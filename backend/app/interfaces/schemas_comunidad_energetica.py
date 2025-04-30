from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes

class ComunidadEnergeticaBase(BaseModel):
    nombre: str
    latitud: float
    longitud: float
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes
    idUsuario: int

class ComunidadEnergeticaCreate(ComunidadEnergeticaBase):
    pass

class ComunidadEnergeticaUpdate(BaseModel):
    nombre: str
    latitud: float
    longitud: float
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes

class ComunidadEnergeticaRead(ComunidadEnergeticaBase):
    idComunidadEnergetica: int
    model_config = ConfigDict(from_attributes=True)

class UsuarioRead(BaseModel):
    id: int
    nombre: str
    model_config = ConfigDict(from_attributes=True)

class ComunidadEnergeticaWithUsuarios(ComunidadEnergeticaRead):
    usuarios: Optional[List[UsuarioRead]] = []
