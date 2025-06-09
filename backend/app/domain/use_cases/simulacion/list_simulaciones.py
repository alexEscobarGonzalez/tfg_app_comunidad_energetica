from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import List

def listar_simulaciones_use_case(repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    return repo.list(skip=skip, limit=limit)

def listar_simulaciones_por_comunidad_use_case(comunidad_id: int, repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    return repo.list_by_comunidad(comunidad_id, skip=skip, limit=limit)

def listar_simulaciones_por_usuario_use_case(usuario_id: int, repo: SimulacionRepository, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
    return repo.list_by_usuario(usuario_id, skip=skip, limit=limit)