import requests
import logging
import time
import json
from typing import List, Dict, Any, Optional, Union
from datetime import datetime, date, timezone

from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity

class DatosAmbientalesApiRepository(DatosAmbientalesRepository):
    PVGIS_API_URL = "https://re.jrc.ec.europa.eu/api/v5_3/seriescalc"
    DEFAULT_TIMEOUT = 180
    MAX_RETRIES = 3
    INITIAL_RETRY_DELAY = 5

    def get_datos_ambientales(
        self,
        lat: float,
        lon: float,
        start_date: Union[datetime, date],
        end_date: Union[datetime, date]
    ) -> List[DatosAmbientalesEntity]:
        """
        Obtiene datos ambientales de PVGIS para un período y ubicación
        
        Args:
            lat: Latitud en grados decimales
            lon: Longitud en grados decimales
            start_date: Fecha/hora de inicio
            end_date: Fecha/hora de fin
            
        Returns:
            Lista de entidades DatosAmbientalesEntity
        """
        # Convertir fechas a UTC-aware y luego a naive UTC para consistencia interna
        start_dt = self._ensure_datetime_utc(start_date, start_of_day=True).replace(tzinfo=None)
        end_dt = self._ensure_datetime_utc(end_date, start_of_day=False).replace(tzinfo=None)

        logging.info(f"Solicitando datos ambientales de PVGIS para lat={lat}, lon={lon}, "
                     f"periodo=[{start_dt.isoformat()}, {end_dt.isoformat()}]")

        # Obtener datos de PVGIS para el período especificado
        pvgis_data = self._request_pvgis_data(
            lat=lat, lon=lon,
            start_year=start_dt.year,
            end_year=end_dt.year,
            include_components=True
        )
        
        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error("No se obtuvieron datos horarios de PVGIS.")
            return []

        logging.info(f"✓ PVGIS: Respuesta horaria recibida para datos ambientales en lat={lat}, lon={lon}.")
        
        # Procesar los datos horarios
        resultados: List[DatosAmbientalesEntity] = []
        for rec in pvgis_data['outputs']['hourly']:
            # Parsear el timestamp PVGIS y normalizarlo al inicio de hora y sin zona horaria
            ts = self._parse_pvgis_timestamp(rec.get('time'))
            if not ts:
                continue

            # IMPORTANTE: Normalizar al inicio de hora exacta y quitar tzinfo
            # para que sea compatible con los timestamps de consumo
            ts = ts.astimezone(timezone.utc).replace(minute=0, second=0, microsecond=0, tzinfo=None)

            # Filtrar por el rango exacto solicitado
            if not (start_dt <= ts <= end_dt):
                continue

            # Extraer datos del registro
            try:
                ghi = float(rec.get('G(h)', 0.0))  # Radiación global horizontal (Wh/m²)
                temp = float(rec.get('T2m', 20.0))  # Temperatura ambiente (°C)
                wind = float(rec.get('WS10m', 0.0))  # Velocidad del viento (m/s)
            except (ValueError, TypeError) as e:
                logging.warning(f"Error al convertir valores en registro ambiental ({ts}): {e}")
                continue

            # Crear y añadir entidad de datos ambientales
            resultados.append(DatosAmbientalesEntity(
                idRegistro=None,  # Se asignará en la base de datos
                timestamp=ts,
                fuenteDatos="PVGIS",
                radiacionGlobalHoriz_Wh_m2=ghi,
                temperaturaAmbiente_C=temp,
                velocidadViento_m_s=wind
            ))

        logging.info(f"✓ PVGIS: Extraídos {len(resultados)} registros de datos ambientales "
                     f"para el período solicitado.")
        return resultados

    def get_generacion_fotovoltaica(
        self,
        lat: float,
        lon: float,
        start_date: Union[datetime, date],
        end_date: Union[datetime, date],
        peak_power_kwp: float,
        angle: float,
        aspect: float,
        loss: float = 14.0,
        tech: str = 'crystSi'
    ) -> Dict[datetime, float]:
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
            Diccionario que mapea timestamp (datetime naive) a generación estimada en kWh para esa hora.
        """
        # Convertir fechas para consistencia interna
        start_dt = self._ensure_datetime_utc(start_date, start_of_day=True).replace(tzinfo=None)
        end_dt = self._ensure_datetime_utc(end_date, start_of_day=False).replace(tzinfo=None)

        logging.info(f"Solicitando generación PV estimada de PVGIS para lat={lat}, lon={lon}, "
                     f"periodo=[{start_dt.isoformat()}, {end_dt.isoformat()}], "
                     f"P={peak_power_kwp}kWp, angle={angle}, aspect={aspect}, loss={loss}%")

        # Obtener datos de PVGIS con cálculo PV activado
        pvgis_data = self._request_pvgis_data(
            lat=lat, lon=lon,
            start_year=start_dt.year,
            end_year=end_dt.year,
            pv_calculation=True,  # Activar cálculo PV
            peak_power=peak_power_kwp,
            angle=angle,
            aspect=aspect,
            loss=loss,
            pv_tech=tech,
            include_components=False  # No necesitamos componentes para generación
        )

        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error(f"No se pudieron obtener datos horarios válidos de generación PV "
                          f"de PVGIS para lat={lat}, lon={lon}")
            return {}

        logging.info(f"✓ PVGIS: Respuesta horaria recibida para generación PV en lat={lat}, lon={lon}.")

        # Procesar y filtrar los datos horarios
        hourly_data = pvgis_data['outputs']['hourly']
        resultados: Dict[datetime, float] = {}

        for record in hourly_data:
            # Parsear y normalizar timestamp al inicio de hora exacta
            ts = self._parse_pvgis_timestamp(record.get('time'))
            if not ts:
                logging.warning(f"Saltando registro de generación con timestamp inválido: {record.get('time')}")
                continue

            # IMPORTANTE: Normalizar al inicio de hora exacta y quitar tzinfo
            ts = ts.astimezone(timezone.utc).replace(minute=0, second=0, microsecond=0, tzinfo=None)
            
            # Filtrar por el rango exacto solicitado
            if not (start_dt <= ts <= end_dt):
                continue

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

        logging.info(f"✓ PVGIS: Extraídas {len(resultados)} horas de generación PV estimada "
                     f"para el período solicitado.")
        return resultados

    def _ensure_datetime_utc(self, date_obj: Union[datetime, date], start_of_day: bool = True) -> datetime:
        """
        Asegura que el objeto sea un datetime con zona horaria UTC.
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
            dt = datetime.now(timezone.utc)  # Fallback muy genérico

        # Asegurar que sea consciente de la zona horaria y convertir a UTC si es necesario
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
            logging.debug(f"Timestamp naive convertido a UTC (asumido): {dt.isoformat()}")
        elif dt.tzinfo != timezone.utc:
            dt = dt.astimezone(timezone.utc)
            logging.debug(f"Timestamp convertido a UTC: {dt.isoformat()}")

        return dt

    def _parse_pvgis_timestamp(self, ts_str: Optional[str]) -> Optional[datetime]:
        """
        Convierte el string de timestamp de PVGIS (formato 'YYYYMMDD:HHMM') a un objeto datetime UTC.
        """
        if not ts_str:
            return None

        try:
            # El formato esperado es como '20220101:0010' (PVGIS devuelve tiempos en UTC)
            dt = datetime.strptime(ts_str, "%Y%m%d:%H%M").replace(tzinfo=timezone.utc)
            return dt
        except ValueError:
            # Intentar limpiar si el formato es ligeramente diferente (ej. sin ':')
            ts_clean = ''.join(filter(str.isdigit, ts_str))
            if len(ts_clean) == 12:  # YYYYMMDDHHMM
                try:
                    dt = datetime.strptime(ts_clean, "%Y%m%d%H%M").replace(tzinfo=timezone.utc)
                    return dt
                except ValueError:
                    pass  # Falla también tras limpiar

            logging.warning(f"No se pudo parsear el timestamp PVGIS con formatos conocidos: '{ts_str}'")
            return None
        except Exception as e:
            logging.error(f"Error inesperado al parsear timestamp PVGIS '{ts_str}': {e}")
            return None

    def _request_pvgis_data(
        self,
        lat: float,
        lon: float,
        start_year: int,
        end_year: int,
        pv_calculation: bool = False,
        peak_power: Optional[float] = None,
        angle: Optional[float] = None,
        aspect: Optional[float] = None,
        loss: float = 14.0,
        pv_tech: str = 'crystSi',
        include_components: bool = True,
        use_horizon_effect: bool = True,
        tracking_type: int = 0
    ) -> Optional[Dict[str, Any]]:
        """
        Realiza la petición a la API PVGIS seriescalc y maneja errores/reintentos.
        """
        if pv_calculation and peak_power is None:
            logging.error("Error interno: Se requiere potencia nominal (peak_power) para cálculo PV.")
            return None

        # Construir parámetros para la solicitud
        params = {
            'lat': lat,
            'lon': lon,
            'outputformat': 'json',
            'startyear': start_year,
            'endyear': end_year,
            'pvcalculation': 1 if pv_calculation else 0,
            'trackingtype': tracking_type,
            'components': 1 if include_components else 0,
            'usehorizon': 1 if use_horizon_effect else 0,
        }

        # Añadir parámetros específicos para cálculo PV
        if pv_calculation:
            params['peakpower'] = peak_power
            params['loss'] = loss
            params['pvtechchoice'] = pv_tech
            
            # Solo añadir angle/aspect para instalación fija o relevante
            if tracking_type == 0:
                if angle is not None:
                    params['angle'] = angle
                if aspect is not None:
                    params['aspect'] = aspect

        # Lógica de petición con reintentos
        retry_delay = self.INITIAL_RETRY_DELAY
        for attempt in range(self.MAX_RETRIES):
            try:
                logging.info(f"Solicitando datos a PVGIS (Intento {attempt+1}/{self.MAX_RETRIES})...")
                
                response = requests.get(
                    self.PVGIS_API_URL,
                    params=params,
                    timeout=self.DEFAULT_TIMEOUT
                )
                
                # Manejar errores HTTP
                if response.status_code >= 400:
                    error_msg = f"Error HTTP {response.status_code} de PVGIS"
                    try:
                        error_detail = response.json().get('message', response.text)
                        error_msg += f": {error_detail}"
                    except json.JSONDecodeError:
                        error_msg += f": {response.text[:200]}"
                    logging.error(error_msg)
                    response.raise_for_status()

                data = response.json()
                
                # Verificar errores internos en la respuesta JSON
                if 'errors' in data and data['errors']:
                    error_msgs = data['errors']
                    logging.error(f"PVGIS reportó errores internos en la respuesta: {error_msgs}")
                    raise Exception(f"Errores internos de PVGIS: {error_msgs}")
                
                logging.info("✓ Respuesta correcta recibida de PVGIS.")
                return data
                
            except requests.exceptions.Timeout:
                logging.warning(f"Timeout en solicitud PVGIS (intento {attempt+1}/{self.MAX_RETRIES})")
            except requests.exceptions.RequestException as e:
                logging.warning(f"Error de conexión/red en solicitud PVGIS (intento {attempt+1}/{self.MAX_RETRIES}): {e}")
            except Exception as e:
                logging.warning(f"Error procesando solicitud/respuesta PVGIS (intento {attempt+1}/{self.MAX_RETRIES}): {e}")
                
            # Reintento con backoff exponencial
            if attempt < self.MAX_RETRIES - 1:
                logging.info(f"Reintentando en {retry_delay} segundos...")
                time.sleep(retry_delay)
                retry_delay *= 2
        
        logging.error(f"Error: Se agotaron los {self.MAX_RETRIES} reintentos para la solicitud a PVGIS.")
        return None