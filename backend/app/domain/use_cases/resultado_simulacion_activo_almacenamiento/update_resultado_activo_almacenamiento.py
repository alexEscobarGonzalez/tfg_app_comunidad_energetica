from typing import Optional
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

class UpdateResultadoActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado_id: int, resultado: ResultadoSimulacionActivoAlmacenamientoEntity) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        return self.repository.update(resultado_id, resultado)