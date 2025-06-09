from typing import Dict, List, Optional
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity

class ResultadoSimulacionActivoAlmacenamientoRepository:
    def get_by_id(self, resultado_activo_alm_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def get_by_resultado_simulacion_id(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def get_by_activo_almacenamiento_id(self, activo_almacenamiento_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def get_by_resultado_simulacion_and_activo(self, resultado_simulacion_id: int, activo_almacenamiento_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError
    
    def create(self, resultado_activo_alm: ResultadoSimulacionActivoAlmacenamientoEntity) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        raise NotImplementedError
    
    def update(self, resultado_activo_alm_id: int, resultado_activo_alm: ResultadoSimulacionActivoAlmacenamientoEntity) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        raise NotImplementedError
    
    def delete(self, resultado_activo_alm_id: int) -> None:
        raise NotImplementedError
    
    def create_bulk(self, resultados: List[ResultadoSimulacionActivoAlmacenamientoEntity], resultado_global_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        raise NotImplementedError