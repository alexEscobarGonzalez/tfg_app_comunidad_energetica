from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from typing import Optional, List

def obtener_resultado_activo_almacenamiento_use_case(id_resultado: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> ResultadoSimulacionActivoAlmacenamientoEntity:
    """
    Obtiene los detalles de un resultado de simulación de activo de almacenamiento específico
    Args:
        id_resultado: ID del resultado a obtener
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        ResultadoSimulacionActivoAlmacenamientoEntity: La entidad solicitada
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado = repo.get_by_id(id_resultado)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de almacenamiento no encontrado")
    return resultado

def obtener_resultados_por_simulacion_use_case(resultado_simulacion_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    """
    Obtiene todos los resultados de activos de almacenamiento asociados a una simulación
    Args:
        resultado_simulacion_id: ID del resultado de simulación
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        List[ResultadoSimulacionActivoAlmacenamientoEntity]: Lista de resultados
    """
    return repo.get_by_resultado_simulacion_id(resultado_simulacion_id)

def obtener_resultados_por_activo_use_case(activo_almacenamiento_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    """
    Obtiene todos los resultados asociados a un activo de almacenamiento específico
    Args:
        activo_almacenamiento_id: ID del activo de almacenamiento
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        List[ResultadoSimulacionActivoAlmacenamientoEntity]: Lista de resultados
    """
    return repo.get_by_activo_almacenamiento_id(activo_almacenamiento_id)

def obtener_resultado_por_simulacion_y_activo_use_case(resultado_simulacion_id: int, activo_almacenamiento_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
    """
    Obtiene un resultado específico por su combinación de simulación y activo
    Args:
        resultado_simulacion_id: ID del resultado de simulación
        activo_almacenamiento_id: ID del activo de almacenamiento
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        ResultadoSimulacionActivoAlmacenamientoEntity: La entidad solicitada o None si no existe
    """
    return repo.get_by_resultado_simulacion_and_activo(resultado_simulacion_id, activo_almacenamiento_id)

