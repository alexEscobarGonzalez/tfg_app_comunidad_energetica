from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from typing import List

def listar_resultados_activo_almacenamiento_use_case(repo: ResultadoSimulacionActivoAlmacenamientoRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    """
    Lista todos los resultados de simulación de activo de almacenamiento
    Args:
        repo: Repositorio de resultados de simulación de activo de almacenamiento
        skip: Número de resultados a omitir
        limit: Límite de resultados
    Returns:
        List[ResultadoSimulacionActivoAlmacenamientoEntity]: Lista de resultados
    """
    return repo.list(skip=skip, limit=limit)