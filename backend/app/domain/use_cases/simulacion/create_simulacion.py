from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity

class CreateSimulacion:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, simulacion: SimulacionEntity) -> SimulacionEntity:
        return self.simulacion_repository.create(simulacion)