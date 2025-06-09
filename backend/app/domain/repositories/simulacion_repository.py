from typing import List, Optional
from app.domain.entities.simulacion import SimulacionEntity

class SimulacionRepository:
    def get_by_id(self, simulacion_id: int) -> Optional[SimulacionEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        raise NotImplementedError
    
    def list_by_comunidad(self, comunidad_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        raise NotImplementedError
    
    def list_by_usuario(self, usuario_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        raise NotImplementedError
    
    def create(self, simulacion: SimulacionEntity) -> SimulacionEntity:
        raise NotImplementedError
    
    def update(self, simulacion_id: int, simulacion: SimulacionEntity) -> SimulacionEntity:
        raise NotImplementedError
    
    def update_estado(self, simulacion_id: int, estado: str) -> SimulacionEntity:
        raise NotImplementedError
    
    def delete(self, simulacion_id: int) -> None:
        raise NotImplementedError