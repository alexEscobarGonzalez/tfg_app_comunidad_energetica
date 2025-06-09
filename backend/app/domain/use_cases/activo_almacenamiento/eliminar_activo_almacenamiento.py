from fastapi import HTTPException
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

def eliminar_activo_almacenamiento_use_case(id_activo: int, repo: ActivoAlmacenamientoRepository) -> None:
    # Verificar que el activo existe
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
        
    # Eliminar el activo
    repo.delete(id_activo)