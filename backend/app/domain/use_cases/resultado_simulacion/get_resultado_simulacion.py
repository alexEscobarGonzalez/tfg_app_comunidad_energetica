from fastapi import HTTPException
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from typing import Optional

def mostrar_resultado_simulacion_use_case(id_resultado: int, repo: ResultadoSimulacionRepository) -> ResultadoSimulacionEntity:
    """
    Obtiene los detalles de un resultado de simulación específico
    Args:
        id_resultado: ID del resultado a obtener
        repo: Repositorio de resultados de simulación
    Returns:
        ResultadoSimulacionEntity: La entidad solicitada
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado = repo.get_by_id(id_resultado)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación no encontrado")
    return resultado

def mostrar_resultado_por_simulacion_use_case(id_simulacion: int, repo: ResultadoSimulacionRepository) -> Optional[ResultadoSimulacionEntity]:
    """
    Obtiene el resultado asociado a una simulación específica
    Args:
        id_simulacion: ID de la simulación
        repo: Repositorio de resultados de simulación
    Returns:
        ResultadoSimulacionEntity: La entidad solicitada o None si no existe
    """
    return repo.get_by_simulacion_id(id_simulacion)