from typing import List, Optional
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity

class ResultadoSimulacionParticipanteRepository:
    def get_by_id(self, resultado_participante_id: int) -> Optional[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def get_by_resultado_simulacion(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def get_by_participante(self, participante_id: int) -> List[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def get_by_resultado_and_participante(self, resultado_simulacion_id: int, participante_id: int) -> Optional[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def create(self, resultado: ResultadoSimulacionParticipanteEntity) -> ResultadoSimulacionParticipanteEntity:
        raise NotImplementedError

    def update(self, resultado_participante_id: int, resultado: ResultadoSimulacionParticipanteEntity) -> Optional[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError

    def delete(self, resultado_participante_id: int) -> None:
        raise NotImplementedError

    def delete_by_resultado_simulacion(self, resultado_simulacion_id: int) -> None:
        raise NotImplementedError
    
    def create_bulk(self, resultados: List[ResultadoSimulacionParticipanteEntity], resultado_global_id: int) -> List[ResultadoSimulacionParticipanteEntity]:
        raise NotImplementedError