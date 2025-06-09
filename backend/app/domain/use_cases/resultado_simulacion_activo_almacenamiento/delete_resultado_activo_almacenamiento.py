from fastapi import HTTPException
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

def eliminar_resultado_activo_almacenamiento_use_case(id_resultado: int, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> dict:
    
    resultado_existente = repo.get_by_id(id_resultado)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de activo de almacenamiento no encontrado")
    repo.delete(id_resultado)
    return {"mensaje": f"Resultado de simulación de activo de almacenamiento con ID {id_resultado} eliminado correctamente"}