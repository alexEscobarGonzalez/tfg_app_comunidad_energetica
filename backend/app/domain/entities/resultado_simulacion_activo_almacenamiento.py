from dataclasses import dataclass
from typing import Optional

@dataclass
class ResultadoSimulacionActivoAlmacenamientoEntity:
    idResultadoActivoAlm: Optional[int] = None
    energiaTotalCargada_kWh: Optional[float] = None
    energiaTotalDescargada_kWh: Optional[float] = None
    ciclosEquivalentes: Optional[float] = None
    perdidasEficiencia_kWh: Optional[float] = None
    socMedio_pct: Optional[float] = None
    socMin_pct: Optional[float] = None
    socMax_pct: Optional[float] = None
    degradacionEstimada_pct: Optional[float] = None
    throughputTotal_kWh: Optional[float] = None
    idResultadoSimulacion: Optional[int] = None
    idActivoAlmacenamiento: Optional[int] = None