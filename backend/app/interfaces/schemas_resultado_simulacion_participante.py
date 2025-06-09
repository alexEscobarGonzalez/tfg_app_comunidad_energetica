from pydantic import BaseModel, Field, ConfigDict
from typing import Optional

class ResultadoSimulacionParticipanteBase(BaseModel):
    costeNetoParticipante_eur: Optional[float] = Field(None, description="Coste neto de energía para el participante (€)")
    ahorroParticipante_eur: Optional[float] = Field(None, description="Ahorro económico para el participante (€)")
    ahorroParticipante_pct: Optional[float] = Field(None, ge=0.0, le=100.0, description="Ahorro económico para el participante (%)")
    energiaAutoconsumidaDirecta_kWh: Optional[float] = Field(None, ge=0.0, description="Energía generada por el participante y autoconsumida directamente (kWh)")
    energiaRecibidaRepartoConsumida_kWh: Optional[float] = Field(None, ge=0.0, description="Energía recibida por reparto y consumida por el participante (kWh)")
    tasaAutoconsumoSCR_pct: Optional[float] = Field(None, ge=0.0, le=100.0, description="Tasa de autoconsumo individual (SCR) (%)")
    tasaAutosuficienciaSSR_pct: Optional[float] = Field(None, ge=0.0, le=100.0, description="Tasa de autosuficiencia individual (SSR) (%)")
    consumo_kWh: Optional[float] = Field(None, ge=0.0, description="Suma total del consumo durante la simulación (kWh)")
    idResultadoSimulacion: int = Field(..., description="ID del resultado de simulación global asociado")
    idParticipante: int = Field(..., description="ID del participante asociado")

class ResultadoSimulacionParticipanteCreate(ResultadoSimulacionParticipanteBase):
    pass

class ResultadoSimulacionParticipanteUpdate(BaseModel):
    costeNetoParticipante_eur: Optional[float] = Field(None)
    ahorroParticipante_eur: Optional[float] = Field(None)
    ahorroParticipante_pct: Optional[float] = Field(None, ge=0.0, le=100.0)
    energiaAutoconsumidaDirecta_kWh: Optional[float] = Field(None, ge=0.0)
    energiaRecibidaRepartoConsumida_kWh: Optional[float] = Field(None, ge=0.0)
    tasaAutoconsumoSCR_pct: Optional[float] = Field(None, ge=0.0, le=100.0)
    tasaAutosuficienciaSSR_pct: Optional[float] = Field(None, ge=0.0, le=100.0)
    consumo_kWh: Optional[float] = Field(None, ge=0.0)
    # Los FKs no se suelen actualizar

class ResultadoSimulacionParticipanteRead(ResultadoSimulacionParticipanteBase):
    idResultadoParticipante: int

    model_config = ConfigDict(from_attributes=True) # Compatible con Pydantic v2