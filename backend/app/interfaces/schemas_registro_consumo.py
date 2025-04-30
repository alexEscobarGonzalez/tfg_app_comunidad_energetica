from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional

class RegistroConsumoBase(BaseModel):
    timestamp: datetime = Field(description="Fecha y hora del registro de consumo")
    consumoEnergia: float = Field(description="Consumo de energía en kWh", gt=0)
    idParticipante: int = Field(description="ID del participante al que corresponde este consumo")

class RegistroConsumoCreate(RegistroConsumoBase):
    pass

class RegistroConsumoUpdate(BaseModel):
    timestamp: Optional[datetime] = None
    consumoEnergia: Optional[float] = Field(None, gt=0)
    # No se permite actualizar el idParticipante

class RegistroConsumoRead(RegistroConsumoBase):
    idRegistroConsumo: int
    
    model_config = ConfigDict(from_attributes=True)