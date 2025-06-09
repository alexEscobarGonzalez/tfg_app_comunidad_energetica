from fastapi import HTTPException
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository

def eliminar_activo_generacion_use_case(id_activo: int, repo: ActivoGeneracionRepository) -> None:

    # Verificar que el activo existe
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de generación no encontrado")
        
    # Eliminar el activo
    repo.delete(id_activo)