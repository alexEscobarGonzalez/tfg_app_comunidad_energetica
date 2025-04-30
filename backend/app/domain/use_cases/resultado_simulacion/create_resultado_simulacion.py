from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity

class CreateResultadoSimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, resultado: ResultadoSimulacionEntity) -> ResultadoSimulacionEntity:
        return self.resultado_repository.create(resultado)