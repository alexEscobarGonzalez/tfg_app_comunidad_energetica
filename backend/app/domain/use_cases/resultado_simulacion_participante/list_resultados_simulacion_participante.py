from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from typing import List

def listar_resultados_simulacion_participante_use_case(repo: ResultadoSimulacionParticipanteRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionParticipanteEntity]:
    
    return repo.list(skip=skip, limit=limit)
