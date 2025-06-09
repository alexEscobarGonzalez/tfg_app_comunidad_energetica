from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from typing import Optional

def mostrar_simulacion_use_case(simulacion_id: int, repo: SimulacionRepository) -> SimulacionEntity:
    simulacion = repo.get_by_id(simulacion_id)
    if not simulacion:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    return simulacion