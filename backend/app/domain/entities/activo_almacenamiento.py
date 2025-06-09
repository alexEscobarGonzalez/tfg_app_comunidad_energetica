from dataclasses import dataclass
from typing import Optional
from datetime import datetime

@dataclass
class ActivoAlmacenamientoEntity:
    idActivoAlmacenamiento: Optional[int] = None
    nombreDescriptivo: Optional[str] = None
    capacidadNominal_kWh: Optional[float] = None
    potenciaMaximaCarga_kW: Optional[float] = None
    potenciaMaximaDescarga_kW: Optional[float] = None
    eficienciaCicloCompleto_pct: Optional[float] = None
    profundidadDescargaMax_pct: Optional[float] = None
    idComunidadEnergetica: Optional[int] = None
    esta_activo: Optional[bool] = True
    fecha_eliminacion: Optional[datetime] = None