from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime

class DatosIntervaloActivoBase(BaseModel):
    """Clase base para los esquemas de datos de intervalo por activo"""
    timestamp: datetime = Field(..., description="Marca de tiempo del intervalo")
    energiaGenerada_kWh: Optional[float] = Field(None, description="Energía generada en kWh")
    energiaCargada_kWh: Optional[float] = Field(None, description="Energía cargada en kWh")
    energiaDescargada_kWh: Optional[float] = Field(None, description="Energía descargada en kWh")
    SoC_kWh: Optional[float] = Field(None, description="Estado de carga en kWh")

    @validator('energiaGenerada_kWh', 'energiaCargada_kWh', 'energiaDescargada_kWh', 'SoC_kWh')
    def validate_non_negative(cls, v):
        if v is not None and v < 0:
            raise ValueError('Los valores de energía no pueden ser negativos')
        return v

class DatosIntervaloActivoCreate(DatosIntervaloActivoBase):
    """Esquema para crear nuevos datos de intervalo por activo"""
    idResultadoActivoGen: Optional[int] = Field(None, description="ID del resultado del activo de generación")
    idResultadoActivoAlm: Optional[int] = Field(None, description="ID del resultado del activo de almacenamiento")

    @validator('idResultadoActivoGen', 'idResultadoActivoAlm')
    def validate_at_least_one_activo(cls, v, values):
        if v is None and 'idResultadoActivoAlm' in values and 'idResultadoActivoGen' in values:
            if (values['idResultadoActivoAlm'] is None and values['idResultadoActivoGen'] is None):
                raise ValueError('Al menos uno de idResultadoActivoGen o idResultadoActivoAlm debe estar presente')
        return v

class DatosIntervaloActivoBulkCreate(BaseModel):
    """Esquema para crear múltiples datos de intervalo por activo en una sola operación"""
    datos: List[DatosIntervaloActivoCreate] = Field(..., description="Lista de datos de intervalo a crear")

class DatosIntervaloActivoUpdate(BaseModel):
    """Esquema para actualizar datos existentes"""
    timestamp: Optional[datetime] = None
    energiaGenerada_kWh: Optional[float] = None
    energiaCargada_kWh: Optional[float] = None
    energiaDescargada_kWh: Optional[float] = None
    SoC_kWh: Optional[float] = None
    idResultadoActivoGen: Optional[int] = None
    idResultadoActivoAlm: Optional[int] = None

class DatosIntervaloActivoRead(DatosIntervaloActivoBase):
    """Esquema para la respuesta de datos de intervalo por activo"""
    idDatosIntervaloActivo: int
    idResultadoActivoGen: Optional[int] = None
    idResultadoActivoAlm: Optional[int] = None

    class Config:
        from_attributes = True