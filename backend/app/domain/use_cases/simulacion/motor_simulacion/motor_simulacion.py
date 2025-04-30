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

    def ejecutar_simulacion(self, simulacion_id: int):
        """
        Runs the simulation for the given simulation ID.
        Args:
            simulacion_id: The ID of the simulation to run.
        """
        print(f"Iniciando ejecución de simulación ID: {simulacion_id}")

        try:
            # Paso 1: cargar simulación y configuración
            simulacion = self.simulacion_repo.get_by_id(simulacion_id)
            comunidad = self.comunidad_repo.get_by_id(simulacion.idComunidadEnergetica)
            participantes = self.participante_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            activos_gen = self.activo_gen_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            activos_alm = self.activo_alm_repo.get_by_comunidad(comunidad.idComunidadEnergetica)
            contratos = {p.idParticipante: self.contrato_repo.get_by_participante(p.idParticipante) for p in participantes}
            coeficientes = {p.idParticipante: self.coeficiente_repo.get_by_participante(p.idParticipante) for p in participantes}

            # Paso 2: actualizar estado a 'Ejecutando'
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.EJECUTANDO.value)
            self.db_session.commit()

            # Paso 3: obtener datos de consumo y ambientales
            datos_consumo = self.registro_consumo_repo.get_range_for_participantes(
                [p.idParticipante for p in participantes],
                simulacion.fechaInicio, simulacion.fechaFin
            )

            # Obtener datos ambientales utilizando PVGIS
            datos_ambientales = self.datos_ambientales_api_repo.get_datos_ambientales(
                comunidad.latitud, comunidad.longitud, simulacion.fechaInicio, simulacion.fechaFin
            )
            
            # Asignar el ID de simulación a los datos ambientales obtenidos
            for dato in datos_ambientales:
                dato.idSimulacion = simulacion_id
            
            # No guardamos los datos ahora, los guardaremos si la simulación termina correctamente
            
            consumo_por_intervalo = self._organize_consumo_by_interval(datos_consumo)
            ambiental_por_intervalo = self._organize_ambiental_by_interval(datos_ambientales)
            
            # Precalcular la generación solar para todos los activos fotovoltaicos
            self._precalcular_generacion_fotovoltaica(
                activos_gen, 
                comunidad.latitud, comunidad.longitud,
                simulacion.fechaInicio, simulacion.fechaFin
            )

            # Paso 4: inicializar estado interno
            estado_almacenamiento = {
                alm.idActivoAlmacenamiento: {'soc_kwh': 0.0} for alm in activos_alm
            }
            resultados_intervalo_participantes = []
            resultados_intervalo_activos = []

            # Paso 5: bucle de simulación
            current_time = simulacion.fechaInicio
            intervalo = timedelta(minutes=simulacion.tiempo_medicion)
            while current_time < simulacion.fechaFin:
                datos_amb = ambiental_por_intervalo.get(current_time, {})
                consumo_int = consumo_por_intervalo.get(current_time, {})
                # generación y consumo
                gen_activos = {a.idActivoGeneracion: self._calcular_generacion_activo(a, datos_amb, current_time)
                               for a in activos_gen}
                consumo_total = sum(consumo_int.values())
                gen_total = sum(gen_activos.values())
                # almacenamiento y reparto según estrategia
                resultados_i, estado_almacenamiento = self._aplicar_estrategia_intervalo(
                    comunidad, participantes, gen_activos, consumo_int,
                    estado_almacenamiento, contratos, coeficientes, intervalo
                )
                resultados_intervalo_participantes.extend(resultados_i['participantes'])
                resultados_intervalo_activos.extend(resultados_i['activos'])
                current_time += intervalo

            # Paso 6: calcular resultados globales
            resultados_globales = self._calcular_resultados_globales(resultados_intervalo_participantes,
                                                                    resultados_intervalo_activos)
            resultados_part = self._calcular_resultados_participantes(resultados_intervalo_participantes)
            # ... similares para activos gen y alm ...

            # Paso 7: persistir resultados
            self.resultado_simulacion_repo.create(resultados_globales)
            self.resultado_participante_repo.create_bulk(resultados_part)
            
            # Guardar los datos ambientales después de que la simulación se ha completado con éxito
            self.datos_ambientales_repo.create_bulk(datos_ambientales)
            # ... bulk de activos y datos de intervalo ...
            self.db_session.commit()

            # Paso 8: actualizar estado a 'Completada'
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.COMPLETADA.value)
            self.db_session.commit()

        except Exception as e:
            logging.error(f"Error en la simulación: {str(e)}")
            self.db_session.rollback()
            self.simulacion_repo.update_estado(simulacion_id, EstadoSimulacion.FALLIDA.value)
            self.db_session.commit()
            raise

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

    # Helper methods (to be implemented)
    def _organize_consumo_by_interval(self, datos_consumo):
        result = {}
        for registro in datos_consumo:
            # Initialize the dictionary for this timestamp if it doesn't exist yet
            if registro.timestamp not in result:
                result[registro.timestamp] = {}
                
            # Add the consumption for this participant at this timestamp
            result[registro.timestamp][registro.idParticipante] = registro.consumoEnergia
            
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
                if timestamp in generacion_cache:
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

    def _calcular_resultados_globales(self, *args, **kwargs):
        # Aggregates interval data to compute overall simulation results
        pass

    def _calcular_resultados_participantes(self, *args, **kwargs):
        # Aggregates interval data for each participant
        pass

    def _calcular_resultados_activos_gen(self, *args, **kwargs):
        # Aggregates interval data for each generation asset
        pass

    def _calcular_resultados_activos_alm(self, *args, **kwargs):
        # Aggregates interval data for each storage asset
        pass

    def _aplicar_estrategia_intervalo(self, comunidad, participantes, gen_activos,
                                      consumo_int, estado_alm, contratos, coefs, intervalo):
        # Implementar lógica de almacenamiento y reparto según comunidad.tipoEstrategiaExcedentes
        # Debe devolver dict con listas 'participantes' y 'activos', y el estado_alm actualizado
        pass

