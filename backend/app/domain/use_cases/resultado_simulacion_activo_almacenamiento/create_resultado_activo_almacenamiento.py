from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

class CreateResultadoActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado: ResultadoSimulacionActivoAlmacenamientoEntity) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        return self.repository.create(resultado)