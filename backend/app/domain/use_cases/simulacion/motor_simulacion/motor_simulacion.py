# -*- coding: utf-8 -*-

from datetime import datetime, timedelta
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
from app.domain.entities.estado_simulacion import EstadoSimulacion
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
import logging

from app.domain.use_cases.simulacion.motor_simulacion.aplicar_estrategia_intervalo import aplicar_estrategia_intervalo
from app.domain.use_cases.simulacion.motor_simulacion.persistir_resultados import persistir_todos_los_resultados
from app.domain.use_cases.simulacion.motor_simulacion.calcular_resultados import calcular_todos_resultados


class MotorSimulacion:
    """
    Handles the core logic for running an energy community simulation.
    """

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
        datos_ambientales_api_repo,
        db_session
    ):
        """
        Initializes the simulation engine with necessary repositories.
        Args:
            db_session: The database session for data access.
        """
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
        self.db_session = db_session
        # Atributos para cachear datos fotovoltaicos
        self._cache_generacion_pv = {}

    def ejecutar_simulacion(self, simulacion_id: int):
        """
        Runs the simulation for the given simulation ID.
        Args:
            simulacion_id: The ID of the simulation to run.
        """
        # Almacenar ID de simulación para uso en otras funciones
        self.simulacion_id = simulacion_id
        
        print(f"\n{'='*80}")
        print(f"INICIANDO SIMULACIÓN ID: {simulacion_id}".center(80))
        print(f"{'='*80}")

        try:

            # Paso 1: actualizar estado a 'Ejecutando'
            print("\n[1/8] Actualizando estado de la simulación...")
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.EJECUTANDO.value)
            self.db_session.commit()
            print(f"  ✓ Estado actualizado a: {EstadoSimulacion.EJECUTANDO.value}")

            # Paso 2: cargar simulación y configuración
            print("\n[2/8] Cargando datos de configuración...")
            
            simulacion = self.simulacion_repo.get_by_id(simulacion_id)
            print(f"  ✓ Simulación: {simulacion.nombreSimulacion} ({simulacion.fechaInicio} a {simulacion.fechaFin})")
            
            comunidad = self.comunidad_repo.get_by_id(simulacion.idComunidadEnergetica)
            print(f"  ✓ Comunidad: {comunidad.nombre}")
            
            participantes = self.participante_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            print(f"  ✓ Participantes: {len(participantes)} encontrados")
            
            activos_gen = self.activo_gen_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            print(f"  ✓ Activos de generación: {len(activos_gen)} encontrados")
            
            activos_alm = self.activo_alm_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            print(f"  ✓ Activos de almacenamiento: {len(activos_alm)} encontrados")
            
            contratos = {p.idParticipante: self.contrato_repo.get_by_participante(p.idParticipante) for p in participantes}
            coeficientes = {p.idParticipante: self.coeficiente_repo.get_by_participante(p.idParticipante) for p in participantes}
            print(f"  ✓ Contratos y coeficientes de reparto cargados")

            

            # Paso 3: obtener todos los datos necesarios (consumo, ambientales y generación)
            print("\n[3/6] Obteniendo datos de consumo, ambientales y generación...")
            print(f"  • Periodo de simulación: {simulacion.fechaInicio} a {simulacion.fechaFin}")
            
            # 3.1 Cargar datos de consumo
            print(f"  • Cargando datos de consumo para {len(participantes)} participantes...")
            datos_consumo = self.registro_consumo_repo.get_range_for_participantes(
                [p.idParticipante for p in participantes],
                simulacion.fechaInicio, simulacion.fechaFin
            )
            print(f"  ✓ Datos de consumo: {len(datos_consumo)} registros cargados")
            
            # 3.2 Organizar datos de consumo por timestamp
            consumo_por_intervalo = self._organize_consumo_by_interval(datos_consumo)
            print(f"  ✓ Consumo organizado en {len(consumo_por_intervalo)} intervalos")
            
            # 3.3 Obtener datos ambientales utilizando PVGIS
            print(f"  • Solicitando datos ambientales en ubicación: {comunidad.latitud}, {comunidad.longitud}...")
            datos_ambientales = self.datos_ambientales_api_repo.get_datos_ambientales(
                comunidad.latitud, comunidad.longitud, simulacion.fechaInicio, simulacion.fechaFin
            )
            print(f"  ✓ Datos ambientales: {len(datos_ambientales)} registros obtenidos")
            
            # 3.4 Asignar ID de simulación a los datos ambientales
            for dato in datos_ambientales:
                dato.idSimulacion = simulacion_id
            
            # 3.5 Organizar datos ambientales por timestamp
            ambiental_por_intervalo = self._organize_ambiental_by_interval(datos_ambientales)
            print(f"  ✓ Datos ambientales organizados en {len(ambiental_por_intervalo)} intervalos")
            
            # 3.6 Precalcular y organizar datos de generación para activos fotovoltaicos
            activos_pv = [a for a in activos_gen if a.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA]
            print(f"  • Precalculando generación para {len(activos_pv)} activos fotovoltaicos...")
            
            # Ejecutar precálculo de generación (modo sin timestamp)
            self._gestionar_generacion_activos(
                activos_gen, 
                comunidad.latitud, comunidad.longitud,
                simulacion.fechaInicio, simulacion.fechaFin
            )
            
            # Mostrar resumen de datos precalculados de generación
            for activo_id, generacion in self._cache_generacion_pv.items():
                activo_nombre = next((a.nombreDescriptivo for a in activos_gen if a.idActivoGeneracion == activo_id), 'Desconocido')
                print(f"  ✓ Activo {activo_nombre}: {len(generacion)} intervalos de generación precalculados")
            
            
            # 3.8 Validar que los timestamps sean consistentes entre todos los tipos de datos
            print(f"  • Verificando consistencia de los timestamps en los datos de entrada...")
            self._verificar_consistencia_timestamps(consumo_por_intervalo, ambiental_por_intervalo, self._cache_generacion_pv)
            
            print(f"  ✓ Todos los datos de entrada organizados por intervalos de tiempo")
                
    
            # Paso 5: bucle principal de simulación 
            print(f"\n[5/6] Iniciando bucle de simulación...")
            # Preparamos la lista de timestamps ordenados
            timestamps = sorted(consumo_por_intervalo.keys())
            total_intervalos = len(timestamps)
            print(f"  • Total intervalos a procesar: {total_intervalos}")
            print(f"  • Intervalo de tiempo: {simulacion.tiempo_medicion} minutos")
    
            intervalos_procesados = 0
            ultimo_porcentaje = -1
            
            # Paso 5.1: Inicializar resultados
            estado_almacenamiento = {
                alm.idActivoAlmacenamiento: {'soc_kwh': 0.0} for alm in activos_alm
            }
            
            resultados_intervalo_activos_generacion = []
            resultados_intervalo_participantes = []
            resultados_intervalo_activos_almacenamiento = []
            
            estado_almacenamiento = {
                alm.idActivoAlmacenamiento: {'soc_kwh': 0.0} for alm in activos_alm
            }
    
            for idx, current_time in enumerate(timestamps):
                # Mostrar progreso cada 5%
                porcentaje_actual = int(((idx + 1) / total_intervalos) * 100)
                if porcentaje_actual % 5 == 0 and porcentaje_actual != ultimo_porcentaje:
                    print(f"  • Progreso: {porcentaje_actual}% ({idx + 1}/{total_intervalos})")
                    ultimo_porcentaje = porcentaje_actual
    
                # Extraer datos de este intervalo
                datos_amb = ambiental_por_intervalo.get(current_time, {})
                consumo_int = consumo_por_intervalo.get(current_time, {})
    
                # Generación y consumo - Utilizando nuestra nueva función unificada
                gen_activos = self._gestionar_generacion_activos(
                    activos_gen, 
                    comunidad.latitud, comunidad.longitud,
                    simulacion.fechaInicio, simulacion.fechaFin,
                    datos_amb, current_time
                )
                
                # Añadir valores a la lista de resultados generacion
                for activo_id, energia in gen_activos.items():

                    resultados_intervalo_activos_generacion.append({
                        'idActivoGeneracion': activo_id,
                        'timestamp': current_time,
                        'energiaGenerada_kWh': energia
                    })

    
                print(f"  • Generación calculada para {len(gen_activos)} activos de generación")
                
                # Almacenamiento y reparto según estrategia
                resultados_intervalo_participantes_aux, resultados_intervalo_activos_almacenamiento_aux, estado_almacenamiento = aplicar_estrategia_intervalo(
                    comunidad, participantes, gen_activos, consumo_int, contratos, coeficientes, current_time, estado_almacenamiento, activos_alm
                )
                
                # Añadir valores a la lista de resultados participantes y almacenamiento
                resultados_intervalo_participantes.extend(resultados_intervalo_participantes_aux)
                resultados_intervalo_activos_almacenamiento.extend(resultados_intervalo_activos_almacenamiento_aux)
                
                

                intervalos_procesados += 1

            print(f"  ✓ Bucle completado: {intervalos_procesados} intervalos procesados")
            print(f"  ✓ Resultados generados: {len(resultados_intervalo_participantes)} registros de participantes")
            print(f"  ✓ Resultados generados: {len(resultados_intervalo_activos_generacion)} registros de activos de generación")
            print(f"  ✓ Resultados generados: {len(resultados_intervalo_activos_almacenamiento)} registros de activos de almacenamiento")

            # Paso 6: calcular resultados globales
            print(f"\n[6/8] Calculando resultados globales...")
            resultados_globales, resultados_part, resultados_activos_gen, resultados_activos_alm = calcular_todos_resultados(
                simulacion,
                resultados_intervalo_participantes,
                resultados_intervalo_activos_generacion,
                resultados_intervalo_activos_almacenamiento,
                activos_gen,
                activos_alm,
            )

            # Paso 7: persistir resultados
            print(f"\n[7/8] Guardando resultados en base de datos...")
            
            # Usar las nuevas funciones de persistencia
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
            
            # Mostrar resumen de resultados
            print(f"  ✓ Resultados guardados exitosamente")
            print(f"    - Resultados globales: ID {resultados_persistidos['resultado_global'].idResultado}")
            print(f"    - Participantes: {len(resultados_persistidos['resultados_participantes'])}")
            print(f"    - Activos generación: {len(resultados_persistidos['resultados_activos_generacion'])}")
            print(f"    - Activos almacenamiento: {len(resultados_persistidos['resultados_activos_almacenamiento'])}")
            print(f"    - Intervalos participantes: {len(resultados_persistidos['intervalos_participantes'])}")
            print(f"    - Intervalos generación: {len(resultados_persistidos['intervalos_activos_generacion'])}")
            print(f"    - Intervalos almacenamiento: {len(resultados_persistidos['intervalos_activos_almacenamiento'])}")
            
            self.db_session.commit()
            print(f"  ✓ Transacción de base de datos confirmada")

            # Actualizar estado a 'Completada'
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.COMPLETADA.value)
            self.db_session.commit()
            print(f"  ✓ Estado actualizado a: {EstadoSimulacion.COMPLETADA.value}")
            
            print(f"\n{'='*80}")
            print(f"SIMULACIÓN ID: {simulacion_id} COMPLETADA CON ÉXITO".center(80))
            print(f"{'='*80}\n")

        except Exception as e:
            print(f"\n{'!'*80}")
            print(f"ERROR EN LA SIMULACIÓN".center(80))
            print(f"{'!'*80}")
            print(f"Detalles del error: {str(e)}")
            
            logging.error(f"Error en la simulación: {str(e)}")
            self.db_session.rollback()
            print("  • Transacción revertida")
            
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.FALLIDA.value)
            self.db_session.commit()
            print(f"  • Estado actualizado a: {EstadoSimulacion.FALLIDA.value}")
            
            raise

    
        
    def _gestionar_generacion_activos(self, activos_gen, lat, lon, fecha_inicio, fecha_fin, datos_ambientales=None, timestamp=None):
        """
        Función unificada que gestiona tanto el precálculo como el cálculo en tiempo real de la 
        generación de energía para todos los activos.
        
        Primero precalcula y almacena en caché los datos de generación para todo el período
        de la simulación (especialmente para activos fotovoltaicos).
        Luego proporciona datos de generación para un timestamp específico.
        
        Args:
            activos_gen: Lista de activos de generación
            lat: Latitud de la comunidad (coordenada base)
            lon: Longitud de la comunidad (coordenada base)
            fecha_inicio: Fecha de inicio de la simulación
            fecha_fin: Fecha de fin de la simulación
            datos_ambientales: Datos ambientales para un intervalo específico (opcional)
            timestamp: Momento específico para el que solicita la generación (opcional)
            
        Returns:
            En el modo de precálculo (timestamp=None): No devuelve nada, solo rellena la caché
            En el modo de cálculo (timestamp especificado): Diccionario {id_activo: energía_generada_kWh}
        """
        # Detectar modo de operación
        modo_precalculo = timestamp is None

        # Parte 1: Precálculo de generación (si estamos en ese modo)
        if modo_precalculo:
            logging.info(f"Iniciando precálculo de generación para {len(activos_gen)} activos")
            self._cache_generacion_pv = {}  # Reiniciar la caché
            
            # Identificar activos fotovoltaicos para precálculo
            activos_pv = [a for a in activos_gen if a.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA]
            
            for activo in activos_pv:
                # Verificar que tiene los datos necesarios
                if (activo.inclinacionGrados is None or 
                    activo.azimutGrados is None or 
                    activo.potenciaNominal_kWp is None or
                    activo.perdidaSistema is None):
                    logging.warning(f"Activo PV {activo.idActivoGeneracion} - {activo.nombreDescriptivo} "
                                   f"no tiene todos los datos necesarios para cálculo preciso. "
                                   "Se usarán valores predeterminados.")
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
                    print(f"  • Generación precalculada para activo {activo.nombreDescriptivo}: {len(generacion)} intervalos")
                    logging.info(f"Precalculada generación PV para activo {activo.idActivoGeneracion} - "
                                f"{activo.nombreDescriptivo}: {len(generacion)} intervalos")
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
        """
        Organiza los datos de consumo por intervalo de tiempo.
        
        Args:
            datos_consumo: Lista de registros de consumo obtenidos de la base de datos
            
        Returns:
            Diccionario con estructura {timestamp: {id_participante: consumo_kWh, ...}, ...}
            
        Raises:
            ValueError: Si no hay datos de consumo para el periodo de simulación
        """
        result = {}
        for registro in datos_consumo:
            # Initialize the dictionary for this timestamp if it doesn't exist yet
            if registro.timestamp not in result:
                result[registro.timestamp] = {}
                
            # Add the consumption for this participant at this timestamp
            result[registro.timestamp][registro.idParticipante] = registro.consumoEnergia
            
        # Verificar que existan datos de consumo
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
            # Create a dictionary with environmental data for each timestamp
            result[registro.timestamp] = {
                'radiacionGlobalHoriz_Wh_m2': registro.radiacionGlobalHoriz_Wh_m2,
                'temperaturaAmbiente_C': registro.temperaturaAmbiente_C,
                'velocidadViento_m_s': registro.velocidadViento_m_s
            }
            
        return result



    
    def _verificar_consistencia_timestamps(self, consumo_por_intervalo, ambiental_por_intervalo, cache_generacion_pv):
        """
        Comprueba que los timestamps de los datos de consumo, ambientales y generación coinciden.
        Muestra información detallada para depuración.
        
        Args:
            consumo_por_intervalo: dict {timestamp: {id_participante: consumo_kWh}}
            ambiental_por_intervalo: dict {timestamp: {datos_ambientales}}
            cache_generacion_pv: dict {id_activo: {timestamp: generacion_kWh}}
        """
        print("\n[DEBUG] Verificando consistencia de timestamps entre los datos de entrada...")
        
        # Extraer conjuntos de timestamps de cada fuente
        ts_consumo = set(consumo_por_intervalo.keys())
        ts_ambiental = set(ambiental_por_intervalo.keys())
        
        # Para generación, necesitamos combinar timestamps de todos los activos
        ts_generacion = set()
        for id_activo, datos_activo in cache_generacion_pv.items():
            ts_generacion.update(datos_activo.keys())
        
        print(f"  • Total timestamps en consumo:     {len(ts_consumo)} muestras")
        print(f"  • Total timestamps en ambiental:   {len(ts_ambiental)} muestras")
        print(f"  • Total timestamps en generación:  {len(ts_generacion)} muestras")
        
        # Mostrar ejemplos del inicio y fin de cada conjunto
        if ts_consumo:
            ts_list = sorted(list(ts_consumo))
            print(f"    Ejemplo consumo:    {ts_list[:3]} ... {ts_list[-3:]}")
        
        if ts_ambiental:  
            ts_list = sorted(list(ts_ambiental))
            print(f"    Ejemplo ambiental:  {ts_list[:3]} ... {ts_list[-3:]}")
        
        if ts_generacion:
            ts_list = sorted(list(ts_generacion))
            print(f"    Ejemplo generación: {ts_list[:3]} ... {ts_list[-3:]}")
        
        # Identificar timestamps que solo existen en uno de los conjuntos
        only_in_consumo = ts_consumo - ts_ambiental - ts_generacion
        only_in_ambiental = ts_ambiental - ts_consumo - ts_generacion
        only_in_generacion = ts_generacion - ts_consumo - ts_ambiental
        
        # Identificar timestamps comunes a todos los conjuntos
        common_timestamps = ts_consumo & ts_ambiental & ts_generacion
        
        # Reportar discrepancias si existen
        if only_in_consumo:
            print(f"  [WARN] {len(only_in_consumo)} timestamps solo existen en datos de consumo")
            print(f"    Primeros ejemplos: {sorted(list(only_in_consumo))[:5]}")
        
        if only_in_ambiental:
            print(f"  [WARN] {len(only_in_ambiental)} timestamps solo existen en datos ambientales")
            print(f"    Primeros ejemplos: {sorted(list(only_in_ambiental))[:5]}")
        
        if only_in_generacion:
            print(f"  [WARN] {len(only_in_generacion)} timestamps solo existen en datos de generación")
            print(f"    Primeros ejemplos: {sorted(list(only_in_generacion))[:5]}")
        
        # Verificar timestamps faltantes entre conjuntos
        missing_in_consumo = (ts_ambiental | ts_generacion) - ts_consumo
        missing_in_ambiental = (ts_consumo | ts_generacion) - ts_ambiental
        missing_in_generacion = (ts_consumo | ts_ambiental) - ts_generacion
        
        if missing_in_consumo:
            print(f"  [WARN] Faltan {len(missing_in_consumo)} timestamps en datos de consumo")
            print(f"    Primeros ejemplos: {sorted(list(missing_in_consumo))[:5]}")
        
        if missing_in_ambiental:
            print(f"  [WARN] Faltan {len(missing_in_ambiental)} timestamps en datos ambientales")
            print(f"    Primeros ejemplos: {sorted(list(missing_in_ambiental))[:5]}")
        
        if missing_in_generacion:
            print(f"  [WARN] Faltan {len(missing_in_generacion)} timestamps en datos de generación")
            print(f"    Primeros ejemplos: {sorted(list(missing_in_generacion))[:5]}")
        
        # Resultado final
        if len(common_timestamps) == 0:
            print("  [ERROR] ¡No hay ningún timestamp común entre las tres fuentes de datos!")
            print("          La simulación puede fallar o producir resultados inconsistentes.")
        elif len(common_timestamps) == len(ts_consumo) == len(ts_ambiental) == len(ts_generacion):
            print(f"  ✓ Perfecta coincidencia: {len(common_timestamps)} timestamps comunes en todas las fuentes")
        else:
            print(f"  [ATENCIÓN] Hay {len(common_timestamps)} timestamps comunes entre todas las fuentes")
            print(f"  [ATENCIÓN] {len(ts_consumo | ts_ambiental | ts_generacion) - len(common_timestamps)} timestamps presentan discrepancias")
            
            # Calcular porcentaje de coincidencia
            total_unique = len(ts_consumo | ts_ambiental | ts_generacion)
            coincidencia = (len(common_timestamps) / total_unique) * 100 if total_unique > 0 else 0
            print(f"  • Porcentaje de coincidencia: {coincidencia:.2f}%")
            
        return len(common_timestamps) > 0