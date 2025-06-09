from dataclasses import dataclass
from typing import Optional
from datetime import datetime

@dataclass
class DatosAmbientalesEntity:
    idRegistro: int = None
    timestamp: datetime = None
    fuenteDatos: str = None
    radiacionGlobalHoriz_Wh_m2: float = None
    temperaturaAmbiente_C: float = None
    velocidadViento_m_s: float = None
    idSimulacion: int = None