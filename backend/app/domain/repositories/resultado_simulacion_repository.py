from typing import List, Optional
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity

class ResultadoSimulacionRepository:
    def get_by_id(self, resultado_id: int) -> Optional[ResultadoSimulacionEntity]:
        raise NotImplementedError
    
    def get_by_simulacion_id(self, simulacion_id: int) -> Optional[ResultadoSimulacionEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionEntity]:
        raise NotImplementedError
    
    def create(self, resultado: ResultadoSimulacionEntity) -> ResultadoSimulacionEntity:
        raise NotImplementedError
    
    def update(self, resultado_id: int, resultado: ResultadoSimulacionEntity) -> ResultadoSimulacionEntity:
        raise NotImplementedError
    
    def delete(self, resultado_id: int) -> None:
        raise NotImplementedError