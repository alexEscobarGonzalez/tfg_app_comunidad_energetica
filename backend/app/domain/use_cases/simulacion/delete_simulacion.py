from app.domain.repositories.simulacion_repository import SimulacionRepository

class DeleteSimulacion:
    def __init__(self, simulacion_repository: SimulacionRepository):
        self.simulacion_repository = simulacion_repository
    
    def execute(self, simulacion_id: int) -> None:
        return self.simulacion_repository.delete(simulacion_id)