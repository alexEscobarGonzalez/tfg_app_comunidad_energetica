import joblib
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Any, List
import logging

# Configurar logging
logger = logging.getLogger(__name__)

class PredictorConsumo:
    """Clase para cargar y usar el modelo de predicción de consumo socioeconómico v3"""
    
    def __init__(self):
        self.modelo = None
        self.metadata = None
        self._cargar_modelo()
    
    def _cargar_modelo(self):
        """Carga el modelo entrenado desde app/ml"""
        try:
            # Ruta fija del modelo
            modelo_dir = Path("app/ml")
            modelo_file = modelo_dir / "modelo_lightgbm_optimizado.pkl"
            metadata_file = modelo_dir / "metadata.pkl"
            
            logger.info(f"Intentando cargar modelo desde: {modelo_dir}")
            
            if not modelo_dir.exists():
                raise Exception(f"Directorio del modelo no existe: {modelo_dir}")
            
            if not modelo_file.exists():
                raise Exception(f"Archivo del modelo no encontrado: {modelo_file}")
                
            if not metadata_file.exists():
                raise Exception(f"Archivo de metadata no encontrado: {metadata_file}")
            
            # Cargar modelo y metadata
            modelo_cargado = joblib.load(modelo_file)
            self.metadata = joblib.load(metadata_file)
            
            # Verificar si es una función o un objeto con método predict
            if callable(modelo_cargado) and not hasattr(modelo_cargado, 'predict'):
                # Es una función directa, crear un wrapper
                class ModeloWrapper:
                    def __init__(self, predictor_func):
                        self.predictor_func = predictor_func
                    
                    def predict(self, X):
                        return self.predictor_func(X)
                
                self.modelo = ModeloWrapper(modelo_cargado)
            else:
                # Es un objeto con método predict
                self.modelo = modelo_cargado
            
            logger.info(f"Modelo cargado exitosamente. Versión: {self.metadata.get('version', 'N/A')}")
                
        except Exception as e:
            logger.error(f"Error al cargar el modelo: {str(e)}")
            raise Exception(f"No se pudo cargar el modelo: {str(e)}")
    
    def esta_disponible(self) -> bool:
        """Verifica si el modelo está disponible"""
        return self.modelo is not None
    
    def _clasificar_hora_tarifa(self, hora: int) -> tuple[int, str]:
        """
        Clasifica la hora según el tipo de tarifa eléctrica
        
        Valle: 22:00-8:00 (valor 0) - Tarifa más económica
        Normal: 8:00-18:00 (valor 1) - Tarifa estándar  
        Punta: 18:00-22:00 (valor 2) - Tarifa más cara
        """
        if 22 <= hora or hora < 8:
            return 0, "Valle"
        elif 8 <= hora < 18:
            return 1, "Normal"
        else:
            return 2, "Punta"
    
    def _preparar_datos_prediccion(
        self,
        fecha_hora: datetime,
        tipo_vivienda: int,
        num_personas: int,
        temperatura: float,
        lag_mes1: float,
        lag_mes2: float,
        lag_mes3: float
    ) -> pd.DataFrame:
        """Prepara los datos con las 11 características para el modelo"""
        
        # Extraer características temporales
        hora = fecha_hora.hour
        dia_semana = fecha_hora.weekday()
        es_finde = 1 if dia_semana >= 5 else 0
        mes = fecha_hora.month
        
        # Clasificar tipo de tarifa
        tipo_tarifa, _ = self._clasificar_hora_tarifa(hora)
        
        # Crear DataFrame con las 11 características requeridas
        datos = pd.DataFrame({
            'tipo_vivienda': [tipo_vivienda],
            'num_personas': [num_personas],
            'hora': [hora],
            'dia_semana': [dia_semana],
            'es_finde': [es_finde],
            'mes': [mes],
            'tipo_tarifa': [tipo_tarifa],
            'lag_mes1': [lag_mes1],
            'lag_mes2': [lag_mes2],
            'lag_mes3': [lag_mes3],
            'temp_hora': [temperatura]
        })
        
        return datos
    
    def predecir_rango(
        self,
        fecha_inicio: datetime,
        fecha_fin: datetime,
        intervalo_horas: int = 1,
        tipo_vivienda: int = 2,
        num_personas: int = 3,
        temperatura: float = 20.0,
        lag_mes1: float = 0.5,
        lag_mes2: float = 0.5,
        lag_mes3: float = 0.5
    ) -> List[Dict[str, Any]]:
        """
        Realiza predicciones de consumo para un rango de fechas
        
        Args:
            fecha_inicio: Fecha y hora de inicio
            fecha_fin: Fecha y hora de fin
            intervalo_horas: Intervalo en horas entre predicciones (1-24)
            tipo_vivienda: Tipo de vivienda (1-4)
            num_personas: Número de personas (1-8)
            temperatura: Temperatura promedio en °C (-10 a 40)
            lag_mes1: Consumo promedio mes anterior (0.01-5.0 kWh)
            lag_mes2: Consumo promedio hace 2 meses (0.01-5.0 kWh)
            lag_mes3: Consumo promedio hace 3 meses (0.01-5.0 kWh)
            
        Returns:
            Lista de predicciones para cada intervalo de tiempo
        """
        if not self.esta_disponible():
            raise Exception("El modelo no está disponible")
            
        if fecha_fin <= fecha_inicio:
            raise ValueError("La fecha de fin debe ser posterior a la fecha de inicio")
            
        predicciones = []
        fecha_actual = fecha_inicio
        
        while fecha_actual <= fecha_fin:
            try:
                # Preparar datos para esta fecha/hora
                datos = self._preparar_datos_prediccion(
                    fecha_actual, tipo_vivienda, num_personas, 
                    temperatura, lag_mes1, lag_mes2, lag_mes3
                )
                
                # Realizar predicción
                consumo_predicho = self.modelo.predict(datos)[0]
                
                # Obtener información de tarifa
                _, nombre_tarifa = self._clasificar_hora_tarifa(fecha_actual.hour)
                
                prediccion = {
                    'consumo_kwh': round(float(consumo_predicho), 3),
                    'fecha_hora': fecha_actual.strftime('%Y-%m-%d %H:%M'),
                    'tipo_tarifa': nombre_tarifa,
                    'temperatura': temperatura,
                    'perfil': {
                        'tipo_vivienda': tipo_vivienda,
                        'num_personas': num_personas
                    }
                }
                
                predicciones.append(prediccion)
                
            except Exception as e:
                logger.warning(f"Error en predicción para {fecha_actual}: {str(e)}")
                # Continuar con la siguiente fecha en caso de error
                
            fecha_actual += timedelta(hours=intervalo_horas)
        
        return predicciones

# Instancia global del predictor (singleton)
_predictor_global = None

def get_predictor() -> PredictorConsumo:
    """Obtiene la instancia global del predictor"""
    global _predictor_global
    if _predictor_global is None:
        _predictor_global = PredictorConsumo()
    return _predictor_global

def predecir_consumo_rango_use_case(
    fecha_inicio: datetime,
    fecha_fin: datetime,
    intervalo_horas: int = 1,
    tipo_vivienda: int = 2,
    num_personas: int = 3,
    temperatura: float = 20.0,
    lag_mes1: float = 0.5,
    lag_mes2: float = 0.5,
    lag_mes3: float = 0.5
) -> Dict[str, Any]:
    """
    Caso de uso para predecir el consumo energético en un rango de fechas
    
    Utiliza el modelo socioeconómico v3 con 11 características:
    - 2 socioeconómicas (tipo_vivienda, num_personas)
    - 5 temporales (hora, dia_semana, es_finde, mes, tipo_tarifa)
    - 3 lags mensuales (lag_mes1, lag_mes2, lag_mes3)
    - 1 climática (temp_hora)
    
    Args:
        fecha_inicio: Fecha y hora de inicio
        fecha_fin: Fecha y hora de fin
        intervalo_horas: Intervalo en horas entre predicciones (1-24)
        tipo_vivienda: Tipo de vivienda (1-4)
        num_personas: Número de personas (1-8)
        temperatura: Temperatura promedio en °C (-10 a 40)
        lag_mes1: Consumo promedio mes anterior (0.01-5.0 kWh)
        lag_mes2: Consumo promedio hace 2 meses (0.01-5.0 kWh)
        lag_mes3: Consumo promedio hace 3 meses (0.01-5.0 kWh)
        
    Returns:
        Dict con las predicciones y resumen estadístico
        
    Raises:
        Exception: Si el modelo no está disponible o hay error en la predicción
        ValueError: Si los parámetros están fuera de rango
    """
    # Validaciones según la documentación del modelo
    if tipo_vivienda < 1 or tipo_vivienda > 4:
        raise ValueError("tipo_vivienda debe estar entre 1 y 4")
    
    if num_personas < 1 or num_personas > 8:
        raise ValueError("num_personas debe estar entre 1 y 8")
        
    if temperatura < -10 or temperatura > 40:
        raise ValueError("temperatura debe estar entre -10 y 40°C")
    
    if intervalo_horas < 1 or intervalo_horas > 24:
        raise ValueError("intervalo_horas debe estar entre 1 y 24")
    
    # Validar lags de consumo histórico
    for lag_name, lag_value in [("lag_mes1", lag_mes1), ("lag_mes2", lag_mes2), ("lag_mes3", lag_mes3)]:
        if lag_value < 0.01 or lag_value > 5.0:
            raise ValueError(f"{lag_name} debe estar entre 0.01 y 5.0 kWh")
    
    # Obtener predictor y realizar predicciones
    predictor = get_predictor()
    
    predicciones = predictor.predecir_rango(
        fecha_inicio=fecha_inicio,
        fecha_fin=fecha_fin,
        intervalo_horas=intervalo_horas,
        tipo_vivienda=tipo_vivienda,
        num_personas=num_personas,
        temperatura=temperatura,
        lag_mes1=lag_mes1,
        lag_mes2=lag_mes2,
        lag_mes3=lag_mes3
    )
    
    # Calcular estadísticas
    if predicciones:
        consumos = [p['consumo_kwh'] for p in predicciones]
        total_consumo = sum(consumos)
        promedio_consumo = total_consumo / len(consumos)
        consumo_max = max(consumos)
        consumo_min = min(consumos)
        
        # Estadísticas por tarifa
        tarifas = {}
        for p in predicciones:
            tarifa = p['tipo_tarifa']
            if tarifa not in tarifas:
                tarifas[tarifa] = {'count': 0, 'total': 0}
            tarifas[tarifa]['count'] += 1
            tarifas[tarifa]['total'] += p['consumo_kwh']
        
        estadisticas_tarifa = {}
        for tarifa, datos in tarifas.items():
            estadisticas_tarifa[tarifa] = {
                'periodos': datos['count'],
                'consumo_total': round(datos['total'], 3),
                'consumo_promedio': round(datos['total'] / datos['count'], 3)
            }
    else:
        total_consumo = 0
        promedio_consumo = 0
        consumo_max = 0
        consumo_min = 0
        estadisticas_tarifa = {}
    
    return {
        'predicciones': predicciones,
        'resumen': {
            'fecha_inicio': fecha_inicio.strftime('%Y-%m-%d %H:%M'),
            'fecha_fin': fecha_fin.strftime('%Y-%m-%d %H:%M'),
            'intervalo_horas': intervalo_horas,
            'total_periodos': len(predicciones),
            'consumo_total_kwh': round(total_consumo, 3),
            'consumo_promedio_kwh': round(promedio_consumo, 3),
            'consumo_maximo_kwh': round(consumo_max, 3),
            'consumo_minimo_kwh': round(consumo_min, 3),
            'estadisticas_por_tarifa': estadisticas_tarifa,
            'perfil': {
                'tipo_vivienda': tipo_vivienda,
                'num_personas': num_personas,
                'temperatura_promedio': temperatura
            },
            'modelo_info': {
                'version': predictor.metadata.get('version', 'N/A') if predictor.metadata else 'N/A',
                'algoritmo': 'LightGBM',
                'caracteristicas': 11
            }
        }
    } 