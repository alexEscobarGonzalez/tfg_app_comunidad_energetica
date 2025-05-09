from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from typing import List

def listar_resultados_activo_generacion_use_case(repo: ResultadoSimulacionActivoGeneracionRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoGeneracionEntity]:
    """
    Lista todos los resultados de simulación de activo de generación
    Args:
        repo: Repositorio de resultados de simulación de activo de generación
        skip: Número de resultados a omitir
        limit: Límite de resultados
    Returns:
        List[ResultadoSimulacionActivoGeneracionEntity]: Lista de resultados
    """
    return repo.list(skip=skip, limit=limit)