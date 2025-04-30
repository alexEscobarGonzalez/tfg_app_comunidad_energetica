from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository

class DeleteResultadoSimulacion:
    def __init__(self, resultado_repository: ResultadoSimulacionRepository):
        self.resultado_repository = resultado_repository
    
    def execute(self, resultado_id: int) -> None:
        return self.resultado_repository.delete(resultado_id)