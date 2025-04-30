from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from typing import Optional

class GetResultadoSimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, resultado_id: int) -> Optional[ResultadoSimulacionEntity]:
        return self.resultado_repository.get_by_id(resultado_id)

class GetResultadoBySimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, simulacion_id: int) -> Optional[ResultadoSimulacionEntity]:
        return self.resultado_repository.get_by_simulacion_id(simulacion_id)