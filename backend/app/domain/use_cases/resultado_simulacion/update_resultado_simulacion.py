from fastapi import HTTPException
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from typing import Optional

def modificar_resultado_simulacion_use_case(id_resultado: int, resultado_datos: ResultadoSimulacionEntity, repo: ResultadoSimulacionRepository) -> ResultadoSimulacionEntity:
    
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación no encontrado")
    resultado_datos.idResultadoSimulacion = id_resultado
    return repo.update(id_resultado, resultado_datos)