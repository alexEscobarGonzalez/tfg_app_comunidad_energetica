from dataclasses import dataclass
from typing import Optional

@dataclass
class ActivoAlmacenamientoEntity:
    idActivoAlmacenamiento: int = None
    capacidadNominal_kWh: float = None
    potenciaMaximaCarga_kW: float = None
    potenciaMaximaDescarga_kW: float = None
    eficienciaCicloCompleto_pct: float = None
    profundidadDescargaMax_pct: float = None
    idComunidadEnergetica: int = None