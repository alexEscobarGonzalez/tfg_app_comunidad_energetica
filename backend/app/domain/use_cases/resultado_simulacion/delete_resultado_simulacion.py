from fastapi import HTTPException
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository

def eliminar_resultado_simulacion_use_case(id_resultado: int, repo: ResultadoSimulacionRepository) -> dict:
    """
    Elimina un resultado de simulación existente
    Args:
        id_resultado: ID del resultado a eliminar
        repo: Repositorio de resultados de simulación
    Returns:
        dict: Mensaje de confirmación
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación no encontrado")
    repo.delete(id_resultado)
    return {"mensaje": f"Resultado de simulación con ID {id_resultado} eliminado correctamente"}