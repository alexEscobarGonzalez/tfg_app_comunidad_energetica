from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import Optional

class GetSimulacion:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, simulacion_id: int) -> Optional[SimulacionEntity]:
        return self.simulacion_repository.get_by_id(simulacion_id)