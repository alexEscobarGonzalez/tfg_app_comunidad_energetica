from pydantic import BaseModel, ConfigDict
from typing import Optional

class ParticipanteBase(BaseModel):
    nombre: str
    idComunidadEnergetica: int

class ParticipanteCreate(ParticipanteBase):
    pass

class ParticipanteUpdate(BaseModel):
    nombre: str

class ParticipanteRead(ParticipanteBase):
    idParticipante: int
    model_config = ConfigDict(from_attributes=True)