from dataclasses import dataclass
from typing import Optional

@dataclass
class ResultadoSimulacionParticipanteEntity:
    idResultadoParticipante: Optional[int] = None
    costeNetoParticipante_eur: Optional[float] = None
    ahorroParticipante_eur: Optional[float] = None
    ahorroParticipante_pct: Optional[float] = None
    energiaAutoconsumidaDirecta_kWh: Optional[float] = None
    energiaRecibidaRepartoConsumida_kWh: Optional[float] = None
    tasaAutoconsumoSCR_pct: Optional[float] = None
    tasaAutosuficienciaSSR_pct: Optional[float] = None
    consumo_kWh: Optional[float] = None
    idResultadoSimulacion: Optional[int] = None
    idParticipante: Optional[int] = None