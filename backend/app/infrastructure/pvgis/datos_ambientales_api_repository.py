import requests
import logging
import time
from typing import List, Dict, Any, Optional, Union
from datetime import datetime, date, timezone # Import timezone for UTC handling

# Asumiendo que estas clases están definidas en otra parte de tu aplicación
# from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
# from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository

# -------- Inicio: Clases Simuladas (SOLO PARA EJECUCIÓN INDEPENDIENTE) --------
# Si ejecutas este código como parte de tu aplicación, elimina o comenta esta sección
# y asegúrate de importar las clases reales desde 'app.domain...'

class DatosAmbientalesRepository: # Clase base simulada
    def get_datos_ambientales(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date]) -> List['DatosAmbientalesEntity']:
        raise NotImplementedError
    def get_generacion_fotovoltaica(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date],
                                   peak_power_kwp: float, angle: float, aspect: float,
                                   loss: float = 14.0, tech: str = 'crystSi') -> Dict[datetime, float]:
        raise NotImplementedError

# Entidad simulada (ajústala a tu definición real si es diferente)
class DatosAmbientalesEntity:
    def __init__(self, timestamp: datetime, fuenteDatos: str,
                 radiacionGlobalHoriz_Wh_m2: Optional[float] = None,
                 temperaturaAmbiente_C: Optional[float] = None,
                 velocidadViento_m_s: Optional[float] = None,
                 idRegistro: Optional[int] = None): # Añadido idRegistro opcional
        self.idRegistro = idRegistro
        self.timestamp = timestamp
        self.fuenteDatos = fuenteDatos
        self.radiacionGlobalHoriz_Wh_m2 = radiacionGlobalHoriz_Wh_m2
        self.temperaturaAmbiente_C = temperaturaAmbiente_C
        self.velocidadViento_m_s = velocidadViento_m_s

    def __repr__(self):
        return (f"DatosAmbientalesEntity(timestamp={self.timestamp.isoformat()}, "
                f"GHI={self.radiacionGlobalHoriz_Wh_m2}, T={self.temperaturaAmbiente_C}, "
                f"Wind={self.velocidadViento_m_s})")

# -------- Fin: Clases Simuladas --------


# Configuración básica de logging (si no está configurada globalmente)
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


class DatosAmbientalesApiRepository(DatosAmbientalesRepository):
    """
    Implementación del repositorio de datos ambientales que usa la API de PVGIS v5.3
    para obtener tanto datos ambientales como datos de generación fotovoltaica.
    """
    # --- Constantes ---
    PVGIS_API_URL = "https://re.jrc.ec.europa.eu/api/v5_3/seriescalc"
    DEFAULT_TIMEOUT = 180  # Segundos
    MAX_RETRIES = 3
    INITIAL_RETRY_DELAY = 5 # Segundos

    def get_datos_ambientales(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date]) -> List[DatosAmbientalesEntity]:
        """
        Obtiene datos ambientales horarios (radiación GHI, temperatura, viento) de la API de PVGIS.

        Args:
            lat: Latitud en grados decimales.
            lon: Longitud en grados decimales.
            start_date: Fecha/hora de inicio del período deseado.
            end_date: Fecha/hora de fin del período deseado.

        Returns:
            Lista de entidades DatosAmbientalesEntity para el período solicitado.
        """
        start_date_dt = self._ensure_datetime_utc(start_date, start_of_day=True)
        end_date_dt = self._ensure_datetime_utc(end_date, start_of_day=False) # Fin del día para incluir todo

        logging.info(f"Solicitando datos ambientales PVGIS para lat={lat}, lon={lon}, "
                     f"periodo=[{start_date_dt.isoformat()}, {end_date_dt.isoformat()}]")

        # Obtener datos de PVGIS (años completos necesarios)
        # Asegurarse de que pv_calculation=False implícitamente
        pvgis_data = self._request_pvgis_data(
            lat=lat, lon=lon,
            start_year=start_date_dt.year,
            end_year=end_date_dt.year,
            # pv_calculation=False (es el default de _request_pvgis_data)
            include_components=True # Necesario para G(h), T2m, WS10m
        )

        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error(f"No se pudieron obtener datos horarios válidos de PVGIS para lat={lat}, lon={lon}")
            return []

        logging.info(f"✓ PVGIS: Respuesta horaria recibida para lat={lat}, lon={lon}.")

        # Procesar y filtrar los datos horarios
        hourly_data = pvgis_data['outputs']['hourly']
        resultados: List[DatosAmbientalesEntity] = []

        for record in hourly_data:
            ts = self._parse_pvgis_timestamp(record.get('time'))
            if not ts:
                logging.warning(f"Saltando registro con timestamp inválido: {record.get('time')}")
                continue

            # Filtrar por el rango de datetime exacto solicitado
            if start_date_dt <= ts <= end_date_dt:
                try:
                    # Extraer datos ambientales, usando defaults numéricos si faltan
                    # PVGIS devuelve G(h) en W/m2, no Wh/m2. Asumimos que la entidad espera Wh/m2
                    # y que el valor representa la irradiancia *media* durante la hora.
                    # Energía = Potencia Media * Tiempo. Aquí Tiempo = 1 hora.
                    # Entonces, GHI (Wh/m2) = G(h) (W/m2) * 1 h
                    ghi_wh_m2 = float(record.get('G(h)', 0.0)) # Valor directo si se interpreta como energía en la hora

                    temp_c = float(record.get('T2m', 20.0))  # Default 20°C
                    wind_ms = float(record.get('WS10m', 0.0)) # Default 0 m/s

                    resultados.append(DatosAmbientalesEntity(
                        idRegistro=None, # Se asignará al guardar en BD si procede
                        timestamp=ts,
                        fuenteDatos="PVGIS",
                        radiacionGlobalHoriz_Wh_m2=ghi_wh_m2,
                        temperaturaAmbiente_C=temp_c,
                        velocidadViento_m_s=wind_ms
                    ))
                except (ValueError, TypeError) as e:
                    logging.error(f"Error al convertir datos en registro PVGIS ({ts}): {e}. Registro: {record}")
                except Exception as e:
                    logging.error(f"Error inesperado procesando registro PVGIS ({ts}): {e}")
                    logging.debug(f"Datos del registro con error: {record}")

        logging.info(f"✓ PVGIS: Extraídos {len(resultados)} registros de datos ambientales para el período solicitado.")
        return resultados

    def get_generacion_fotovoltaica(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date],
                                   peak_power_kwp: float, angle: float, aspect: float,
                                   loss: float = 14.0, tech: str = 'crystSi') -> Dict[datetime, float]:
        """
        Obtiene la generación fotovoltaica horaria estimada (en kWh) de la API de PVGIS.

        Args:
            lat: Latitud en grados decimales.
            lon: Longitud en grados decimales.
            start_date: Fecha/hora de inicio del período deseado.
            end_date: Fecha/hora de fin del período deseado.
            peak_power_kwp: Potencia nominal del sistema en kWp.
            angle: Ángulo de inclinación (grados).
            aspect: Ángulo de azimut (grados, 0=Sur, -90=Este, 90=Oeste).
            loss: Pérdidas del sistema (porcentaje).
            tech: Tecnología del panel ('crystSi', 'CIS', 'CdTe', 'Unknown').

        Returns:
            Diccionario que mapea timestamp (datetime UTC) a generación estimada en kWh para esa hora.
        """
        start_date_dt = self._ensure_datetime_utc(start_date, start_of_day=True)
        end_date_dt = self._ensure_datetime_utc(end_date, start_of_day=False)

        logging.info(f"Solicitando generación PV estimada de PVGIS para lat={lat}, lon={lon}, "
                     f"periodo=[{start_date_dt.isoformat()}, {end_date_dt.isoformat()}], "
                     f"P={peak_power_kwp}kWp, angle={angle}, aspect={aspect}, loss={loss}%")

        # Obtener datos de PVGIS con cálculo PV activado
        pvgis_data = self._request_pvgis_data(
            lat=lat, lon=lon,
            start_year=start_date_dt.year,
            end_year=end_date_dt.year,
            pv_calculation=True, # <-- Activar cálculo PV
            peak_power=peak_power_kwp,
            angle=angle,
            aspect=aspect,
            loss=loss,
            pv_tech=tech,
            include_components=False # No necesitamos componentes aquí si solo queremos 'P'
        )

        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error(f"No se pudieron obtener datos horarios válidos de generación PV de PVGIS para lat={lat}, lon={lon}")
            return {}

        logging.info(f"✓ PVGIS: Respuesta horaria recibida para generación PV en lat={lat}, lon={lon}.")

        # Procesar y filtrar los datos horarios
        hourly_data = pvgis_data['outputs']['hourly']
        resultados: Dict[datetime, float] = {}

        for record in hourly_data:
            ts = self._parse_pvgis_timestamp(record.get('time'))
            if not ts:
                logging.warning(f"Saltando registro de generación con timestamp inválido: {record.get('time')}")
                continue

            # Filtrar por el rango de datetime exacto solicitado
            if start_date_dt <= ts <= end_date_dt:
                try:
                    # 'P' es la potencia generada en W (promedio durante la hora)
                    potencia_w = float(record.get('P', 0.0))
                    # Energía (kWh) = Potencia (W) * 1 (h) / 1000 (W/kW)
                    energia_kwh = potencia_w / 1000.0

                    resultados[ts] = energia_kwh
                except (ValueError, TypeError) as e:
                     logging.error(f"Error al convertir potencia en registro PV ({ts}): {e}. Registro: {record}")
                except Exception as e:
                    logging.error(f"Error inesperado procesando registro de generación PV ({ts}): {e}")
                    logging.debug(f"Datos del registro de generación con error: {record}")

        logging.info(f"✓ PVGIS: Extraídas {len(resultados)} horas de generación PV estimada para el período solicitado.")
        return resultados

    def _ensure_datetime_utc(self, date_obj: Union[datetime, date], start_of_day: bool = True) -> datetime:
        """
        Asegura que el objeto sea un datetime y lo establece en UTC.
        Si es solo date, lo convierte a datetime al inicio o fin del día en UTC.
        """
        dt: datetime
        if isinstance(date_obj, datetime):
            dt = date_obj
        elif isinstance(date_obj, date):
            # Convertir date a datetime
            if start_of_day:
                dt = datetime.combine(date_obj, datetime.min.time())
            else:
                # Para end_date, usar el final del día para incluir todas las horas
                dt = datetime.combine(date_obj, datetime.max.time().replace(microsecond=0))
        else:
            # Fallback o error si no es ni date ni datetime
            logging.error(f"Tipo de fecha inválido: {type(date_obj)}. Usando fallback.")
            # Podrías lanzar un error aquí: raise TypeError("Se esperaba date o datetime")
            dt = datetime.now(timezone.utc) # Fallback muy genérico

        # Asegurar que sea consciente de la zona horaria y convertir a UTC si es necesario
        if dt.tzinfo is None:
            # Asumir que es hora local si no tiene timezone (¡Ojo! esto puede ser incorrecto si la entrada no es local)
            # Sería mejor requerir datetimes conscientes de zona horaria en la entrada.
            # Por ahora, lo marcamos como UTC si es naive, asumiendo que las entradas sin tz son UTC.
            # O podríamos intentar localizarlo a la zona local y luego convertir a UTC.
            # Opción segura: Asumir UTC si es naive.
            dt = dt.replace(tzinfo=timezone.utc)
            logging.debug(f"Timestamp naive convertido a UTC (asumido): {dt.isoformat()}")
        elif dt.tzinfo != timezone.utc:
            dt = dt.astimezone(timezone.utc)
            logging.debug(f"Timestamp convertido a UTC: {dt.isoformat()}")

        return dt


    def _parse_pvgis_timestamp(self, ts_str: Optional[str]) -> Optional[datetime]:
        """
        Convierte el string de timestamp de PVGIS (esperado: 'YYYYMMDD:HHMM') a un objeto datetime UTC.
        """
        if not ts_str:
            return None

        try:
            # El formato esperado es como '20220101:0000'
            # Usar strptime para parsear directamente
            # PVGIS devuelve tiempos en UTC. Lo hacemos consciente de UTC.
            dt = datetime.strptime(ts_str, "%Y%m%d:%H%M").replace(tzinfo=timezone.utc)
            return dt
        except ValueError:
            # Intentar limpiar si el formato es ligeramente diferente (ej. sin ':')
            ts_clean = ''.join(filter(str.isdigit, ts_str))
            if len(ts_clean) == 12: # YYYYMMDDHHMM
                try:
                    dt = datetime.strptime(ts_clean, "%Y%m%d%H%M").replace(tzinfo=timezone.utc)
                    logging.debug(f"Timestamp PVGIS parseado tras limpieza: '{ts_str}' -> {dt.isoformat()}")
                    return dt
                except ValueError:
                    pass # Falla también tras limpiar

            logging.warning(f"No se pudo parsear el timestamp PVGIS con formatos conocidos: '{ts_str}'")
            return None
        except Exception as e:
            logging.error(f"Error inesperado al parsear timestamp PVGIS '{ts_str}': {e}")
            return None

    def _request_pvgis_data(self, lat: float, lon: float, start_year: int, end_year: int,
                           pv_calculation: bool = False, peak_power: Optional[float] = None,
                           angle: Optional[float] = None, aspect: Optional[float] = None,
                           loss: float = 14.0, pv_tech: str = 'crystSi',
                           include_components: bool = True, # Default True para obtener G(h),T2m,WS10m
                           use_horizon_effect: bool = True,
                           tracking_type: int = 0 # Asumimos fijo por defecto para esta clase
                           ) -> Optional[Dict[str, Any]]:
        """
        Realiza la petición a la API PVGIS seriescalc y maneja errores/reintentos.
        (Lógica validada y robusta basada en el script de prueba)
        """
        if pv_calculation and peak_power is None:
            logging.error("Error interno: Se requiere potencia nominal (peak_power) para cálculo PV.")
            return None

        params = {
            'lat': lat, 'lon': lon, 'outputformat': 'json',
            'startyear': start_year, 'endyear': end_year,
            'pvcalculation': 1 if pv_calculation else 0,
            'trackingtype': tracking_type, # Usar el trackingtype pasado (default 0)
            'components': 1 if include_components else 0,
            'usehorizon': 1 if use_horizon_effect else 0,
        }

        if pv_calculation:
            params['peakpower'] = peak_power
            params['loss'] = loss
            params['pvtechchoice'] = pv_tech
            # Solo añadir angle/aspect si son relevantes para el tracking_type (asumimos fijo aquí)
            if tracking_type == 0:
                if angle is not None: params['angle'] = angle
                if aspect is not None: params['aspect'] = aspect
            # Podríamos añadir lógica para otros tracking types si fuera necesario

        # --- Lógica de Petición con Reintentos ---
        retry_delay = self.INITIAL_RETRY_DELAY
        for attempt in range(self.MAX_RETRIES):
            try:
                logging.info(f"Solicitando datos a PVGIS (Intento {attempt+1}/{self.MAX_RETRIES})...")
                logging.debug(f"URL: {self.PVGIS_API_URL}")
                logging.debug(f"Params: {params}") # Loguear parámetros en DEBUG puede ser útil

                response = requests.get(self.PVGIS_API_URL, params=params, timeout=self.DEFAULT_TIMEOUT)

                if response.status_code >= 400:
                    error_msg = f"Error HTTP {response.status_code} de PVGIS"
                    try:
                        error_detail = response.json().get('message', response.text)
                        error_msg += f": {error_detail}"
                    except json.JSONDecodeError:
                        error_msg += f": {response.text[:200]}" # Primeros chars si no es JSON
                    logging.error(error_msg)
                    response.raise_for_status() # Lanza excepción para reintento/fallo

                data = response.json()

                # Verificar errores internos en la respuesta JSON
                if 'errors' in data and data['errors']:
                    error_msgs = data['errors']
                    logging.error(f"PVGIS reportó errores internos en la respuesta: {error_msgs}")
                    raise Exception(f"Errores internos de PVGIS: {error_msgs}")

                logging.info(f"✓ Respuesta correcta recibida de PVGIS.")
                return data # Éxito

            except requests.exceptions.Timeout:
                logging.warning(f"Timeout en solicitud PVGIS (intento {attempt+1}/{self.MAX_RETRIES})")
            except requests.exceptions.RequestException as e:
                logging.warning(f"Error de conexión/red en solicitud PVGIS (intento {attempt+1}/{self.MAX_RETRIES}): {e}")
            except Exception as e: # Captura errores HTTP, errores JSON, errores internos lanzados
                logging.warning(f"Error procesando solicitud/respuesta PVGIS (intento {attempt+1}/{self.MAX_RETRIES}): {e}")

            if attempt < self.MAX_RETRIES - 1:
                logging.info(f"Reintentando en {retry_delay} segundos...")
                time.sleep(retry_delay)
                retry_delay *= 2
            else:
                logging.error(f"Error: Se agotaron los reintentos ({self.MAX_RETRIES}) para la solicitud a PVGIS.")
                return None # Fallo definitivo