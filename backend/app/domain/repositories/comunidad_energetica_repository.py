from typing import List, Optional
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes

class ComunidadEnergeticaRepository:
    def get_by_id(self, comunidad_id: int) -> Optional[ComunidadEnergeticaEntity]:
        raise NotImplementedError

    def list(self, skip: int = 0, limit: int = 100) -> List[ComunidadEnergeticaEntity]:
        raise NotImplementedError

    def create(self, comunidad: ComunidadEnergeticaEntity) -> ComunidadEnergeticaEntity:
        raise NotImplementedError

    def update(self, comunidad_id: int, comunidad: ComunidadEnergeticaEntity) -> ComunidadEnergeticaEntity:
        raise NotImplementedError

    def delete(self, comunidad_id: int) -> None:
        raise NotImplementedError
