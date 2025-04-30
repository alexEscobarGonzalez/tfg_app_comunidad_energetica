from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from typing import List

class ListResultadosSimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionEntity]:
        return self.resultado_repository.list(skip=skip, limit=limit)