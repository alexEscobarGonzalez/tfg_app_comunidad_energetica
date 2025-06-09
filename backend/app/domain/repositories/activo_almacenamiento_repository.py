from typing import List, Optional
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity

class ActivoAlmacenamientoRepository:
    def get_by_id(self, activo_id: int) -> Optional[ActivoAlmacenamientoEntity]:
        raise NotImplementedError

    def get_by_comunidad(self, comunidad_id: int) -> List[ActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ActivoAlmacenamientoEntity]:
        raise NotImplementedError

    def create(self, activo: ActivoAlmacenamientoEntity) -> ActivoAlmacenamientoEntity:
        raise NotImplementedError

    def update(self, activo_id: int, activo: ActivoAlmacenamientoEntity) -> ActivoAlmacenamientoEntity:
        raise NotImplementedError

    def delete(self, activo_id: int) -> None:
        raise NotImplementedError