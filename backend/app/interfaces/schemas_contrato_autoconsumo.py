from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from app.domain.entities.tipo_contrato import TipoContrato

class ContratoAutoconsumoBase(BaseModel):
    tipoContrato: TipoContrato
    precioEnergiaImportacion_eur_kWh: float = Field(ge=0.0, description="Precio de la energía importada en €/kWh")
    precioCompensacionExcedentes_eur_kWh: float = Field(ge=0.0, description="Precio de compensación de excedentes en €/kWh")
    potenciaContratada_kW: float = Field(gt=0.0, description="Potencia contratada en kW")
    precioPotenciaContratado_eur_kWh: float = Field(ge=0.0, description="Precio de la potencia contratada en €/kWh")
    idParticipante: int

class ContratoAutoconsumoCreate(ContratoAutoconsumoBase):
    pass

class ContratoAutoconsumoUpdate(BaseModel):
    tipoContrato: Optional[TipoContrato] = None
    precioEnergiaImportacion_eur_kWh: Optional[float] = Field(None, ge=0.0)
    precioCompensacionExcedentes_eur_kWh: Optional[float] = Field(None, ge=0.0)
    potenciaContratada_kW: Optional[float] = Field(None, gt=0.0)
    precioPotenciaContratado_eur_kWh: Optional[float] = Field(None, ge=0.0)

class ContratoAutoconsumoRead(ContratoAutoconsumoBase):
    idContrato: int
    
    model_config = ConfigDict(from_attributes=True)