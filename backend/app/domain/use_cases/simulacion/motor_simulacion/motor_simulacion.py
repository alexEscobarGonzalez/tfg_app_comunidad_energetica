# -*- coding: utf-8 -*-

from datetime import datetime, timedelta
from app.infrastructure.persistance.repository.sqlalchemy_simulacion_repository import SqlAlchemySimulacionRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository
from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_datos_ambientales_repository import SqlAlchemyDatosAmbientalesRepository
from app.infrastructure.pvgis.datos_ambientales_api_repository import DatosAmbientalesApiRepository
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_participante_repository import SqlAlchemyResultadoSimulacionParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_generacion_repository import SqlAlchemyResultadoSimulacionActivoGeneracionRepository
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_almacenamiento_repository import SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_participante_repository import SqlAlchemyDatosIntervaloParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_activo_repository import SqlAlchemyDatosIntervaloActivoRepository
from app.domain.entities.estado_simulacion import EstadoSimulacion
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
import logging


class MotorSimulacion:
    """
    Handles the core logic for running an energy community simulation.
    """

    def __init__(self, db_session):
        """
        Initializes the simulation engine with necessary repositories.
        Args:
            db_session: The database session for data access.
        """
        # Instanciar repositorios Sqlalchemy
        self.simulacion_repo = SqlAlchemySimulacionRepository(db_session)
        self.comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db_session)
        self.participante_repo = SqlAlchemyParticipanteRepository(db_session)
        self.activo_gen_repo = SqlAlchemyActivoGeneracionRepository(db_session)
        self.activo_alm_repo = SqlAlchemyActivoAlmacenamientoRepository(db_session)
        self.coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db_session)
        self.contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db_session)
        self.registro_consumo_repo = SqlAlchemyRegistroConsumoRepository(db_session)
        self.datos_ambientales_repo = SqlAlchemyDatosAmbientalesRepository(db_session)
        self.datos_ambientales_api_repo = DatosAmbientalesApiRepository()
        self.resultado_simulacion_repo = SqlAlchemyResultadoSimulacionRepository(db_session)
        self.resultado_participante_repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db_session)
        self.resultado_activo_gen_repo = SqlAlchemyResultadoSimulacionActivoGeneracionRepository(db_session)
        self.resultado_activo_alm_repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db_session)
        self.datos_intervalo_participante_repo = SqlAlchemyDatosIntervaloParticipanteRepository(db_session)
        self.datos_intervalo_activo_repo = SqlAlchemyDatosIntervaloActivoRepository(db_session)
        self.db_session = db_session
        # Atributos para cachear datos fotovoltaicos
        self._cache_generacion_pv = {}
        # Directorio para archivos de depuración
        self.debug_dir = "debug_outputs"
        import os
        if not os.path.exists(self.debug_dir):
            os.makedirs(self.debug_dir)

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
            # Paso 1: cargar simulación y configuración
            print("\n[1/8] Cargando datos de configuración...")
            
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

            # Paso 2: actualizar estado a 'Ejecutando'
            print("\n[2/8] Actualizando estado de la simulación...")
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.EJECUTANDO.value)
            self.db_session.commit()
            print(f"  ✓ Estado actualizado a: {EstadoSimulacion.EJECUTANDO.value}")

            # Paso 3: obtener datos de consumo y ambientales
            print("\n[3/8] Obteniendo datos de consumo y ambientales...")
            print(f"  • Periodo: {simulacion.fechaInicio} a {simulacion.fechaFin}")
            
            print(f"  • Cargando datos de consumo para {len(participantes)} participantes...")
            datos_consumo = self.registro_consumo_repo.get_range_for_participantes(
                [p.idParticipante for p in participantes],
                simulacion.fechaInicio, simulacion.fechaFin
            )
            print(f"  ✓ Datos de consumo: {len(datos_consumo)} registros cargados")

            # Obtener datos ambientales utilizando PVGIS
            print(f"  • Solicitando datos ambientales de PVGIS en ubicación: {comunidad.latitud}, {comunidad.longitud}...")
            datos_ambientales = self.datos_ambientales_api_repo.get_datos_ambientales(
                comunidad.latitud, comunidad.longitud, simulacion.fechaInicio, simulacion.fechaFin
            )
            print(f"  ✓ Datos ambientales: {len(datos_ambientales)} registros obtenidos")
            
            # Asignar el ID de simulación a los datos ambientales obtenidos
            for dato in datos_ambientales:
                dato.idSimulacion = simulacion_id
            
            print("  • Organizando datos por intervalos...")
            consumo_por_intervalo = self._organize_consumo_by_interval(datos_consumo)
            ambiental_por_intervalo = self._organize_ambiental_by_interval(datos_ambientales)
            print(f"  ✓ {len(consumo_por_intervalo)} intervalos de consumo organizados")
            print(f"  ✓ {len(ambiental_por_intervalo)} intervalos de datos ambientales organizados")
            
            # Precalcular la generación solar para todos los activos fotovoltaicos
            activos_pv = [a for a in activos_gen if a.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA]
            print(f"\n[4/8] Precalculando generación fotovoltaica para {len(activos_pv)} activos...")
            self._gestionar_generacion_activos(
                activos_gen, 
                comunidad.latitud, comunidad.longitud,
                simulacion.fechaInicio, simulacion.fechaFin
            )
            
            # Mostrar resumen de los datos precalculados
            for activo_id, generacion in self._cache_generacion_pv.items():
                activo_nombre = next((a.nombreDescriptivo for a in activos_gen if a.idActivoGeneracion == activo_id), 'Desconocido')
                print(f"  ✓ Activo {activo_nombre}: {len(generacion)} intervalos precalculados")

            # Paso 5: inicializar estado interno
            print("\n[5/8] Inicializando estado interno de la simulación...")
            estado_almacenamiento = {
                alm.idActivoAlmacenamiento: {'soc_kwh': 0.0} for alm in activos_alm
            }
            resultados_intervalo_participantes = []
            resultados_intervalo_activos = []
            print(f"  ✓ Estado de almacenamiento inicializado para {len(activos_alm)} activos")

    
            # Paso 6: bucle de simulación (refactorizado usando for en lugar de while)
            print(f"\n[6/8] Iniciando bucle de simulación...")
            # Preparamos la lista de timestamps ordenados
            timestamps = sorted(consumo_por_intervalo.keys())
            total_intervalos = len(timestamps)
            print(f"  • Total intervalos a procesar: {total_intervalos}")
            print(f"  • Intervalo de tiempo: {simulacion.tiempo_medicion} minutos")
    
            intervalos_procesados = 0
            ultimo_porcentaje = -1
    
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

                # Guardar información de generación para depuración
                self._guardar_cache_generacion_json()
    
                print(f"  • Generación calculada para {len(gen_activos)} activos de generación")
                
                # Almacenamiento y reparto según estrategia
                resultados_i, estado_almacenamiento = self._aplicar_estrategia_intervalo(
                    comunidad, participantes, gen_activos, consumo_int,
                    estado_almacenamiento, contratos, coeficientes, current_time
                )

                resultados_intervalo_participantes.extend(resultados_i['participantes'])
                resultados_intervalo_activos.extend(resultados_i['activos'])
                intervalos_procesados += 1

            print(f"  ✓ Bucle completado: {intervalos_procesados} intervalos procesados")
            print(f"  ✓ Resultados generados: {len(resultados_intervalo_participantes)} registros de participantes")
            print(f"  ✓ Resultados generados: {len(resultados_intervalo_activos)} registros de activos")

            # Paso 7: calcular resultados globales
            print(f"\n[7/8] Calculando resultados agregados...")
            resultados_globales = self._calcular_resultados_globales(resultados_intervalo_participantes,
                                                                    resultados_intervalo_activos)
            print(f"  ✓ Resultados globales calculados")
            
            resultados_part = self._calcular_resultados_participantes(resultados_intervalo_participantes)
            print(f"  ✓ Resultados por participante calculados: {len(resultados_part)} participantes")
            
            resultados_activos_gen = self._calcular_resultados_activos_gen(resultados_intervalo_activos)
            print(f"  ✓ Resultados por activo de generación calculados: {len(resultados_activos_gen)} activos")
            
            resultados_activos_alm = self._calcular_resultados_activos_alm(resultados_intervalo_activos)
            print(f"  ✓ Resultados por activo de almacenamiento calculados: {len(resultados_activos_alm)} activos")

            # Paso 8: persistir resultados
            print(f"\n[8/8] Guardando resultados en base de datos...")
            resultado_global = self.resultado_simulacion_repo.create(resultados_globales)
            print(f"  ✓ Resultados globales guardados")
            
            self.resultado_participante_repo.create_bulk(resultados_part, resultado_global.idResultado)
            print(f"  ✓ Resultados de participantes guardados")
            
            # Guardar los datos ambientales después de que la simulación se ha completado con éxito
            self.datos_ambientales_repo.create_bulk(datos_ambientales)
            print(f"  ✓ Datos ambientales guardados: {len(datos_ambientales)} registros")

            # Guardar intervalos de participantes y activos


            # Participantes
            datos_intervalo_participantes = [
                DatosIntervaloParticipanteEntity(
                    timestamp=res['timestamp'],
                    consumoReal_kWh=res.get('consumoEnergia_kWh'),
                    produccionPropia_kWh=res.get('energiaAutoconsumida_kWh'),
                    energiaDesdeRed_kWh=res.get('energiaCompradaRed_kWh'),
                    excedenteVertidoCompensado_kWh=res.get('energiaExcedentesRed_kWh'),
                    idResultadoParticipante=res.get('idParticipante')
                )
                for res in resultados_intervalo_participantes
            ]
            self.datos_intervalo_participante_repo.create_bulk(datos_intervalo_participantes)
            print(f"  ✓ Intervalos de participantes guardados: {len(datos_intervalo_participantes)} registros")

            # Activos
            datos_intervalo_activos = [
                DatosIntervaloActivoEntity(
                    timestamp=res['timestamp'],
                    idResultadoActivo=res.get('idActivo'),
                    energiaGenerada_kWh=res.get('generacionTotal_kWh'),
                    energiaUtilizada_kWh=res.get('energiaUtilizada_kWh'),
                    energiaExcedente_kWh=res.get('energiaExcedente_kWh'),
                    energiaAlmacenada_kWh=res.get('energiaAlmacenada_kWh'),
                    energiaLiberada_kWh=res.get('energiaLiberada_kWh'),
                    estadoCarga_pct=res.get('estadoCarga_pct'),
                    tipo_activo=res.get('tipo_activo')
                )
                for res in resultados_intervalo_activos
            ]
            self.datos_intervalo_activo_repo.create_bulk(datos_intervalo_activos)
            print(f"  ✓ Intervalos de activos guardados: {len(datos_intervalo_activos)} registros")

            # ... bulk de activos y datos de intervalo ...
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
                    # Cálculo para aerogenerador (modelo simplificado)
                    if 'velocidadViento_m_s' in datos_ambientales:
                        velocidad = datos_ambientales['velocidadViento_m_s']
                        potencia_nominal = activo.potenciaNominal_kWp or 0.0
                        
                        # Cálculo basado en curva de potencia simplificada
                        if velocidad < 3.0:  # Velocidad mínima de arranque
                            energia_generada = 0.0
                        elif velocidad > 25.0:  # Velocidad de corte por seguridad
                            energia_generada = 0.0
                        else:
                            # Aproximación cúbica simplificada a la curva de potencia eólica
                            factor_velocidad = min(1.0, (velocidad - 3.0) / 10.0) ** 3
                            energia_generada = potencia_nominal * factor_velocidad
                
                # Asignar al resultado
                generacion_intervalo[activo.idActivoGeneracion] = energia_generada
            
            return generacion_intervalo

    def _precalcular_generacion_fotovoltaica(self, activos_gen, lat, lon, fecha_inicio, fecha_fin):
        """
        Precalcula la generación fotovoltaica para todos los activos PV.
        
        Args:
            activos_gen: Lista de activos de generación
            lat: Latitud de la comunidad
            lon: Longitud de la comunidad
            fecha_inicio: Fecha de inicio de la simulación
            fecha_fin: Fecha de fin de la simulación
        """
        activos_pv = [a for a in activos_gen if a.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA]
        
        for activo in activos_pv:
            # Verificar que tiene los datos necesarios
            if (activo.inclinacionGrados is None or 
                activo.azimutGrados is None or 
                activo.potenciaNominal_kWp is None or
                activo.perdidaSistema is None):
                logging.warning(f"Activo PV {activo.idActivoGeneracion} - {activo.nombreDescriptivo} "
                               f"no tiene todos los datos necesarios para cálculo preciso."
                               "Se usarán valores predeterminados.")
                continue
                
            # Obtener generación PV para este activo
            try:
                generacion = self.datos_ambientales_api_repo.get_generacion_fotovoltaica(
                    lat=activo.latitud if activo.latitud else lat,
                    lon=activo.longitud if activo.longitud else lon,
                    start_date=fecha_inicio,
                    end_date=fecha_fin,
                    peak_power_kwp=activo.potenciaNominal_kWp,
                    angle=activo.inclinacionGrados,
                    aspect=activo.azimutGrados,
                    loss=activo.perdidaSistema if activo.perdidaSistema else 14.0,
                    tech=activo.tecnologiaPanel if activo.tecnologiaPanel else 'crystSi'
                )
                
                # Almacenar en caché
                self._cache_generacion_pv[activo.idActivoGeneracion] = generacion
                logging.info(f"Precalculada generación PV para activo {activo.idActivoGeneracion} - "
                            f"{activo.nombreDescriptivo}: {len(generacion)} intervalos")
            except Exception as e:
                logging.error(f"Error al precalcular generación PV para activo {activo.idActivoGeneracion}: {e}")
                self._cache_generacion_pv[activo.idActivoGeneracion] = {}

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

    def _calcular_generacion_activo(self, activo_gen, datos_ambientales, timestamp):
        """
        Calcula la generación para un activo específico basado en su tipo y datos ambientales.
        
        Args:
            activo_gen: Activo de generación
            datos_ambientales: Datos ambientales para el intervalo
            timestamp: Momento actual de la simulación
            
        Returns:
            float: Energía generada en kWh en el intervalo
        """
        # Si es un activo fotovoltaico, usar los datos precalculados por PVGIS
        if activo_gen.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
            # Si tenemos datos precalculados para este activo
            if activo_gen.idActivoGeneracion in self._cache_generacion_pv:
                generacion_cache = self._cache_generacion_pv[activo_gen.idActivoGeneracion]
                # Si tenemos el timestamp exacto, usar ese valor
                print(f"  • Buscando generación precalculada para activo {activo_gen.nombreDescriptivo} en timestamp {timestamp}")
                if timestamp in generacion_cache:
                    print(f"  • Generación precalculada para activo {activo_gen.nombreDescriptivo} en timestamp {timestamp}")
                    return generacion_cache[timestamp]
            
            # Si no tenemos datos precalculados, hacemos cálculo básico basado en radiación
            if datos_ambientales and 'radiacionGlobalHoriz_Wh_m2' in datos_ambientales:
                # Modelo muy simplificado: radiación * área efectiva * eficiencia
                ghi = datos_ambientales['radiacionGlobalHoriz_Wh_m2']
                potencia_kw = activo_gen.potenciaNominal_kWp
                # Suponemos factor de rendimiento básico de 0.8
                factor_rendimiento = 0.8
                
                # La fórmula simplificada sería: kWh = kWp * GHI/1000 * PR (factor de rendimiento)
                return potencia_kw * (ghi/1000) * factor_rendimiento
        
        elif activo_gen.tipo_activo == TipoActivoGeneracion.AEROGENERADOR:
            # Implementar modelo de generación eólica cuando sea necesario
            if datos_ambientales and 'velocidadViento_m_s' in datos_ambientales:
                velocidad = datos_ambientales['velocidadViento_m_s']
                # Implementar curva de potencia aquí - ejemplo simplificado
                if velocidad < 3.0:  # Velocidad mínima de arranque
                    return 0.0
                elif velocidad > 25.0:  # Velocidad de corte
                    return 0.0
                else:
                    # Aproximación cúbica simplificada a la potencia eólica
                    potencia_nominal = activo_gen.potenciaNominal_kWp
                    factor_velocidad = min(1.0, (velocidad-3.0) / 10.0) ** 3  # ejemplo simplificado
                    return potencia_nominal * factor_velocidad
        
        # Para otros tipos o si falta información, devolver 0
        return 0.0

    def _calcular_resultados_globales(self, resultados_participantes, resultados_activos):
        """
        Calcula los resultados globales de la simulación agregando datos de intervalos
        
        Args:
            resultados_participantes: Lista de resultados por intervalo para cada participante
            resultados_activos: Lista de resultados por intervalo para cada activo
            
        Returns:
            Entidad ResultadoSimulacion con los resultados agregados
        """
        from datetime import datetime
        from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
        
        if not resultados_participantes and not resultados_activos:
            logging.warning("No hay datos suficientes para calcular resultados globales")
            # Devolver una entidad con valores por defecto
            return ResultadoSimulacionEntity(
                idResultado=None,  # Se asignará automáticamente
                idSimulacion=self.simulacion_id,
                fechaCreacion=datetime.now(),  # Importante: añadir la fecha de creación
                costeTotalEnergia_eur=0,
                ahorroTotal_eur=0,
                ingresoTotalExportacion_eur=0,
                paybackPeriod_anios=0,
                roi_pct=0,
                tasaAutoconsumoSCR_pct=0,
                tasaAutosuficienciaSSR_pct=0,
                energiaTotalImportada_kWh=0,
                energiaTotalExportada_kWh=0,
                energiaCompartidaInterna_kWh=0,
                reduccionPicoDemanda_kW=0,
                reduccionPicoDemanda_pct=0,
                reduccionCO2_kg=0
            )
        
        # Agregación de datos de participantes
        energia_consumida = sum(r.get('consumoEnergia_kWh', 0) for r in resultados_participantes if isinstance(r, dict))
        energia_autoconsumida = sum(r.get('energiaAutoconsumida_kWh', 0) for r in resultados_participantes if isinstance(r, dict))
        energia_comprada_red = sum(r.get('energiaCompradaRed_kWh', 0) for r in resultados_participantes if isinstance(r, dict))
        energia_excedentes_red = sum(r.get('energiaExcedentesRed_kWh', 0) for r in resultados_participantes if isinstance(r, dict))
        
        # Agregación de datos de activos
        energia_generada = sum(r.get('generacionTotal_kWh', 0) for r in resultados_activos if isinstance(r, dict))
        energia_excedentes = sum(r.get('energiaExcedente_kWh', 0) for r in resultados_activos if isinstance(r, dict))
        
        # Cálculos derivados
        porcentaje_autoconsumo = (energia_autoconsumida / energia_consumida * 100) if energia_consumida > 0 else 0
        tasa_autosuficiencia = (energia_autoconsumida / energia_consumida * 100) if energia_consumida > 0 else 0
        
        # Factores ambientales y económicos (valores aproximados)
        factor_co2_red = 0.25  # kg CO2 / kWh (valor aproximado de España)
        precio_energia_red = 0.15  # EUR / kWh (precio medio aproximado)
        precio_exportacion = 0.06  # EUR / kWh (compensación excedentes aproximada)
        
        # Cálculo de ahorros
        ahorro_co2 = energia_autoconsumida * factor_co2_red  # kg de CO2 evitados
        coste_energia = energia_comprada_red * precio_energia_red  # EUR gastados
        ingreso_exportacion = energia_excedentes_red * precio_exportacion  # EUR ingresados
        ahorro_economico = energia_autoconsumida * precio_energia_red  # EUR ahorrados
        
        # Construir entidad de resultados
        resultados = ResultadoSimulacionEntity(
            idResultado=None,  # Se asignará automáticamente
            idSimulacion=self.simulacion_id,
            fechaCreacion=datetime.now(),
            costeTotalEnergia_eur=round(coste_energia, 2),
            ahorroTotal_eur=round(ahorro_economico, 2),
            ingresoTotalExportacion_eur=round(ingreso_exportacion, 2),
            paybackPeriod_anios=0,  # Requiere información adicional de inversión
            roi_pct=0,  # Requiere información adicional de inversión
            tasaAutoconsumoSCR_pct=round(porcentaje_autoconsumo, 2),
            tasaAutosuficienciaSSR_pct=round(tasa_autosuficiencia, 2),
            energiaTotalImportada_kWh=round(energia_comprada_red, 3),
            energiaTotalExportada_kWh=round(energia_excedentes_red, 3),
            energiaCompartidaInterna_kWh=round(energia_autoconsumida, 3),
            reduccionPicoDemanda_kW=0,  # Requiere análisis detallado por intervalos
            reduccionPicoDemanda_pct=0,  # Requiere análisis detallado por intervalos
            reduccionCO2_kg=round(ahorro_co2, 2)
        )
        
        logging.info(f"Resultados globales calculados")
        return resultados

    def _calcular_resultados_participantes(self, resultados_intervalo_participantes):
        """
        Agrega los resultados por intervalo para cada participante en resultados globales por participante
        
        Args:
            resultados_intervalo_participantes: Lista de resultados por intervalo para cada participante
            
        Returns:
            Lista de entidades ResultadoSimulacionParticipante con los resultados agregados
        """
        if not resultados_intervalo_participantes:
            logging.warning("No hay datos de intervalos para calcular resultados de participantes")
            return []
        
        # Organizar datos por participante
        datos_por_participante = {}
        for resultado in resultados_intervalo_participantes:
            if not isinstance(resultado, dict):
                continue
                
            id_participante = resultado.get('idParticipante')
            if not id_participante:
                continue
                
            if id_participante not in datos_por_participante:
                datos_por_participante[id_participante] = {
                    'consumoTotal_kWh': 0,
                    'energiaAutoconsumidaTotal_kWh': 0,
                    'energiaCompradaRedTotal_kWh': 0,
                    'energiaExcedentesRedTotal_kWh': 0,
                    'costeEnergeticoTotal_euros': 0
                }
            
            # Sumar datos del intervalo
            datos = datos_por_participante[id_participante]
            datos['consumoTotal_kWh'] += resultado.get('consumoEnergia_kWh', 0)
            datos['energiaAutoconsumidaTotal_kWh'] += resultado.get('energiaAutoconsumida_kWh', 0)
            datos['energiaCompradaRedTotal_kWh'] += resultado.get('energiaCompradaRed_kWh', 0)
            datos['energiaExcedentesRedTotal_kWh'] += resultado.get('energiaExcedentesRed_kWh', 0)
        
        # Calcular costes económicos y construir objetos de resultados
        precio_energia_red = 0.15  # EUR/kWh - valor aproximado
        precio_compensacion = 0.06  # EUR/kWh - valor aproximado para compensación de excedentes
        
        resultados_participantes = []
        for id_participante, datos in datos_por_participante.items():
            # Calcular costes
            coste_energia_red = datos['energiaCompradaRedTotal_kWh'] * precio_energia_red
            compensacion_excedentes = datos['energiaExcedentesRedTotal_kWh'] * precio_compensacion
            coste_total = coste_energia_red - compensacion_excedentes
            
            # Calcular porcentaje de autoconsumo
            porcentaje_autoconsumo = 0
            if datos['consumoTotal_kWh'] > 0:
                porcentaje_autoconsumo = (datos['energiaAutoconsumidaTotal_kWh'] / datos['consumoTotal_kWh']) * 100
            
            # Construir objeto de resultado
            resultado = {
                'idSimulacion': self.simulacion_id,
                'idParticipante': id_participante,
                'consumoTotal_kWh': round(datos['consumoTotal_kWh'], 3),
                'energiaAutoconsumidaTotal_kWh': round(datos['energiaAutoconsumidaTotal_kWh'], 3),
                'energiaCompradaRedTotal_kWh': round(datos['energiaCompradaRedTotal_kWh'], 3),
                'energiaExcedentesRedTotal_kWh': round(datos['energiaExcedentesRedTotal_kWh'], 3),
                'porcentajeAutoconsumo': round(porcentaje_autoconsumo, 2),
                'costeEnergeticoTotal_euros': round(coste_total, 2)
            }
            resultados_participantes.append(resultado)
        
        logging.info(f"Resultados calculados para {len(resultados_participantes)} participantes")
        return resultados_participantes

    def _calcular_resultados_activos_gen(self, resultados_intervalo_activos):
        """
        Agrega los resultados por intervalo para cada activo de generación
        
        Args:
            resultados_intervalo_activos: Lista de resultados por intervalo para cada activo
            
        Returns:
            Lista de entidades ResultadoSimulacionActivoGeneracion con los resultados agregados
        """
        if not resultados_intervalo_activos:
            logging.warning("No hay datos de intervalos para calcular resultados de activos de generación")
            return []
        
        # Obtener la lista de activos de generación para la comunidad de la simulación actual
        simulacion = self.simulacion_repo.get_by_id(self.simulacion_id)
        activos_generacion = self.activo_gen_repo.get_by_comunidad(simulacion.idComunidadEnergetica)
        
        # Crear un diccionario para acceder rápidamente por ID
        activos_dict = {a.idActivoGeneracion: a for a in activos_generacion}
        
        # Organizar datos por activo
        datos_por_activo = {}
        for resultado in resultados_intervalo_activos:
            if not isinstance(resultado, dict):
                continue
                
            id_activo = resultado.get('idActivo')
            if not id_activo:
                continue
                
            if id_activo not in datos_por_activo:
                datos_por_activo[id_activo] = {
                    'energiaGeneradaTotal_kWh': 0,
                    'energiaUtilizadaTotal_kWh': 0,
                    'energiaExcedenteTotal_kWh': 0,
                    'horasProduccion': 0,
                    'potenciaMaxima_kW': 0
                }
            
            # Sumar datos del intervalo
            datos = datos_por_activo[id_activo]
            generacion = resultado.get('generacionTotal_kWh', 0)
            datos['energiaGeneradaTotal_kWh'] += generacion
            datos['energiaUtilizadaTotal_kWh'] += resultado.get('energiaUtilizada_kWh', 0)
            datos['energiaExcedenteTotal_kWh'] += resultado.get('energiaExcedente_kWh', 0)
            
            # Contar horas de producción y actualizar potencia máxima
            if generacion > 0.01:  # Considerar producción significativa (>10W)
                datos['horasProduccion'] += 1
                datos['potenciaMaxima_kW'] = max(datos['potenciaMaxima_kW'], generacion)
        
        # Calcular resultados finales y construir objetos
        resultados_activos_gen = []
        for id_activo, datos in datos_por_activo.items():
            # Calcular factores adicionales
            factor_capacidad = 0
            
            # Intentar recuperar la potencia nominal del activo del diccionario
            activo = activos_dict.get(id_activo)
            if activo and activo.potenciaNominal_kWp and activo.potenciaNominal_kWp > 0:
                # Factor de capacidad = Energía generada / (Potencia nominal * Horas totales)
                horas_totales = datos['horasProduccion'] or 1  # Evitar división por cero
                factor_capacidad = (datos['energiaGeneradaTotal_kWh'] / (activo.potenciaNominal_kWp * horas_totales)) * 100
            
            # Calcular eficiencia de utilización
            eficiencia_utilizacion = 0
            if datos['energiaGeneradaTotal_kWh'] > 0:
                eficiencia_utilizacion = (datos['energiaUtilizadaTotal_kWh'] / datos['energiaGeneradaTotal_kWh']) * 100
            
            # Construir objeto de resultado
            resultado = {
                'idSimulacion': self.simulacion_id,
                'idActivoGeneracion': id_activo,
                'energiaGeneradaTotal_kWh': round(datos['energiaGeneradaTotal_kWh'], 3),
                'energiaUtilizadaTotal_kWh': round(datos['energiaUtilizadaTotal_kWh'], 3),
                'energiaExcedenteTotal_kWh': round(datos['energiaExcedenteTotal_kWh'], 3),
                'factorCapacidad': round(factor_capacidad, 2),
                'eficienciaUtilizacion': round(eficiencia_utilizacion, 2),
                'horasProduccion': datos['horasProduccion'],
                'potenciaMaxima_kW': round(datos['potenciaMaxima_kW'], 3)
            }
            resultados_activos_gen.append(resultado)
        
        logging.info(f"Resultados calculados para {len(resultados_activos_gen)} activos de generación")
        return resultados_activos_gen

    def _calcular_resultados_activos_alm(self, resultados_intervalo_activos):
        """
        Agrega los resultados por intervalo para cada activo de almacenamiento
        
        Args:
            resultados_intervalo_activos: Lista de resultados por intervalo para cada activo
            
        Returns:
            Lista de entidades ResultadoSimulacionActivoAlmacenamiento con los resultados agregados
        """
        if not resultados_intervalo_activos:
            logging.warning("No hay datos de intervalos para calcular resultados de activos de almacenamiento")
            return []
        
        # Organizar datos por activo
        datos_por_activo = {}
        for resultado in resultados_intervalo_activos:
            if not isinstance(resultado, dict):
                continue
                
            id_activo = resultado.get('idActivo')
            if not id_activo:
                continue
                
            # Verificar si es un activo de almacenamiento
            if resultado.get('tipo_activo', '') != 'almacenamiento':
                continue
                
            if id_activo not in datos_por_activo:
                datos_por_activo[id_activo] = {
                    'energiaAlmacenadaTotal_kWh': 0,
                    'energiaLiberadaTotal_kWh': 0,
                    'ciclosCarga': 0,
                    'ciclosDescarga': 0,
                    'eficienciaAlmacenamiento': 0,
                    'estadoFinalCarga_pct': 0
                }
            
            # Sumar datos del intervalo
            datos = datos_por_activo[id_activo]
            energia_almacenada = resultado.get('energiaAlmacenada_kWh', 0)
            energia_liberada = resultado.get('energiaLiberada_kWh', 0)
            
            datos['energiaAlmacenadaTotal_kWh'] += energia_almacenada
            datos['energiaLiberadaTotal_kWh'] += energia_liberada
            
            # Contar ciclos de carga y descarga (cuando son significativos)
            if energia_almacenada > 0.01:  # >10Wh
                datos['ciclosCarga'] += 1
            if energia_liberada > 0.01:
                datos['ciclosDescarga'] += 1
                
            # Actualizar estado final de carga si está disponible
            if 'estadoCarga_pct' in resultado:
                datos['estadoFinalCarga_pct'] = resultado['estadoCarga_pct']
        
        # Calcular resultados finales y construir objetos
        resultados_activos_alm = []
        for id_activo, datos in datos_por_activo.items():
            # Calcular eficiencia de almacenamiento
            eficiencia = 0
            if datos['energiaAlmacenadaTotal_kWh'] > 0:
                eficiencia = (datos['energiaLiberadaTotal_kWh'] / datos['energiaAlmacenadaTotal_kWh']) * 100
                eficiencia = min(100, eficiencia)  # No permitir eficiencias > 100%
            
            # Construir objeto de resultado
            resultado = {
                'idSimulacion': self.simulacion_id,
                'idActivoAlmacenamiento': id_activo,
                'energiaAlmacenadaTotal_kWh': round(datos['energiaAlmacenadaTotal_kWh'], 3),
                'energiaLiberadaTotal_kWh': round(datos['energiaLiberadaTotal_kWh'], 3),
                'ciclosCarga': datos['ciclosCarga'],
                'ciclosDescarga': datos['ciclosDescarga'],
                'eficienciaAlmacenamiento': round(eficiencia, 2),
                'estadoFinalCarga_pct': round(datos['estadoFinalCarga_pct'], 2)
            }
            resultados_activos_alm.append(resultado)
        
        logging.info(f"Resultados calculados para {len(resultados_activos_alm)} activos de almacenamiento")
        return resultados_activos_alm

    def _aplicar_estrategia_intervalo(self, comunidad, participantes, gen_activos,
                                      consumo_int, estado_alm, contratos, coefs, intervalo):
        """
        Aplica la estrategia de reparto de energía según la configuración de la comunidad.
        
        Args:
            comunidad: Entidad de la comunidad energética
            participantes: Lista de participantes
            gen_activos: Diccionario de generación de activos {id_activo: generación_kWh}
            consumo_int: Diccionario de consumo {id_participante: consumo_kWh}
            estado_alm: Estado actual de almacenamiento
            contratos: Diccionario de contratos por participante
            coefs: Diccionario de coeficientes de reparto por participante
            intervalo: Timestamp del intervalo actual
            
        Returns:
            Tupla con (resultados del intervalo, estado actualizado de almacenamiento)
        """
        from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes
        from app.domain.entities.tipo_reparto import TipoReparto
        
        try:
            print(f"\n[DEBUG] Intervalo: {intervalo}")
            print(f"[DEBUG] Comunidad: {comunidad.nombre}")
            print(f"[DEBUG] Participantes: {len(participantes)}")
            print(f"[DEBUG] Activos generación: {len(gen_activos)} - Generación total: {sum(gen_activos.values()):.4f} kWh")
            print(f"[DEBUG] Consumos: {consumo_int}")
            
            logging.debug(f"Aplicando estrategia para intervalo: {intervalo}")
            
            # Valores por defecto para prevenir errores
            resultados_participantes = []
            resultados_activos = []
            resultados_activos_alm = []
            
            # Calcular valores agregados
            generacion_total = sum(gen_activos.values())
            consumo_total = sum(consumo_int.get(p.idParticipante, 0) for p in participantes)
            
            print(f"[DEBUG] Generación total: {generacion_total:.4f} kWh, Consumo total: {consumo_total:.4f} kWh")
            print(f"[DEBUG] Balance energético: {generacion_total - consumo_total:.4f} kWh")
            logging.debug(f"Generación total: {generacion_total} kWh, Consumo total: {consumo_total} kWh")
            
            # 1. Determinar tipo de estrategia de excedentes de la comunidad
            estrategia = comunidad.tipoEstrategiaExcedentes
            if not estrategia:
                estrategia = TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_INTERNA
                logging.warning(f"No se definió estrategia de excedentes. Usando por defecto: {estrategia.value}")
            
            print(f"[DEBUG] Estrategia de excedentes: {estrategia.value}")
            
            # 2. Determinar reparto de generación entre participantes según coeficientes
            energia_asignada = {}  # {id_participante: energía_asignada_kWh}
            
            # Determinar tipo de reparto y asignar energía según coeficientes
            if generacion_total > 0:
                # Reparto por coeficientes según tipo configurado en la comunidad
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    coeficiente = self._obtener_coeficiente_reparto(coefs.get(id_p, []), intervalo)
                    
                    # Si no hay coeficiente, usar reparto proporcional al consumo
                    if coeficiente is None:
                        if consumo_total > 0:
                            coeficiente = consumo / consumo_total
                        else:
                            coeficiente = 1.0 / len(participantes)
                    
                    # Asignar energía según coeficiente (nunca más que su consumo en caso de sin excedentes)
                    energia_asignada[id_p] = generacion_total * coeficiente
                    print(f"[DEBUG] Participante {id_p}: Consumo={consumo:.4f} kWh, Coef={coeficiente:.4f}, Asignado={energia_asignada[id_p]:.4f} kWh")
                    logging.debug(f"Participante {id_p}: Coef={coeficiente}, Asignado={energia_asignada[id_p]} kWh")
            
            # 3. Aplicar estrategia según tipo definido
            excedentes_red = 0  # Energía exportada a la red
            energia_utilizacion_activo = {}  # Seguimiento de cuánto se utiliza de cada activo
            
            for id_activo in gen_activos:
                energia_utilizacion_activo[id_activo] = 0
            
            print(f"[DEBUG] Aplicando estrategia: {estrategia.value}")
            
            # Procesar según tipo de estrategia
            if estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
                print("[DEBUG] Procesando estrategia: INDIVIDUAL_SIN_EXCEDENTES")
                # Código 31: Individual sin excedentes
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    autoconsumo = min(consumo, energia_asignada.get(id_p, 0))
                    consumo_red = consumo - autoconsumo
                    
                    # En este caso, limitamos la generación para evitar excedentes
                    for id_activo, generacion in gen_activos.items():
                        if generacion > 0:
                            # Si hay más de un activo, esto es una simplificación
                            energia_utilizacion_activo[id_activo] = min(generacion, consumo)
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': 0  # Sin excedentes
                    })
            
            elif estrategia == TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
                print("[DEBUG] Procesando estrategia: COLECTIVO_SIN_EXCEDENTES")
                # Código 32: Colectivo sin excedentes
                energia_disponible = generacion_total
                
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    autoconsumo = min(consumo, energia_asignada.get(id_p, 0))
                    consumo_red = consumo - autoconsumo
                    
                    # Restar energía consumida del disponible total
                    energia_disponible -= autoconsumo
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': 0  # Sin excedentes
                    })
                
                # Proporcionar utilización por activo (reparto proporcional simplificado)
                if generacion_total > 0:
                    energia_utilizada_total = generacion_total - energia_disponible
                    for id_activo, generacion in gen_activos.items():
                        if generacion > 0:
                            energia_utilizacion_activo[id_activo] = (generacion / generacion_total) * energia_utilizada_total
            
            elif estrategia == TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES_COMPENSACION_INTERNA:
                print("[DEBUG] Procesando estrategia: COLECTIVO_SIN_EXCEDENTES_COMPENSACION_INTERNA")
                # Código 33: Colectivo con acuerdo de compensación interna
                energia_disponible = generacion_total
                
                # Primera pasada: asignar según coeficientes
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    autoconsumo = min(consumo, energia_asignada.get(id_p, 0))
                    consumo_red = consumo - autoconsumo
                    energia_disponible -= autoconsumo
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': 0  # Sin excedentes
                    })
                
                # Segunda pasada: compensación interna de excedentes de unos con déficit de otros
                if energia_disponible > 0:
                    # Identificar participantes con capacidad para más energía
                    participantes_deficitarios = []
                    for p in participantes:
                        id_p = p.idParticipante
                        consumo = consumo_int.get(id_p, 0)
                        autoconsumo_actual = next((r['energiaAutoconsumida_kWh'] for r in resultados_participantes 
                                               if r['idParticipante'] == id_p), 0)
                        
                        deficit = consumo - autoconsumo_actual
                        if deficit > 0:
                            participantes_deficitarios.append({
                                'id': id_p,
                                'deficit': deficit
                            })
                    
                    # Ordenar por déficit para asignar energía
                    participantes_deficitarios.sort(key=lambda x: x['deficit'], reverse=True)
                    
                    for p_def in participantes_deficitarios:
                        if energia_disponible <= 0:
                            break
                            
                        id_p = p_def['id']
                        deficit = p_def['deficit']
                        energia_adicional = min(deficit, energia_disponible)
                        
                        # Actualizar resultado del participante
                        for res in resultados_participantes:
                            if res['idParticipante'] == id_p:
                                res['energiaAutoconsumida_kWh'] += energia_adicional
                                res['energiaDesdeRed_kWh'] -= energia_adicional
                                break
                        
                        energia_disponible -= energia_adicional
                
                # Proporcionar utilización por activo (reparto proporcional simplificado)
                if generacion_total > 0:
                    energia_utilizada_total = generacion_total - energia_disponible
                    for id_activo, generacion in gen_activos.items():
                        if generacion > 0:
                            energia_utilizacion_activo[id_activo] = (generacion / generacion_total) * energia_utilizada_total
            
            elif estrategia == TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
                print("[DEBUG] Procesando estrategia: INDIVIDUAL_EXCEDENTES_COMPENSACION")
                # Código 41: Individual con excedentes y compensación
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    asignado = energia_asignada.get(id_p, 0)
                    
                    autoconsumo = min(consumo, asignado)
                    excedente = max(0, asignado - autoconsumo)
                    consumo_red = consumo - autoconsumo
                    
                    # El excedente se vierte a la red para compensación
                    excedentes_red += excedente
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': excedente
                    })
                
                # Asignar utilización por activo
                for id_activo, generacion in gen_activos.items():
                    energia_utilizacion_activo[id_activo] = min(generacion, consumo_total)
            
            elif estrategia in [TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_INTERNA, 
                               TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA]:
                print("[DEBUG] Procesando estrategia: COLECTIVO_EXCEDENTES_COMPENSACION")
                # Código 42 y 43: Colectivo con excedentes y compensación (interna o externa)
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    asignado = energia_asignada.get(id_p, 0)
                    
                    autoconsumo = min(consumo, asignado)
                    excedente_individual = max(0, asignado - autoconsumo)
                    consumo_red = consumo - autoconsumo
                    
                    # El excedente total se acumula para repartir según coeficientes
                    excedentes_red += excedente_individual
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': 0  # Inicialmente 0, se actualizará
                    })
                
                # Repartir los excedentes según coeficientes
                if excedentes_red > 0:
                    for p in participantes:
                        id_p = p.idParticipante
                        coeficiente = self._obtener_coeficiente_reparto(coefs.get(id_p, []), intervalo)
                        
                        # Si no hay coeficiente, usar reparto equitativo
                        if coeficiente is None:
                            coeficiente = 1.0 / len(participantes)
                        
                        # Actualizar excedentes asignados a este participante
                        excedente_asignado = excedentes_red * coeficiente
                        
                        for res in resultados_participantes:
                            if res['idParticipante'] == id_p:
                                res['energiaExcedentesRed_kWh'] = excedente_asignado
                                break
                
                # Asignar utilización por activo (toda la generación se usa o exporta)
                for id_activo, generacion in gen_activos.items():
                    energia_utilizacion_activo[id_activo] = generacion
            
            else:
                print("[DEBUG] Estrategia no reconocida, usando comportamiento por defecto")
                logging.warning(f"Estrategia de excedentes no reconocida: {estrategia}. "
                               f"Usando comportamiento por defecto.")
                # Aplicar comportamiento por defecto
                for p in participantes:
                    id_p = p.idParticipante
                    consumo = consumo_int.get(id_p, 0)
                    asignado = energia_asignada.get(id_p, 0)
                    
                    autoconsumo = min(consumo, asignado)
                    consumo_red = consumo - autoconsumo
                    
                    resultados_participantes.append({
                        'idParticipante': id_p,
                        'timestamp': intervalo,
                        'consumoEnergia_kWh': consumo,
                        'energiaAutoconsumida_kWh': autoconsumo,
                        'energiaDesdeRed_kWh': consumo_red,
                        'excedenteVertidoCompensado_kWh': 0
                    })
            
            # 4. Gestión de almacenamiento (si existe)
            print(f"[DEBUG] Gestionando almacenamiento: Excedentes={excedentes_red:.4f} kWh")
            excedentes_utilizables = excedentes_red
            excedentes_almacenados = 0
            energia_descargada = 0
            
            if activos_alm := [a for a in self.activo_alm_repo.get_by_comunidad(comunidad.idComunidadEnergetica) 
                              if a.idActivoAlmacenamiento in estado_alm]:
                print(f"[DEBUG] Activos almacenamiento disponibles: {len(activos_alm)}")
                for activo in activos_alm:
                    id_alm = activo.idActivoAlmacenamiento
                    capacidad_kWh = activo.capacidadNominal_kWh
                    soc_actual = estado_alm[id_alm]['soc_kwh']
                    
                    print(f"[DEBUG] Almacenamiento {id_alm}: SOC={soc_actual:.4f} kWh / {capacidad_kWh:.4f} kWh ({(soc_actual/capacidad_kWh*100):.2f}%)")
                    
                    # Verificar si hay capacidad disponible para almacenar excedentes
                    capacidad_disponible = capacidad_kWh - soc_actual
                    
                    if excedentes_utilizables > 0 and capacidad_disponible > 0:
                        # Cargar la batería con excedentes
                        energia_a_cargar = min(excedentes_utilizables, capacidad_disponible)
                        eficiencia_carga = activo.eficienciaCarga / 100 if activo.eficienciaCarga else 0.9
                        
                        energia_almacenada = energia_a_cargar * eficiencia_carga
                        estado_alm[id_alm]['soc_kwh'] += energia_almacenada
                        
                        print(f"[DEBUG] Cargando almacenamiento {id_alm}: +{energia_almacenada:.4f} kWh (efic={eficiencia_carga:.2f})")
                        
                        excedentes_utilizables -= energia_a_cargar
                        excedentes_almacenados += energia_a_cargar
                        
                        resultados_activos_alm.append({
                            'idActivo': id_alm,
                            'tipo_activo': 'almacenamiento',
                            'timestamp': intervalo,
                            'energiaAlmacenada_kWh': energia_almacenada,
                            'energiaLiberada_kWh': 0,
                            'estadoCarga_pct': (estado_alm[id_alm]['soc_kwh'] / capacidad_kWh) * 100
                        })
                    
                    # En este intervalo, si hay déficit, también podríamos descargar la batería
                    deficit_total = consumo_total - sum(r['energiaAutoconsumida_kWh'] for r in resultados_participantes)
                    if deficit_total > 0 and soc_actual > 0:
                        print(f"[DEBUG] Déficit detectado: {deficit_total:.4f} kWh con SOC={soc_actual:.4f} kWh")
                        
                        # La energía disponible para descargar tiene en cuenta profundidad de descarga
                        profundidad_max = activo.profundidadDescargaMax / 100 if activo.profundidadDescargaMax else 0.8
                        energia_disponible = min(soc_actual, profundidad_max * capacidad_kWh)
                        eficiencia_descarga = activo.eficienciaDescarga / 100 if activo.eficienciaDescarga else 0.9
                        
                        energia_a_descargar = min(deficit_total / eficiencia_descarga, energia_disponible)
                        energia_descargada = energia_a_descargar * eficiencia_descarga
                        
                        print(f"[DEBUG] Descargando almacenamiento {id_alm}: -{energia_a_descargar:.4f} kWh -> {energia_descargada:.4f} kWh (efic={eficiencia_descarga:.2f})")
                        
                        estado_alm[id_alm]['soc_kwh'] -= energia_a_descargar
                        
                        # Actualizar o agregar entrada de resultados para este almacenamiento
                        alm_entry_found = False
                        for res in resultados_activos_alm:
                            if res['idActivo'] == id_alm:
                                res['energiaLiberada_kWh'] = energia_descargada
                                res['estadoCarga_pct'] = (estado_alm[id_alm]['soc_kwh'] / capacidad_kWh) * 100
                                alm_entry_found = True
                                break
                        
                        if not alm_entry_found:
                            resultados_activos_alm.append({
                                'idActivo': id_alm,
                                'tipo_activo': 'almacenamiento',
                                'timestamp': intervalo,
                                'energiaAlmacenada_kWh': 0,
                                'energiaLiberada_kWh': energia_descargada,
                                'estadoCarga_pct': (estado_alm[id_alm]['soc_kwh'] / capacidad_kWh) * 100
                            })
                    
            
            return {'participantes': resultados_participantes, 'activos': resultados_activos}, estado_alm
        except Exception as e:
            logging.error(f"Error en aplicación de estrategia: {str(e)}")
            # Devolver estructuras vacías pero válidas para evitar errores de desempaquetado
            return {'participantes': [], 'activos': []}, estado_alm
            
    def _obtener_coeficiente_reparto(self, coeficientes, timestamp):
        """
        Obtiene el coeficiente de reparto adecuado según el timestamp y tipo
        
        Args:
            coeficientes: Lista de coeficientes de reparto para un participante
            timestamp: Momento actual para el que se requiere el coeficiente
            
        Returns:
            float: Valor del coeficiente o None si no se encuentra
        """
        if not coeficientes:
            return None
            
        from app.domain.entities.tipo_reparto import TipoReparto
        
        # Buscar el coeficiente adecuado según tipo
        for coef in coeficientes:
            # Para reparto fijo, siempre se usa el mismo valor
            if coef.tipoReparto == TipoReparto.REPARTO_FIJO.value:
                return coef.valor
                
            # Para reparto programado, verificar si aplica según horario
            elif coef.tipoReparto == TipoReparto.REPARTO_PROGRAMADO.value:
                # Verificar si el timestamp está en el rango horario del coeficiente
                hora_actual = timestamp.hour if hasattr(timestamp, 'hour') else 12
                if coef.horaInicio <= hora_actual < coef.horaFin:
                    return coef.valor
                    
            # Para reparto dinámico (si se implementa en el futuro)
            elif coef.tipoReparto == TipoReparto.REPARTO_DINAMICO.value:
                # Implementación futura: podría depender de consumos históricos o previsiones
                pass
                
        return None
        
    def _distribuir_energia_almacenada(self, resultados_participantes, energia_disponible):
        """
        Distribuye la energía descargada del almacenamiento entre participantes con déficit
        
        Args:
            resultados_participantes: Lista de resultados de participantes del intervalo
            energia_disponible: Energía total disponible para distribuir (kWh)
        """
        if energia_disponible <= 0:
            return
            
        # Identificar participantes con déficit (compran de la red)
        participantes_deficitarios = []
        for res in resultados_participantes:
            if res['energiaDesdeRed_kWh'] > 0:
                participantes_deficitarios.append({
                    'id': res['idParticipante'],
                    'deficit': res['energiaDesdeRed_kWh']
                })
                
        if not participantes_deficitarios:
            return
            
        # Calcular déficit total
        deficit_total = sum(p['deficit'] for p in participantes_deficitarios)
        
        # Si hay más energía disponible que déficit, limitar
        energia_a_repartir = min(energia_disponible, deficit_total)
        
        # Distribuir proporcionalmente al déficit
        for res in resultados_participantes:
            for p in participantes_deficitarios:
                if res['idParticipante'] == p['id']:
                    # Calcular proporción del déficit
                    proporcion = p['deficit'] / deficit_total if deficit_total > 0 else 0
                    energia_asignada = energia_a_repartir * proporcion
                    
                    # Actualizar resultado del participante
                    res['energiaAutoconsumida_kWh'] += energia_asignada
                    res['energiaDesdeRed_kWh'] -= energia_asignada
                    break

    def _guardar_cache_generacion_json(self):
        """
        Guarda la caché de generación en un archivo JSON para depuración
        """
        import json
        import os
        from datetime import datetime
        
        try:
            # Convertir las claves datetime a string para que sean serializables
            cache_serializable = {}
            for id_activo, datos in self._cache_generacion_pv.items():
                cache_serializable[str(id_activo)] = {
                    str(timestamp): valor 
                    for timestamp, valor in datos.items()
                }
            
            # Crear nombre de archivo con timestamp para evitar sobreescrituras
            timestamp_actual = datetime.now().strftime("%Y%m%d_%H%M%S")
            nombre_archivo = os.path.join(self.debug_dir, f"generacion_cache_{timestamp_actual}.json")
            
            with open(nombre_archivo, 'w') as archivo:
                json.dump(cache_serializable, archivo, indent=2)
                
            print(f"  ✓ Caché de generación guardada en: {nombre_archivo}")
            return nombre_archivo
        
        except Exception as e:
            print(f"  ✗ Error al guardar caché de generación: {str(e)}")
            logging.error(f"Error al guardar caché de generación: {str(e)}")
            return None

