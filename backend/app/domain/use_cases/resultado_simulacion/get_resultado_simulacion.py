from fastapi import HTTPException
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from typing import Optional

def mostrar_resultado_simulacion_use_case(id_resultado: int, repo: ResultadoSimulacionRepository) -> ResultadoSimulacionEntity:
    
    resultado = repo.get_by_id(id_resultado)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación no encontrado")
    return resultado

def mostrar_resultado_por_simulacion_use_case(id_simulacion: int, repo: ResultadoSimulacionRepository) -> Optional[ResultadoSimulacionEntity]:
    
    return repo.get_by_simulacion_id(id_simulacion)