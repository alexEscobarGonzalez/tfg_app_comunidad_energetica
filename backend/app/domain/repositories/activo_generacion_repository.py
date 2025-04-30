from typing import List, Optional
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion

class ActivoGeneracionRepository:
    def get_by_id(self, activo_id: int) -> Optional[ActivoGeneracionEntity]:
        raise NotImplementedError

    def get_by_comunidad(self, comunidad_id: int) -> List[ActivoGeneracionEntity]:
        raise NotImplementedError
    
    def get_by_comunidad_y_tipo(self, comunidad_id: int, tipo_activo: TipoActivoGeneracion) -> List[ActivoGeneracionEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ActivoGeneracionEntity]:
        raise NotImplementedError

    def create(self, activo: ActivoGeneracionEntity) -> ActivoGeneracionEntity:
        raise NotImplementedError

    def update(self, activo_id: int, activo: ActivoGeneracionEntity) -> ActivoGeneracionEntity:
        raise NotImplementedError

    def delete(self, activo_id: int) -> None:
        raise NotImplementedError