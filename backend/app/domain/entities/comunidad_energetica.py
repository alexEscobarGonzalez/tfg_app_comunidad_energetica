from dataclasses import dataclass
from typing import Optional
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes

@dataclass
class ComunidadEnergeticaEntity:
    idComunidadEnergetica: int = None
    nombre: str = None
    latitud: float = None
    longitud: float = None
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes = None
    idUsuario: int = None
