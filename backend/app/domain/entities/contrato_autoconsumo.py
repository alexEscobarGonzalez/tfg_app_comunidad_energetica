from dataclasses import dataclass
from typing import Optional
from app.domain.entities.tipo_contrato import TipoContrato

@dataclass
class ContratoAutoconsumoEntity:
    idContrato: int = None
    tipoContrato: TipoContrato = None
    precioEnergiaImportacion_eur_kWh: float = None
    precioCompensacionExcedentes_eur_kWh: float = None
    potenciaContratada_kW: float = None
    precioPotenciaContratado_eur_kWh: float = None
    idParticipante: int = None