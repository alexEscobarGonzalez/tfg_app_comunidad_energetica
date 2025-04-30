from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

class DeleteResultadoActivoAlmacenamiento:
    def __init__(self, repository: ResultadoSimulacionActivoAlmacenamientoRepository):
        self.repository = repository
        
    def execute(self, resultado_id: int) -> None:
        return self.repository.delete(resultado_id)