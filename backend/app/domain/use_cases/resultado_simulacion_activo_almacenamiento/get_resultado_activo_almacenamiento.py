from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from typing import Optional, List

def obtener_resultado_activo_almacenamiento_use_case(id_resultado: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> ResultadoSimulacionActivoAlmacenamientoEntity:
    
    resultado = repo.get_by_id(id_resultado)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de almacenamiento no encontrado")
    return resultado

def obtener_resultados_por_simulacion_use_case(resultado_simulacion_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    
    return repo.get_by_resultado_simulacion_id(resultado_simulacion_id)

def obtener_resultados_por_activo_use_case(activo_almacenamiento_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    
    return repo.get_by_activo_almacenamiento_id(activo_almacenamiento_id)

def obtener_resultado_por_simulacion_y_activo_use_case(resultado_simulacion_id: int, activo_almacenamiento_id: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
    
    return repo.get_by_resultado_simulacion_and_activo(resultado_simulacion_id, activo_almacenamiento_id)

