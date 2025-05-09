from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from typing import List

def listar_resultados_simulacion_participante_use_case(repo: ResultadoSimulacionParticipanteRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionParticipanteEntity]:
    """
    Lista todos los resultados de simulación de participante
    Args:
        repo: Repositorio de resultados de simulación de participante
        skip: Número de resultados a omitir
        limit: Límite de resultados
    Returns:
        List[ResultadoSimulacionParticipanteEntity]: Lista de resultados
    """
    return repo.list(skip=skip, limit=limit)
