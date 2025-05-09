from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository

def eliminar_simulacion_use_case(simulacion_id: int, repo: SimulacionRepository) -> dict:
    """
    Elimina una simulación existente
    Args:
        simulacion_id: ID de la simulación a eliminar
        repo: Repositorio de simulaciones
    Returns:
        dict: Mensaje de confirmación
    Raises:
        HTTPException: Si la simulación no existe
    """
    simulacion_existente = repo.get_by_id(simulacion_id)
    if not simulacion_existente:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    repo.delete(simulacion_id)
    return {"mensaje": f"Simulación con ID {simulacion_id} eliminada correctamente"}