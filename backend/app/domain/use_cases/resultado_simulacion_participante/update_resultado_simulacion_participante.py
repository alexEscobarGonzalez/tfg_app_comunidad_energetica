from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from typing import Optional

def modificar_resultado_simulacion_participante_use_case(id_resultado_participante: int, resultado_datos: ResultadoSimulacionParticipanteEntity, repo: ResultadoSimulacionParticipanteRepository) -> ResultadoSimulacionParticipanteEntity:
    """
    Modifica los datos de un resultado de simulación de participante existente
    Args:
        id_resultado_participante: ID del resultado a modificar
        resultado_datos: Nuevos datos para el resultado
        repo: Repositorio de resultados de simulación de participante
    Returns:
        ResultadoSimulacionParticipanteEntity: Datos actualizados
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado_existente = repo.get_by_id(id_resultado_participante)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de participante no encontrado")
    resultado_datos.idResultadoSimulacionParticipante = id_resultado_participante
    return repo.update(id_resultado_participante, resultado_datos)
