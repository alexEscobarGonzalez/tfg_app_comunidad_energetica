from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from typing import Optional

class UpdateResultadoSimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, resultado_id: int, resultado: ResultadoSimulacionEntity) -> Optional[ResultadoSimulacionEntity]:
        return self.resultado_repository.update(resultado_id, resultado)