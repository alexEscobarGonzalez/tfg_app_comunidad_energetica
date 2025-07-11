from pydantic import BaseModel, Field
from typing import Optional

class ResultadoSimulacionActivoGeneracionBase(BaseModel):
    
    energiaTotalGenerada_kWh: Optional[float] = Field(None, description="Energía total generada en kWh")
    factorCapacidad_pct: Optional[float] = Field(None, description="Factor de capacidad en porcentaje")
    performanceRatio_pct: Optional[float] = Field(None, description="Ratio de rendimiento en porcentaje")
    horasOperacionEquivalentes: Optional[float] = Field(None, description="Horas de operación equivalentes")

class ResultadoSimulacionActivoGeneracionCreate(ResultadoSimulacionActivoGeneracionBase):
    
    idResultadoSimulacion: int = Field(..., description="ID del resultado de simulación")
    idActivoGeneracion: int = Field(..., description="ID del activo de generación")

class ResultadoSimulacionActivoGeneracionUpdate(ResultadoSimulacionActivoGeneracionBase):
    
    pass

class ResultadoSimulacionActivoGeneracionRead(ResultadoSimulacionActivoGeneracionBase):
    
    idResultadoActivoGen: int
    idResultadoSimulacion: int
    idActivoGeneracion: int

    class Config:
        from_attributes = True