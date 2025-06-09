from pydantic import BaseModel, Field, model_validator
from typing import Optional, List
from datetime import datetime

class DatosIntervaloActivoBase(BaseModel):
    
    timestamp: datetime = Field(..., description="Marca de tiempo del intervalo")
    energiaGenerada_kWh: Optional[float] = Field(None, description="Energía generada en kWh")
    energiaCargada_kWh: Optional[float] = Field(None, description="Energía cargada en kWh")
    energiaDescargada_kWh: Optional[float] = Field(None, description="Energía descargada en kWh")
    SoC_kWh: Optional[float] = Field(None, description="Estado de carga en kWh")


class DatosIntervaloActivoCreate(DatosIntervaloActivoBase):
    
    idResultadoActivoGen: Optional[int] = Field(None, description="ID del resultado del activo de generación")
    idResultadoActivoAlm: Optional[int] = Field(None, description="ID del resultado del activo de almacenamiento")

    @model_validator(mode='after')
    def validate_at_least_one_activo_present(self) -> 'DatosIntervaloActivoCreate':
        if self.idResultadoActivoGen is None and self.idResultadoActivoAlm is None:
            raise ValueError('Al menos uno de idResultadoActivoGen o idResultadoActivoAlm debe estar presente')
        return self

class DatosIntervaloActivoBulkCreate(BaseModel):
    
    datos: List[DatosIntervaloActivoCreate] = Field(..., description="Lista de datos de intervalo a crear")

class DatosIntervaloActivoUpdate(BaseModel):
    
    timestamp: Optional[datetime] = None
    energiaGenerada_kWh: Optional[float] = None
    energiaCargada_kWh: Optional[float] = None
    energiaDescargada_kWh: Optional[float] = None
    SoC_kWh: Optional[float] = None
    idResultadoActivoGen: Optional[int] = None
    idResultadoActivoAlm: Optional[int] = None

class DatosIntervaloActivoRead(DatosIntervaloActivoBase):
    
    idDatosIntervaloActivo: int
    idResultadoActivoGen: Optional[int] = None
    idResultadoActivoAlm: Optional[int] = None

    class Config:
        from_attributes = True