from typing import List, Optional
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository

class ResultadoSimulacionActivoGeneracionUseCases:
    def __init__(self, repository: ResultadoSimulacionActivoGeneracionRepository):
        self.repository = repository
    
    def get_by_id(self, resultado_activo_gen_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        return self.repository.get_by_id(resultado_activo_gen_id)
    
    def get_by_resultado_simulacion_id(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        return self.repository.get_by_resultado_simulacion_id(resultado_simulacion_id)
    
    def get_by_activo_generacion_id(self, activo_generacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        return self.repository.get_by_activo_generacion_id(activo_generacion_id)
    
    def get_by_resultado_simulacion_and_activo(self, resultado_simulacion_id: int, activo_generacion_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        return self.repository.get_by_resultado_simulacion_and_activo(resultado_simulacion_id, activo_generacion_id)
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        return self.repository.list(skip, limit)
    
    def create(self, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        return self.repository.create(resultado_activo_gen)
    
    def update(self, resultado_activo_gen_id: int, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        return self.repository.update(resultado_activo_gen_id, resultado_activo_gen)
    
    def delete(self, resultado_activo_gen_id: int) -> None:
        self.repository.delete(resultado_activo_gen_id)