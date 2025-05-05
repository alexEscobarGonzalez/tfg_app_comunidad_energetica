from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class DatosIntervaloParticipanteBase(BaseModel):
    """Clase base para los esquemas de datos de intervalo por participante"""
    timestamp: datetime = Field(..., description="Marca de tiempo del intervalo")
    consumoReal_kWh: Optional[float] = Field(None, description="Consumo real en kWh")
    produccionPropia_kWh: Optional[float] = Field(None, description="Producción propia en kWh")
    energiaRecibidaReparto_kWh: Optional[float] = Field(None, description="Energía recibida por reparto en kWh")
    energiaDesdeAlmacenamientoInd_kWh: Optional[float] = Field(None, description="Energía desde almacenamiento individual en kWh")
    energiaHaciaAlmacenamientoInd_kWh: Optional[float] = Field(None, description="Energía hacia almacenamiento individual en kWh")
    energiaDesdeRed_kWh: Optional[float] = Field(None, description="Energía importada desde la red en kWh")
    excedenteVertidoCompensado_kWh: Optional[float] = Field(None, description="Excedente vertido compensado en kWh")
    estadoAlmacenamientoInd_kWh: Optional[float] = Field(None, description="Estado del almacenamiento individual en kWh")
    precioImportacionIntervalo: Optional[float] = Field(None, description="Precio de importación en el intervalo")
    precioExportacionIntervalo: Optional[float] = Field(None, description="Precio de exportación en el intervalo")

class DatosIntervaloParticipanteCreate(DatosIntervaloParticipanteBase):
    """Esquema para crear nuevos datos de intervalo por participante"""
    idResultadoParticipante: int = Field(..., description="ID del resultado del participante")

class DatosIntervaloParticipanteBulkCreate(BaseModel):
    """Esquema para crear múltiples datos de intervalo por participante en una sola operación"""
    datos: list[DatosIntervaloParticipanteCreate] = Field(..., description="Lista de datos de intervalo a crear")

class DatosIntervaloParticipanteUpdate(BaseModel):
    """Esquema para actualizar datos existentes"""
    timestamp: Optional[datetime] = None
    consumoReal_kWh: Optional[float] = None
    produccionPropia_kWh: Optional[float] = None
    energiaRecibidaReparto_kWh: Optional[float] = None
    energiaDesdeAlmacenamientoInd_kWh: Optional[float] = None
    energiaHaciaAlmacenamientoInd_kWh: Optional[float] = None
    energiaDesdeRed_kWh: Optional[float] = None
    excedenteVertidoCompensado_kWh: Optional[float] = None
    estadoAlmacenamientoInd_kWh: Optional[float] = None
    precioImportacionIntervalo: Optional[float] = None
    precioExportacionIntervalo: Optional[float] = None

class DatosIntervaloParticipanteRead(DatosIntervaloParticipanteBase):
    """Esquema para la respuesta de datos de intervalo por participante"""
    idDatosIntervaloParticipante: int
    idResultadoParticipante: int

    class Config:
        from_attributes = True