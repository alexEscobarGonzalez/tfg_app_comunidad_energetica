from dataclasses import dataclass
from datetime import datetime

@dataclass
class RegistroConsumoEntity:
    """
    Entidad que representa un registro de consumo energético de un participante
    """
    idRegistroConsumo: int = None
    timestamp: datetime = None
    consumoEnergia: float = None
    idParticipante: int = None