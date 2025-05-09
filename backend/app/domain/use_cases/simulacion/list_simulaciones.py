from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import List

def listar_simulaciones_use_case(repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    """
    Lista todas las simulaciones
    Args:
        repo: Repositorio de simulaciones
        skip: Número de simulaciones a omitir
        limit: Límite de simulaciones
    Returns:
        List[SimulacionEntity]: Lista de simulaciones
    """
    return repo.list(skip=skip, limit=limit)

def listar_simulaciones_por_comunidad_use_case(comunidad_id: int, repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    """
    Lista todas las simulaciones de una comunidad energética
    Args:
        comunidad_id: ID de la comunidad energética
        repo: Repositorio de simulaciones
        skip: Número de simulaciones a omitir
        limit: Límite de simulaciones
    Returns:
        List[SimulacionEntity]: Lista de simulaciones
    """
    return repo.list_by_comunidad(comunidad_id, skip=skip, limit=limit)

def listar_simulaciones_por_usuario_use_case(usuario_id: int, repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    """
    Lista todas las simulaciones creadas por un usuario
    Args:
        usuario_id: ID del usuario
        repo: Repositorio de simulaciones
        skip: Número de simulaciones a omitir
        limit: Límite de simulaciones
    Returns:
        List[SimulacionEntity]: Lista de simulaciones
    """
    return repo.list_by_usuario(usuario_id, skip=skip, limit=limit)