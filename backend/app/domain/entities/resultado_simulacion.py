from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass
class ResultadoSimulacionEntity:
    idResultado: Optional[int] = None
    fechaCreacion: Optional[datetime] = None
    costeTotalEnergia_eur: Optional[float] = None
    ahorroTotal_eur: Optional[float] = None
    ingresoTotalExportacion_eur: Optional[float] = None
    paybackPeriod_anios: Optional[float] = None
    roi_pct: Optional[float] = None
    tasaAutoconsumoSCR_pct: Optional[float] = None
    tasaAutosuficienciaSSR_pct: Optional[float] = None
    energiaTotalImportada_kWh: Optional[float] = None
    energiaTotalExportada_kWh: Optional[float] = None
    reduccionCO2_kg: Optional[float] = None
    idSimulacion: Optional[int] = None