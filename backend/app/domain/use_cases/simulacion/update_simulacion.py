from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import Optional

class UpdateSimulacion:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, simulacion_id: int, simulacion: SimulacionEntity) -> Optional[SimulacionEntity]:
        return self.simulacion_repository.update(simulacion_id, simulacion)

class UpdateEstadoSimulacion:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, simulacion_id: int, estado: str) -> Optional[SimulacionEntity]:
        return self.simulacion_repository.update_estado(simulacion_id, estado)