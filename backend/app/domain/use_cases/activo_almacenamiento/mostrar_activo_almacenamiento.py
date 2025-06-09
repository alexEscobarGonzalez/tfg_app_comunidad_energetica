from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

def mostrar_activo_almacenamiento_use_case(id_activo: int, repo: ActivoAlmacenamientoRepository) -> ActivoAlmacenamientoEntity:
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
    return activo