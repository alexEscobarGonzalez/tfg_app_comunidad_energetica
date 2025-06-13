# -*- coding: utf-8 -*-

from datetime import datetime, timedelta
import time
from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository
from app.domain.repositories.participante_repository import ParticipanteRepository
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository
from app.domain.repositories.pvpc_precios_repository import PvpcPreciosRepository
from app.domain.entities.estado_simulacion import EstadoSimulacion
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
import logging

from app.domain.use_cases.simulacion.motor_simulacion.aplicar_estrategia_intervalo import aplicar_estrategia_intervalo
from app.domain.use_cases.simulacion.motor_simulacion.persistir_resultados import persistir_todos_los_resultados
from app.domain.use_cases.simulacion.motor_simulacion.calcular_resultados import calcular_todos_resultados


class MotorSimulacion:
    
    def __init__(
        self,
        simulacion_repo: SimulacionRepository,
        comunidad_repo: ComunidadEnergeticaRepository,
        participante_repo: ParticipanteRepository,
        activo_gen_repo: ActivoGeneracionRepository,
        activo_alm_repo: ActivoAlmacenamientoRepository,
        coeficiente_repo: CoeficienteRepartoRepository,
        contrato_repo: ContratoAutoconsumoRepository,
        registro_consumo_repo: RegistroConsumoRepository,
        datos_ambientales_repo: DatosAmbientalesRepository,
        resultado_simulacion_repo: ResultadoSimulacionRepository,
        resultado_participante_repo: ResultadoSimulacionParticipanteRepository,
        resultado_activo_gen_repo: ResultadoSimulacionActivoGeneracionRepository,
        resultado_activo_alm_repo: ResultadoSimulacionActivoAlmacenamientoRepository,
        datos_intervalo_participante_repo: DatosIntervaloParticipanteRepository,
        datos_intervalo_activo_repo: DatosIntervaloActivoRepository,
        pvpc_precios_repo: PvpcPreciosRepository,
        datos_ambientales_api_repo,
        db_session
    ):
        self.simulacion_repo = simulacion_repo
        self.comunidad_repo = comunidad_repo
        self.participante_repo = participante_repo
        self.activo_gen_repo = activo_gen_repo
        self.activo_alm_repo = activo_alm_repo
        self.coeficiente_repo = coeficiente_repo
        self.contrato_repo = contrato_repo
        self.registro_consumo_repo = registro_consumo_repo
        self.datos_ambientales_repo = datos_ambientales_repo
        self.datos_ambientales_api_repo = datos_ambientales_api_repo
        self.resultado_simulacion_repo = resultado_simulacion_repo
        self.resultado_participante_repo = resultado_participante_repo
        self.resultado_activo_gen_repo = resultado_activo_gen_repo
        self.resultado_activo_alm_repo = resultado_activo_alm_repo
        self.datos_intervalo_participante_repo = datos_intervalo_participante_repo
        self.datos_intervalo_activo_repo = datos_intervalo_activo_repo
        self.pvpc_precios_repo = pvpc_precios_repo
        self.db_session = db_session
        self._cache_generacion_pv = {}

    def ejecutar_simulacion(self, simulacion_id: int):
        
        self.simulacion_id = simulacion_id
        
        tiempo_inicio_total = time.time()
        print(f"\n{'='*60}")
        print(f"INICIANDO SIMULACIÓN ID: {simulacion_id}".center(60))
        print(f"{'='*60}")

        try:
            tiempo_fase = time.time()
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.EJECUTANDO.value)
            self.db_session.commit()
            print(f"[1/7] Estado actualizado ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            simulacion = self.simulacion_repo.get_by_id(simulacion_id)
            comunidad = self.comunidad_repo.get_by_id(simulacion.idComunidadEnergetica)
            participantes = self.participante_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            activos_gen = self.activo_gen_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            activos_alm = self.activo_alm_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            contratos = {p.idParticipante: self.contrato_repo.get_by_participante(p.idParticipante) for p in participantes}
            coeficientes = {p.idParticipante: self.coeficiente_repo.get_by_participante(p.idParticipante) for p in participantes}
            
            contratos_pvpc = [c for c in contratos.values() if c and c.tipoContrato.value == "PVPC"]
            print(f"[2/7] Configuración cargada ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            
            datos_consumo = self.registro_consumo_repo.get_range_for_participantes(
                [p.idParticipante for p in participantes],
                simulacion.fechaInicio, simulacion.fechaFin
            )
            consumo_por_intervalo = self._organize_consumo_by_interval(datos_consumo)
            
            datos_ambientales = self.datos_ambientales_api_repo.get_datos_ambientales(
                comunidad.latitud, comunidad.longitud, simulacion.fechaInicio, simulacion.fechaFin
            )
            for dato in datos_ambientales:
                dato.idSimulacion = simulacion_id
            ambiental_por_intervalo = self._organize_ambiental_by_interval(datos_ambientales)
            
            self._gestionar_generacion_activos(
                activos_gen, 
                comunidad.latitud, comunidad.longitud,
                simulacion.fechaInicio, simulacion.fechaFin
            )
            
            self._verificar_consistencia_timestamps(consumo_por_intervalo, ambiental_por_intervalo, self._cache_generacion_pv)
            
            print(f"[3/7] Datos obtenidos ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            timestamps = sorted(consumo_por_intervalo.keys())
            total_intervalos = len(timestamps)
            
            estado_almacenamiento = {
                alm.idActivoAlmacenamiento: {'soc_kwh': 0.0} for alm in activos_alm
            }
            
            resultados_intervalo_activos_generacion = []
            resultados_intervalo_participantes = []
            resultados_intervalo_activos_almacenamiento = []
            
            ultimo_porcentaje = -1
            for idx, current_time in enumerate(timestamps):
                porcentaje_actual = int(((idx + 1) / total_intervalos) * 100)
                if porcentaje_actual % 25 == 0 and porcentaje_actual != ultimo_porcentaje:
                    print(f"      • Progreso: {porcentaje_actual}%")
                    ultimo_porcentaje = porcentaje_actual

                datos_amb = ambiental_por_intervalo.get(current_time, {})
                consumo_int = consumo_por_intervalo.get(current_time, {})

                gen_activos = self._gestionar_generacion_activos(
                    activos_gen, 
                    comunidad.latitud, comunidad.longitud,
                    simulacion.fechaInicio, simulacion.fechaFin,
                    datos_amb, current_time
                )
                
                for activo_id, energia in gen_activos.items():
                    resultados_intervalo_activos_generacion.append({
                        'idActivoGeneracion': activo_id,
                        'timestamp': current_time,
                        'energiaGenerada_kWh': energia
                    })

                resultados_intervalo_participantes_aux, resultados_intervalo_activos_almacenamiento_aux, estado_almacenamiento = aplicar_estrategia_intervalo(
                    simulacion, comunidad, participantes, gen_activos, consumo_int, contratos, coeficientes, current_time, estado_almacenamiento, activos_alm, self.pvpc_precios_repo
                )
                
                resultados_intervalo_participantes.extend(resultados_intervalo_participantes_aux)
                resultados_intervalo_activos_almacenamiento.extend(resultados_intervalo_activos_almacenamiento_aux)

            print(f"[4/7] Simulación ejecutada ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            resultados_globales, resultados_part, resultados_activos_gen, resultados_activos_alm = calcular_todos_resultados(
                simulacion,
                resultados_intervalo_participantes,
                resultados_intervalo_activos_generacion,
                resultados_intervalo_activos_almacenamiento,
                activos_gen,
                activos_alm,
                contratos,
            )
            print(f"[5/7] Resultados calculados ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            repos = {
                'resultado_simulacion_repo': self.resultado_simulacion_repo,
                'resultado_participante_repo': self.resultado_participante_repo,
                'resultado_activo_gen_repo': self.resultado_activo_gen_repo,
                'resultado_activo_alm_repo': self.resultado_activo_alm_repo,
                'datos_ambientales_repo': self.datos_ambientales_repo,
                'datos_intervalo_participante_repo': self.datos_intervalo_participante_repo,
                'datos_intervalo_activo_repo': self.datos_intervalo_activo_repo
            }
            
            resultados_persistidos = persistir_todos_los_resultados(
                repos,
                resultados_globales,
                resultados_part,
                resultados_activos_gen,
                resultados_activos_alm,
                datos_ambientales,
                resultados_intervalo_participantes,
                resultados_intervalo_activos_generacion,
                resultados_intervalo_activos_almacenamiento
            )
            print(f"[6/7] Resultados persistidos ({time.time() - tiempo_fase:.2f}s)")

            tiempo_fase = time.time()
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.COMPLETADA.value)
            self.db_session.commit()
            print(f"[7/7] Estado finalizado ({time.time() - tiempo_fase:.2f}s)")
            
            tiempo_total = time.time() - tiempo_inicio_total
            print(f"\n{'='*60}")
            print(f"SIMULACIÓN COMPLETADA - TIEMPO TOTAL: {tiempo_total:.2f}s".center(60))
            print(f"{'='*60}\n")

        except Exception as e:
            print(f"\n{'!'*60}")
            print(f"ERROR EN LA SIMULACIÓN".center(60))
            print(f"{'!'*60}")
            print(f"Detalles: {str(e)}")
            
            logging.error(f"Error en la simulación: {str(e)}")
            self.db_session.rollback()
            
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.FALLIDA.value)
            self.db_session.commit()
            
            raise

    def _gestionar_generacion_activos(self, activos_gen, lat, lon, fecha_inicio, fecha_fin, datos_ambientales=None, timestamp=None):
        
        # Detectar modo de operación
        modo_precalculo = timestamp is None

        # Parte 1: Precálculo de generación (si estamos en ese modo)
        if modo_precalculo:
            self._cache_generacion_pv = {}  # Reiniciar la caché
            
            # Identificar activos fotovoltaicos para precálculo
            activos_pv = [a for a in activos_gen if a.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA]
            
            for activo in activos_pv:
                # Verificar que tiene los datos necesarios
                if (activo.inclinacionGrados is None or 
                    activo.azimutGrados is None or 
                    activo.potenciaNominal_kWp is None or
                    activo.perdidaSistema is None):
                    # Asignar valores por defecto donde falten
                    inclinacion = activo.inclinacionGrados or 35.0  # Valor típico en España
                    azimut = activo.azimutGrados or 0.0  # 0 = orientación sur
                    potencia = activo.potenciaNominal_kWp or 1.0  # Valor mínimo para evitar error
                    perdida = activo.perdidaSistema or 14.0  # Valor típico
                else:
                    inclinacion = activo.inclinacionGrados
                    azimut = activo.azimutGrados
                    potencia = activo.potenciaNominal_kWp
                    perdida = activo.perdidaSistema
                    
                # Obtener generación PV para este activo
                try:
                    generacion = self.datos_ambientales_api_repo.get_generacion_fotovoltaica(
                        lat=activo.latitud if activo.latitud else lat,
                        lon=activo.longitud if activo.longitud else lon,
                        start_date=fecha_inicio,
                        end_date=fecha_fin,
                        peak_power_kwp=potencia,
                        angle=inclinacion,
                        aspect=azimut,
                        loss=perdida,
                        tech=activo.tecnologiaPanel if activo.tecnologiaPanel else 'crystSi'
                    )
                    
                    # Almacenar en caché
                    self._cache_generacion_pv[activo.idActivoGeneracion] = generacion
                except Exception as e:
                    logging.error(f"Error al precalcular generación PV para activo {activo.idActivoGeneracion}: {e}")
                    self._cache_generacion_pv[activo.idActivoGeneracion] = {}
            
            return None  # En modo precálculo no devolvemos nada
                
        # Parte 2: Cálculo de generación para un timestamp específico
        else:
            if timestamp is None or datos_ambientales is None:
                logging.error("Se requiere timestamp y datos_ambientales para calcular generación")
                return {a.idActivoGeneracion: 0.0 for a in activos_gen}  # Devolver ceros por seguridad
                
            # Crear diccionario de resultado para este intervalo
            generacion_intervalo = {}
            
            for activo in activos_gen:
                energia_generada = 0.0
                
                # Cálculo según tipo de activo
                if activo.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
                    # Intentar obtener valor de la caché
                    cache_activo = self._cache_generacion_pv.get(activo.idActivoGeneracion, {})
                    if timestamp in cache_activo:
                        # Usar valor precalculado (más preciso)
                        energia_generada = cache_activo[timestamp]
                    else:
                        # Fallback: Calcular basado en datos ambientales
                        if 'radiacionGlobalHoriz_Wh_m2' in datos_ambientales:
                            ghi = datos_ambientales['radiacionGlobalHoriz_Wh_m2']
                            potencia_kw = activo.potenciaNominal_kWp or 1.0
                              # Factor de rendimiento: incluir pérdidas, inclinación y orientación básica
                            factor_rendimiento = 0.8  # Factor base
                            if activo.perdidaSistema:
                                factor_rendimiento *= (1 - activo.perdidaSistema / 100)
                            
                            # La fórmula simplificada: kWh = kWp * GHI/1000 * factor_rendimiento
                            energia_generada = potencia_kw * (ghi/1000) * factor_rendimiento
                
                elif activo.tipo_activo == TipoActivoGeneracion.AEROGENERADOR:
                    # Cálculo simplificado para aerogenerador usando la curva de potencia proporcionada
                    if 'velocidadViento_m_s' in datos_ambientales:
                        velocidad = datos_ambientales['velocidadViento_m_s']
                        potencia_nominal = activo.potenciaNominal_kWp or 0.0
                        
                        # Usar la curva de potencia del JSON si está disponible
                        if activo.curvaPotencia and isinstance(activo.curvaPotencia, dict):
                            # Redondear la velocidad para buscarla en el JSON
                            velocidad_str = str(round(velocidad))
                            
                            # Si la velocidad está en el JSON, usar ese valor; si no, devolver 0
                            if velocidad_str in activo.curvaPotencia:
                                factor_potencia = float(activo.curvaPotencia[velocidad_str])
                                energia_generada = potencia_nominal * factor_potencia
                            else:
                                energia_generada = 0.0
                        else:
                            # Si no hay curva de potencia definida, devolver 0
                            energia_generada = 0.0
                
                # Asignar al resultado
                generacion_intervalo[activo.idActivoGeneracion] = energia_generada
            
            return generacion_intervalo    
        
    def _organize_consumo_by_interval(self, datos_consumo):
        
        result = {}
        for registro in datos_consumo:
            if registro.timestamp not in result:
                result[registro.timestamp] = {}
            result[registro.timestamp][registro.idParticipante] = registro.consumoEnergia
            
        if not result and hasattr(self, 'simulacion_id'):
            simulacion = self.simulacion_repo.get_by_id(self.simulacion_id)
            mensaje_error = (f"Error: No se encontraron datos de consumo para el periodo "
                            f"del {simulacion.fechaInicio} al {simulacion.fechaFin}. "
                            f"Por favor, asegúrese de que existen registros de consumo "
                            f"para los participantes en ese periodo.")
            logging.error(mensaje_error)
            raise ValueError(mensaje_error)
            
        return result

    def _organize_ambiental_by_interval(self, datos_ambientales):
        
        result = {}
        for registro in datos_ambientales:
            result[registro.timestamp] = {
                'radiacionGlobalHoriz_Wh_m2': registro.radiacionGlobalHoriz_Wh_m2,
                'temperaturaAmbiente_C': registro.temperaturaAmbiente_C,
                'velocidadViento_m_s': registro.velocidadViento_m_s
            }
            
        return result

    def _verificar_consistencia_timestamps(self, consumo_por_intervalo, ambiental_por_intervalo, cache_generacion_pv):
        
        ts_consumo = set(consumo_por_intervalo.keys())
        ts_ambiental = set(ambiental_por_intervalo.keys())
        
        ts_generacion = set()
        for id_activo, datos_activo in cache_generacion_pv.items():
            ts_generacion.update(datos_activo.keys())
        
        common_timestamps = ts_consumo & ts_ambiental & ts_generacion
        total_unique = len(ts_consumo | ts_ambiental | ts_generacion)
        
        # Verificación silenciosa de consistencia de timestamps
            
        return len(common_timestamps) > 0