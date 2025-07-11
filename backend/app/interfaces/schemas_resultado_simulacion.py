from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ResultadoSimulacionBase(BaseModel):
    
    costeTotalEnergia_eur: Optional[float] = Field(None, description="Coste total de la energía en euros")
    ahorroTotal_eur: Optional[float] = Field(None, description="Ahorro total en euros")
    ingresoTotalExportacion_eur: Optional[float] = Field(None, description="Ingreso total por exportación en euros")
    paybackPeriod_anios: Optional[float] = Field(None, description="Periodo de recuperación de la inversión en años")
    roi_pct: Optional[float] = Field(None, description="Retorno de inversión en porcentaje")
    tasaAutoconsumoSCR_pct: Optional[float] = Field(None, description="Tasa de autoconsumo (SCR) en porcentaje")
    tasaAutosuficienciaSSR_pct: Optional[float] = Field(None, description="Tasa de autosuficiencia (SSR) en porcentaje")
    energiaTotalImportada_kWh: Optional[float] = Field(None, description="Energía total importada de la red en kWh")
    energiaTotalExportada_kWh: Optional[float] = Field(None, description="Energía total exportada a la red en kWh")
    reduccionCO2_kg: Optional[float] = Field(None, description="Reducción de emisiones de CO2 en kg")

class ResultadoSimulacionCreate(ResultadoSimulacionBase):
    
    idSimulacion: int = Field(..., description="ID de la simulación asociada")

class ResultadoSimulacionUpdate(ResultadoSimulacionBase):
    
    pass

class ResultadoSimulacionRead(ResultadoSimulacionBase):
    
    idResultado: int
    fechaCreacion: datetime
    idSimulacion: int

    class Config:
        from_attributes = True