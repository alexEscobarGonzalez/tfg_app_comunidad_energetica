from dataclasses import dataclass
from typing import Optional

@dataclass
class ResultadoSimulacionActivoGeneracionEntity:
    idResultadoActivoGen: Optional[int] = None
    energiaTotalGenerada_kWh: Optional[float] = None
    factorCapacidad_pct: Optional[float] = None
    performanceRatio_pct: Optional[float] = None
    horasOperacionEquivalentes: Optional[float] = None
    idResultadoSimulacion: Optional[int] = None
    idActivoGeneracion: Optional[int] = None