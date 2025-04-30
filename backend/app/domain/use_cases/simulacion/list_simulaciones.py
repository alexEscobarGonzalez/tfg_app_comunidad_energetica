from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import List

class ListSimulaciones:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        return self.simulacion_repository.list(skip=skip, limit=limit)

class ListSimulacionesByComunidad:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, comunidad_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        return self.simulacion_repository.list_by_comunidad(comunidad_id=comunidad_id, skip=skip, limit=limit)

class ListSimulacionesByUsuario:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, usuario_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        return self.simulacion_repository.list_by_usuario(usuario_id=usuario_id, skip=skip, limit=limit)