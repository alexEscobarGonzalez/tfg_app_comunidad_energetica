from dataclasses import dataclass
from typing import Optional
from datetime import datetime

@dataclass
class DatosIntervaloActivoEntity:
    idDatosIntervaloActivo: Optional[int] = None
    timestamp: Optional[datetime] = None
    energiaGenerada_kWh: Optional[float] = None
    energiaCargada_kWh: Optional[float] = None
    energiaDescargada_kWh: Optional[float] = None
    SoC_kWh: Optional[float] = None
    idResultadoActivoGen: Optional[int] = None
    idResultadoActivoAlm: Optional[int] = None