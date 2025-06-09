from dataclasses import dataclass
from datetime import datetime

@dataclass
class RegistroConsumoEntity:
    idRegistroConsumo: int = None
    timestamp: datetime = None
    consumoEnergia: float = None
    idParticipante: int = None