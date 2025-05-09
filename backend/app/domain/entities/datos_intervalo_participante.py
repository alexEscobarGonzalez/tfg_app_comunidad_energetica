from dataclasses import dataclass
from typing import Optional
from datetime import datetime

@dataclass
class DatosIntervaloParticipanteEntity:
    idDatosIntervaloParticipante: Optional[int] = None
    timestamp: Optional[datetime] = None
    consumoReal_kWh: Optional[float] = None
    autoconsumo_kWh: Optional[float] = None
    energiaRecibidaReparto_kWh: Optional[float] = None
    energiaAlmacenamiento_kWh: Optional[float] = None
    energiaDiferencia_kWh: Optional[float] = None
    excedenteVertidoCompensado_kWh: Optional[float] = None
    precioImportacionIntervalo: Optional[float] = None
    precioExportacionIntervalo: Optional[float] = None
    idResultadoParticipante: Optional[int] = None
    