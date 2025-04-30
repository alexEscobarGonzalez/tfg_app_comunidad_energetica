from typing import List
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

class ListResultadosActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.list(skip=skip, limit=limit)