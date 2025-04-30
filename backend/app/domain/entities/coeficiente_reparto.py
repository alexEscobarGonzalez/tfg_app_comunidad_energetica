from dataclasses import dataclass
from typing import Dict, Any
from app.domain.entities.tipo_reparto import TipoReparto

@dataclass
class CoeficienteRepartoEntity:
    idCoeficienteReparto: int = None
    tipoReparto: TipoReparto = None
    parametros: Dict[str, Any] = None
    idParticipante: int = None