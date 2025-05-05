from typing import List, Optional
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity

class ResultadoSimulacionActivoGeneracionRepository:
    def get_by_id(self, resultado_activo_gen_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError
    
    def get_by_resultado_simulacion_id(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError
    
    def get_by_activo_generacion_id(self, activo_generacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError
    
    def get_by_resultado_simulacion_and_activo(self, resultado_simulacion_id: int, activo_generacion_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError
    
    def create(self, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        raise NotImplementedError
    
    def update(self, resultado_activo_gen_id: int, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        raise NotImplementedError
    
    def delete(self, resultado_activo_gen_id: int) -> None:
        raise NotImplementedError
    
    def create_bulk(self, resultados: List[ResultadoSimulacionActivoGeneracionEntity]) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        raise NotImplementedError