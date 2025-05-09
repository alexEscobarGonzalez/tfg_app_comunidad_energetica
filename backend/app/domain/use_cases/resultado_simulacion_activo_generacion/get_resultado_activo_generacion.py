from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from typing import Optional, List

def mostrar_resultado_activo_generacion_use_case(id_resultado: int, repo: ResultadoSimulacionActivoGeneracionRepository) -> ResultadoSimulacionActivoGeneracionEntity:
    """
    Obtiene los detalles de un resultado de simulación de activo de generación específico
    Args:
        id_resultado: ID del resultado a obtener
        repo: Repositorio de resultados de simulación de activo de generación
    Returns:
        ResultadoSimulacionActivoGeneracionEntity: La entidad solicitada
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado = repo.get_by_id(id_resultado)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de generación no encontrado")
    return resultado