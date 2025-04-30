from pydantic import BaseModel, Field
from typing import Optional

class ResultadoSimulacionActivoAlmacenamientoBase(BaseModel):
    """Clase base para los esquemas de resultado de simulación por activo de almacenamiento"""
    energiaTotalCargada_kWh: Optional[float] = Field(None, description="Energía total cargada en kWh")
    energiaTotalDescargada_kWh: Optional[float] = Field(None, description="Energía total descargada en kWh")
    ciclosEquivalentes: Optional[float] = Field(None, description="Ciclos equivalentes realizados")
    perdidasEficiencia_kWh: Optional[float] = Field(None, description="Pérdidas por eficiencia en kWh")
    socMedio_pct: Optional[float] = Field(None, description="Estado de carga medio en porcentaje")
    socMin_pct: Optional[float] = Field(None, description="Estado de carga mínimo alcanzado en porcentaje")
    socMax_pct: Optional[float] = Field(None, description="Estado de carga máximo alcanzado en porcentaje")
    degradacionEstimada_pct: Optional[float] = Field(None, description="Degradación estimada en porcentaje")
    throughputTotal_kWh: Optional[float] = Field(None, description="Throughput total en kWh")

class ResultadoSimulacionActivoAlmacenamientoCreate(ResultadoSimulacionActivoAlmacenamientoBase):
    """Esquema para crear un nuevo resultado de simulación por activo de almacenamiento"""
    idResultadoSimulacion: int = Field(..., description="ID del resultado de simulación")
    idActivoAlmacenamiento: int = Field(..., description="ID del activo de almacenamiento")

class ResultadoSimulacionActivoAlmacenamientoUpdate(ResultadoSimulacionActivoAlmacenamientoBase):
    """Esquema para actualizar un resultado existente"""
    pass

class ResultadoSimulacionActivoAlmacenamientoRead(ResultadoSimulacionActivoAlmacenamientoBase):
    """Esquema para la respuesta de resultado de simulación por activo de almacenamiento"""
    idResultadoActivoAlm: int
    idResultadoSimulacion: int
    idActivoAlmacenamiento: int

    class Config:
        from_attributes = True