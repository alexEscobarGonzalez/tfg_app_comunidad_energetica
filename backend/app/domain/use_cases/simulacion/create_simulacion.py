from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity

def crear_simulacion_use_case(simulacion: SimulacionEntity, repo: SimulacionRepository) -> SimulacionEntity:
    """
    Crea una nueva simulación
    Args:
        simulacion: Entidad con los datos de la nueva simulación
        repo: Repositorio de simulaciones
    Returns:
        SimulacionEntity: La entidad creada con su ID asignado
    """
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(simulacion)