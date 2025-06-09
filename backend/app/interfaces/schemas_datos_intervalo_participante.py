from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class DatosIntervaloParticipanteBase(BaseModel):
    
    timestamp: datetime = Field(..., description="Marca de tiempo del intervalo")
    consumoReal_kWh: Optional[float] = Field(None, description="Consumo real en kWh")
    autoconsumo_kWh: Optional[float] = Field(None, description="Producción propia en kWh")
    energiaRecibidaReparto_kWh: Optional[float] = Field(None, description="Energía recibida por reparto en kWh")
    energiaAlmacenamiento_kWh: Optional[float] = Field(None, description="Energía desde almacenamiento individual en kWh")
    energiaDiferencia_kWh: Optional[float] = Field(None, description="Energía importada desde la red en kWh")
    excedenteVertidoCompensado_kWh: Optional[float] = Field(None, description="Excedente vertido compensado en kWh")
    precioImportacionIntervalo: Optional[float] = Field(None, description="Precio de importación en el intervalo")
    precioExportacionIntervalo: Optional[float] = Field(None, description="Precio de exportación en el intervalo")

class DatosIntervaloParticipanteCreate(DatosIntervaloParticipanteBase):
    
    idResultadoParticipante: int = Field(..., description="ID del resultado del participante")

class DatosIntervaloParticipanteBulkCreate(BaseModel):
    
    datos: list[DatosIntervaloParticipanteCreate] = Field(..., description="Lista de datos de intervalo a crear")

class DatosIntervaloParticipanteUpdate(BaseModel):
    
    timestamp: Optional[datetime] = None
    consumoReal_kWh: Optional[float] = None
    autoconsumo_kWh: Optional[float] = None
    energiaRecibidaReparto_kWh: Optional[float] = None
    energiaAlmacenamiento_kWh: Optional[float] = None
    energiaDiferencia_kWh: Optional[float] = None
    excedenteVertidoCompensado_kWh: Optional[float] = None
    precioImportacionIntervalo: Optional[float] = None
    precioExportacionIntervalo: Optional[float] = None

class DatosIntervaloParticipanteRead(DatosIntervaloParticipanteBase):
    
    idDatosIntervaloParticipante: int
    idResultadoParticipante: int

    class Config:
        from_attributes = True