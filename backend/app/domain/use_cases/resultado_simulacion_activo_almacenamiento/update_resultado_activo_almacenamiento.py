from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from typing import Optional

def modificar_resultado_activo_almacenamiento_use_case(id_resultado: int, resultado_datos: ResultadoSimulacionActivoAlmacenamientoEntity, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> ResultadoSimulacionActivoAlmacenamientoEntity:
    """
    Modifica los datos de un resultado de simulación de activo de almacenamiento existente
    Args:
        id_resultado: ID del resultado a modificar
        resultado_datos: Nuevos datos para el resultado
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        ResultadoSimulacionActivoAlmacenamientoEntity: Datos actualizados
    Raises:
        HTTPException: Si el resultado no existe
    """
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de almacenamiento no encontrado")
    resultado_datos.idResultadoSimulacionActivoAlmacenamiento = id_resultado
    return repo.update(id_resultado, resultado_datos)