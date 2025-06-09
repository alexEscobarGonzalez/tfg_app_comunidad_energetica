from dataclasses import dataclass
from typing import Optional

@dataclass
class ParticipanteEntity:
    idParticipante: int = None
    nombre: str = None
    idComunidadEnergetica: int = None