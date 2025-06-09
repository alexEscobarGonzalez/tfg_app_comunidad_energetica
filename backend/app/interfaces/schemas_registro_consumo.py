from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional, List, Dict, Any

class RegistroConsumoBase(BaseModel):
    timestamp: datetime = Field(description="Fecha y hora del registro de consumo")
    consumoEnergia: float = Field(description="Consumo de energía en kWh", gt=0)
    idParticipante: int = Field(description="ID del participante al que corresponde este consumo")

class RegistroConsumoCreate(RegistroConsumoBase):
    pass

class RegistroConsumoUpdate(BaseModel):
    timestamp: Optional[datetime] = None
    consumoEnergia: Optional[float] = Field(None, gt=0)

class RegistroConsumoRead(RegistroConsumoBase):
    idRegistroConsumo: int
    
    model_config = ConfigDict(from_attributes=True)

# Esquemas para predicción de consumo (Modelo Socioeconómico v3)
class PrediccionConsumoRequest(BaseModel):
    
    fecha_inicio: datetime = Field(..., description="Fecha y hora de inicio del rango")
    fecha_fin: datetime = Field(..., description="Fecha y hora de fin del rango")
    intervalo_horas: int = Field(1, ge=1, le=24, description="Intervalo en horas entre predicciones")
    
    # Características socioeconómicas (2)
    tipo_vivienda: int = Field(2, ge=1, le=4, description="Tipo de vivienda (1=Casa pequeña, 2=Apartamento, 3=Casa mediana, 4=Casa grande)")
    num_personas: int = Field(3, ge=1, le=8, description="Número de personas en el hogar")
    
    # Característica climática (1)
    temperatura: float = Field(20.0, ge=-10, le=40, description="Temperatura promedio en °C")
    
    # Características de lags mensuales (3)
    lag_mes1: float = Field(0.5, ge=0.01, le=5.0, description="Consumo promedio del mes anterior en kWh")
    lag_mes2: float = Field(0.5, ge=0.01, le=5.0, description="Consumo promedio de hace 2 meses en kWh")
    lag_mes3: float = Field(0.5, ge=0.01, le=5.0, description="Consumo promedio de hace 3 meses en kWh")

    class Config:
        json_schema_extra = {
            "example": {
                "fecha_inicio": "2024-06-15T00:00:00",
                "fecha_fin": "2024-06-15T23:00:00",
                "intervalo_horas": 1,
                "tipo_vivienda": 2,
                "num_personas": 4,
                "temperatura": 22.0,
                "lag_mes1": 0.52,
                "lag_mes2": 0.48,
                "lag_mes3": 0.55
            }
        }

class EstadisticasTarifa(BaseModel):
    
    periodos: int = Field(..., description="Número de períodos de tiempo")
    consumo_total: float = Field(..., description="Consumo total en kWh")
    consumo_promedio: float = Field(..., description="Consumo promedio en kWh")

class ModeloInfo(BaseModel):
    
    version: str = Field(..., description="Versión del modelo")
    algoritmo: str = Field(..., description="Algoritmo utilizado")
    caracteristicas: int = Field(..., description="Número de características")

class ResumenPrediccion(BaseModel):
    
    fecha_inicio: str = Field(..., description="Fecha de inicio del rango")
    fecha_fin: str = Field(..., description="Fecha de fin del rango") 
    intervalo_horas: int = Field(..., description="Intervalo usado en horas")
    total_periodos: int = Field(..., description="Total de períodos predichos")
    consumo_total_kwh: float = Field(..., description="Consumo total predicho en kWh")
    consumo_promedio_kwh: float = Field(..., description="Consumo promedio por período")
    consumo_maximo_kwh: float = Field(..., description="Consumo máximo predicho")
    consumo_minimo_kwh: float = Field(..., description="Consumo mínimo predicho")
    estadisticas_por_tarifa: Dict[str, EstadisticasTarifa] = Field(..., description="Estadísticas por tipo de tarifa")
    perfil: dict = Field(..., description="Perfil del hogar utilizado")
    modelo_info: ModeloInfo = Field(..., description="Información del modelo")

class PrediccionConsumoResponse(BaseModel):
    
    predicciones: List[Dict[str, Any]] = Field(..., description="Lista de predicciones por intervalo")
    resumen: ResumenPrediccion = Field(..., description="Resumen estadístico")

    class Config:
        json_schema_extra = {
            "example": {
                "predicciones": [
                    {
                        "consumo_kwh": 0.678,
                        "fecha_hora": "2024-06-15 00:00",
                        "tipo_tarifa": "Valle",
                        "temperatura": 22.0,
                        "perfil": {"tipo_vivienda": 2, "num_personas": 4}
                    },
                    {
                        "consumo_kwh": 0.892,
                        "fecha_hora": "2024-06-15 01:00", 
                        "tipo_tarifa": "Valle",
                        "temperatura": 22.0,
                        "perfil": {"tipo_vivienda": 2, "num_personas": 4}
                    }
                ],
                "resumen": {
                    "fecha_inicio": "2024-06-15 00:00",
                    "fecha_fin": "2024-06-15 23:00",
                    "intervalo_horas": 1,
                    "total_periodos": 24,
                    "consumo_total_kwh": 17.832,
                    "consumo_promedio_kwh": 0.743,
                    "consumo_maximo_kwh": 1.234,
                    "consumo_minimo_kwh": 0.456,
                    "estadisticas_por_tarifa": {
                        "Valle": {
                            "periodos": 10,
                            "consumo_total": 7.376,
                            "consumo_promedio": 0.738
                        },
                        "Normal": {
                            "periodos": 10,
                            "consumo_total": 7.16,
                            "consumo_promedio": 0.716
                        },
                        "Punta": {
                            "periodos": 4,
                            "consumo_total": 3.296,
                            "consumo_promedio": 0.824
                        }
                    },
                    "perfil": {
                        "tipo_vivienda": 2,
                        "num_personas": 4,
                        "temperatura_promedio": 22.0
                    },
                    "modelo_info": {
                        "version": "basico_v1.0",
                        "algoritmo": "LightGBM",
                        "caracteristicas": 11
                    }
                }
            }
        }