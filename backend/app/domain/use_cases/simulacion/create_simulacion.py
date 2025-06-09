from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity

def crear_simulacion_use_case(simulacion: SimulacionEntity, repo: SimulacionRepository) -> SimulacionEntity:
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(simulacion)