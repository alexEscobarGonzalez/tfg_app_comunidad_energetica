from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional

class DatosAmbientalesBase(BaseModel):
    timestamp: datetime = Field(description="Fecha y hora del registro")
    fuenteDatos: Optional[str] = Field(None, description="Fuente de los datos (e.g., PVGIS, AEMET, Sensor)")
    radiacionGlobalHoriz_Wh_m2: Optional[float] = Field(None, description="Radiación global horizontal en Wh/m2")
    temperaturaAmbiente_C: Optional[float] = Field(None, description="Temperatura ambiente en grados Celsius")
    velocidadViento_m_s: Optional[float] = Field(None, description="Velocidad del viento en m/s")
    idSimulacion: int = Field(description="ID de la simulación a la que pertenecen estos datos")

class DatosAmbientalesCreate(DatosAmbientalesBase):
    pass

class DatosAmbientalesRead(DatosAmbientalesBase):
    idRegistro: int

    model_config = ConfigDict(from_attributes=True)

# No se definen esquemas Update/Delete ya que no son operaciones comunes para estos datos