import requests
from typing import List, Dict, Any, Optional, Tuple, Union
from datetime import datetime, timedelta, date
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.domain.repositories.datos_ambientales_repository import DatosAmbientalesRepository
import logging
import time

class DatosAmbientalesApiRepository(DatosAmbientalesRepository):
    """
    Implementación del repositorio de datos ambientales que usa la API de PVGIS 
    para obtener tanto datos ambientales como datos de generación fotovoltaica.
    """
    
    def get_datos_ambientales(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date]) -> List[DatosAmbientalesEntity]:
        """
        Obtiene datos ambientales (radiación, temperatura, viento) de la API de PVGIS.
        
        Args:
            lat: Latitud en grados decimales
            lon: Longitud en grados decimales
            start_date: Fecha de inicio
            end_date: Fecha de fin
            
        Returns:
            Lista de entidades de datos ambientales
        """
        # Convertir date a datetime si es necesario
        start_date_dt = self._ensure_datetime(start_date)
        end_date_dt = self._ensure_datetime(end_date)
        
        # Obtener datos de PVGIS
        pvgis_data = self._request_pvgis_data(lat, lon, start_date_dt.year, end_date_dt.year)
        
        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error(f"No se pudieron obtener datos de PVGIS para lat={lat}, lon={lon}")
            return []
        else:
            logging.info(f"✓ PVGIS: Respuesta correcta recibida para lat={lat}, lon={lon}")
            
        # Procesar los datos horarios
        hourly_data = pvgis_data['outputs']['hourly']
        resultados: List[DatosAmbientalesEntity] = []
        
        # Extraer registros para el período solicitado
        for hora in hourly_data:
            try:
                # Procesar timestamp de manera simplificada
                ts = self._parse_pvgis_timestamp(hora.get('time'), start_date_dt, end_date_dt)
                if not ts:
                    continue
                
                # Filtrar registros fuera del rango solicitado
                if ts < start_date_dt or ts > end_date_dt:
                    continue
                
                # Extraer datos ambientales del registro
                ghi_wh = float(hora.get('G(h)', 0))
                temp_c = float(hora.get('T2m', 20))  # Default 20°C si no hay dato
                wind_ms = float(hora.get('WS10m', 0))  # Default 0 m/s si no hay dato
                
                resultados.append(DatosAmbientalesEntity(
                    idRegistro=None,  # Se asignará al guardar en BD
                    timestamp=ts,
                    fuenteDatos="PVGIS",
                    radiacionGlobalHoriz_Wh_m2=ghi_wh,
                    temperaturaAmbiente_C=temp_c,
                    velocidadViento_m_s=wind_ms
                ))
            except Exception as e:
                logging.error(f"Error procesando registro horario PVGIS: {str(e)}")
                logging.debug(f"Datos del registro con error: {hora}")
                continue
                
        logging.info(f"✓ PVGIS: Obtenidos {len(resultados)} registros de datos ambientales")
        return resultados
        
    def get_generacion_fotovoltaica(self, lat: float, lon: float, start_date: Union[datetime, date], end_date: Union[datetime, date], 
                                   peak_power_kwp: float, angle: float, aspect: float, 
                                   loss: float = 14.0, tech: str = 'crystSi') -> Dict[datetime, float]:
        """
        Obtiene datos de generación fotovoltaica de la API de PVGIS.
        
        Args:
            lat: Latitud en grados decimales
            lon: Longitud en grados decimales
            start_date: Fecha de inicio
            end_date: Fecha de fin
            peak_power_kwp: Potencia nominal del sistema en kWp
            angle: Ángulo de inclinación (grados)
            aspect: Ángulo de azimut (grados, 0=Sur, -90=Este, 90=Oeste)
            loss: Pérdidas del sistema (porcentaje)
            tech: Tecnología del panel ('crystSi', 'CIS', 'CdTe', 'Unknown')
            
        Returns:
            Diccionario que mapea timestamp a generación en kWh
        """
        # Convertir date a datetime si es necesario
        start_date_dt = self._ensure_datetime(start_date)
        end_date_dt = self._ensure_datetime(end_date)
        
        # Obtener datos de PVGIS con cálculo PV activado
        pvgis_data = self._request_pvgis_data(
            lat, lon, 
            start_date_dt.year, end_date_dt.year,
            pv_calculation=True,
            peak_power=peak_power_kwp,
            angle=angle,
            aspect=aspect,
            loss=loss,
            pv_tech=tech
        )
        
        if not pvgis_data or 'outputs' not in pvgis_data or 'hourly' not in pvgis_data['outputs']:
            logging.error(f"No se pudieron obtener datos de generación PV para lat={lat}, lon={lon}")
            return {}
        else:
            logging.info(f"✓ PVGIS: Respuesta correcta recibida para generación PV en lat={lat}, lon={lon}")
            
        # Procesar los datos horarios
        hourly_data = pvgis_data['outputs']['hourly']
        resultados: Dict[datetime, float] = {}
        
        # Extraer generación para el período solicitado
        for hora in hourly_data:
            try:
                # Procesar timestamp de manera simplificada
                ts = self._parse_pvgis_timestamp(hora.get('time'), start_date_dt, end_date_dt)
                if not ts:
                    continue
                
                # Filtrar registros fuera del rango solicitado
                if ts < start_date_dt or ts > end_date_dt:
                    continue
                
                # 'P' es la potencia generada en W, la convertimos a kWh para una hora
                potencia_w = float(hora.get('P', 0))
                energia_kwh = potencia_w / 1000.0  # kWh para una hora
                
                resultados[ts] = energia_kwh
            except Exception as e:
                logging.error(f"Error procesando registro de generación PV: {str(e)}")
                logging.debug(f"Datos del registro de generación con error: {hora}")
                continue
                
        logging.info(f"✓ PVGIS: Obtenidas {len(resultados)} horas de generación PV")
        return resultados
    
    def _ensure_datetime(self, date_obj: Union[datetime, date]) -> datetime:
        """
        Convierte un objeto date a datetime si es necesario
        """
        if isinstance(date_obj, date) and not isinstance(date_obj, datetime):
            return datetime.combine(date_obj, datetime.min.time())
        return date_obj
    
    def _parse_pvgis_timestamp(self, ts_str: str, default_start: datetime, default_end: datetime) -> Optional[datetime]:
        """
        Procesa el formato de timestamp de PVGIS de manera simplificada
        
        Args:
            ts_str: String con el timestamp en formato PVGIS (YYYYMMDDHHMM)
            default_start: Fecha de inicio para usar como respaldo
            default_end: Fecha de fin para usar como respaldo
            
        Returns:
            Objeto datetime o None si no se puede procesar
        """
        if not ts_str:
            return None
            
        try:
            # Limpiar el string, mantener solo dígitos
            ts_clean = ''.join(c for c in ts_str if c.isdigit())
            
            # Asegurar que tenemos suficientes dígitos
            if len(ts_clean) < 12:
                ts_clean = ts_clean.ljust(12, '0')
                
            # Convertir a datetime
            return datetime(
                year=int(ts_clean[0:4]), 
                month=int(ts_clean[4:6]),
                day=int(ts_clean[6:8]),
                hour=int(ts_clean[8:10]),
                minute=int(ts_clean[10:12])
            )
        except ValueError as e:
            logging.warning(f"Error al procesar timestamp PVGIS '{ts_str}': {e}")
            # Usar un valor por defecto en el rango solicitado
            return default_start + (default_end - default_start) / 2
        except Exception as e:
            logging.error(f"Error inesperado al procesar timestamp PVGIS '{ts_str}': {e}")
            return None
    
    def _request_pvgis_data(self, lat: float, lon: float, start_year: int, end_year: int, 
                           pv_calculation: bool = False, peak_power: float = None,
                           angle: float = None, aspect: float = None, 
                           loss: float = 14.0, pv_tech: str = 'crystSi') -> Optional[Dict[str, Any]]:
        """
        Realiza una petición a la API PVGIS para obtener datos horarios.
        
        Args:
            lat: Latitud en grados decimales
            lon: Longitud en grados decimales
            start_year: Año inicial
            end_year: Año final
            pv_calculation: Si se debe calcular la producción fotovoltaica
            peak_power: Potencia nominal en kWp (requerida si pv_calculation=True)
            angle: Ángulo de inclinación del panel
            aspect: Ángulo de azimut del panel
            loss: Pérdidas del sistema (porcentaje)
            pv_tech: Tecnología del panel ('crystSi', 'CIS', 'CdTe', 'Unknown')
            
        Returns:
            Diccionario con la respuesta de PVGIS o None si hay error
        """
        # URL de la API PVGIS
        api_url = "https://re.jrc.ec.europa.eu/api/v5_3/seriescalc"
        
        # Parámetros básicos de la petición
        params = {
            'lat': lat,
            'lon': lon,
            'outputformat': 'json',
            'startyear': start_year,
            'endyear': end_year,
            'pvcalculation': 1 if pv_calculation else 0,
            'components': 1,  # Incluir componentes de radiación
            'usehorizon': 1,  # Considerar horizonte
        }
        
        # Añadir parámetros para cálculo PV si es necesario
        if pv_calculation:
            if peak_power is None:
                logging.error("Error: Se requiere potencia nominal para cálculo PV")
                return None
                
            params['peakpower'] = peak_power
            params['loss'] = loss
            params['pvtechchoice'] = pv_tech
            
            if angle is not None:
                params['angle'] = angle
            if aspect is not None:
                params['aspect'] = aspect
        
        # Realizar la petición con reintentos
        max_retries = 3
        retry_delay = 5  # segundos
        
        for attempt in range(max_retries):
            try:
                logging.info(f"Solicitando datos a PVGIS: {params}")
                response = requests.get(api_url, params=params, timeout=180)
                
                # Si hay un error HTTP, mostrar mensaje claro
                if response.status_code >= 400:
                    error_msg = f"Error {response.status_code} en solicitud PVGIS"
                    try:
                        error_detail = response.json().get('message', response.text)
                        error_msg += f": {error_detail}"
                    except:
                        error_msg += f": {response.text[:200]}"
                    
                    logging.error(error_msg)
                    response.raise_for_status()
                
                data = response.json()
                
                # Verificar si hay mensajes de error en la respuesta JSON
                if 'errors' in data:
                    error_msgs = data.get('errors', [])
                    if error_msgs:
                        logging.error(f"PVGIS reportó errores: {error_msgs}")
                        raise Exception(f"PVGIS reportó errores: {error_msgs}")
                
                logging.info(f"✓ Respuesta correcta recibida de PVGIS")
                return data
                
            except requests.exceptions.RequestException as e:
                logging.error(f"Error en solicitud PVGIS (intento {attempt+1}/{max_retries}): {str(e)}")
            except Exception as e:
                logging.error(f"Error procesando respuesta PVGIS (intento {attempt+1}/{max_retries}): {str(e)}")
                
            if attempt < max_retries - 1:
                logging.info(f"Reintentando en {retry_delay} segundos...")
                time.sleep(retry_delay)
                retry_delay *= 2  # Backoff exponencial
            else:
                logging.error(f"Error: Se agotaron los reintentos para la solicitud a PVGIS")
                return None