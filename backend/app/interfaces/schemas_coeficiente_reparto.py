from pydantic import BaseModel, Field, ConfigDict
from typing import Dict, Any, Optional
from app.domain.entities.tipo_reparto import TipoReparto

class CoeficienteRepartoBase(BaseModel):
    tipoReparto: TipoReparto = Field(description="Tipo de reparto (Reparto Fijo, Reparto Programado)")
    parametros: Dict[str, Any] = Field(description="Parámetros específicos del tipo de reparto en formato JSON")
    idParticipante: int = Field(description="ID del participante al que pertenece este coeficiente")

class CoeficienteRepartoCreate(CoeficienteRepartoBase):
    pass

class CoeficienteRepartoUpdate(BaseModel):
    tipoReparto: Optional[TipoReparto] = None
    parametros: Optional[Dict[str, Any]] = None

class CoeficienteRepartoRead(CoeficienteRepartoBase):
    idCoeficienteReparto: int
    
    model_config = ConfigDict(from_attributes=True)