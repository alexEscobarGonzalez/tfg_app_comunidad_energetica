from typing import Optional, List
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

class GetResultadoActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado_activo_alm_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.get_by_id(resultado_activo_alm_id)

class GetResultadosActivosAlmacenamientoByResultadoSimulacion:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.get_by_resultado_simulacion_id(resultado_simulacion_id)

class GetResultadosActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, activo_almacenamiento_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.get_by_activo_almacenamiento_id(activo_almacenamiento_id)

class GetResultadoBySimulacionAndActivo:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado_simulacion_id: int, activo_almacenamiento_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.get_by_resultado_simulacion_and_activo(resultado_simulacion_id, activo_almacenamiento_id)