from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from typing import Optional

def modificar_resultado_activo_generacion_use_case(id_resultado: int, resultado_datos: ResultadoSimulacionActivoGeneracionEntity, repo: ResultadoSimulacionActivoGeneracionRepository) -> ResultadoSimulacionActivoGeneracionEntity:
    
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de generación no encontrado")
    resultado_datos.idResultadoSimulacionActivoGeneracion = id_resultado
    return repo.update(id_resultado, resultado_datos)