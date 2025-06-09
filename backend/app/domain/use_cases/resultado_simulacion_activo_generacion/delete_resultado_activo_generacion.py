from fastapi import HTTPException
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository

def eliminar_resultado_activo_generacion_use_case(id_resultado: int, repo: ResultadoSimulacionActivoGeneracionRepository) -> dict:
    
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de generación no encontrado")
    repo.delete(id_resultado)
    return {"mensaje": f"Resultado de simulación de activo de generación con ID {id_resultado} eliminado correctamente"}