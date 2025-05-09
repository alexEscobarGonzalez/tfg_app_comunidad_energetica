from fastapi import HTTPException
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository

def eliminar_resultado_simulacion_participante_use_case(id_resultado_participante: int, repo: ResultadoSimulacionParticipanteRepository) -> dict:
    """
    Elimina un resultado de simulación de participante existente
    Args:
        id_resultado_participante: ID del resultado a eliminar
        repo: Repositorio de resultados de simulación de participante
    Returns:
        dict: Mensaje de confirmación
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado_existente = repo.get_by_id(id_resultado_participante)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de participante no encontrado")
    repo.delete(id_resultado_participante)
    return {"mensaje": f"Resultado de simulación de participante con ID {id_resultado_participante} eliminado correctamente"}
