from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

def mostrar_activo_almacenamiento_use_case(id_activo: int, repo: ActivoAlmacenamientoRepository) -> ActivoAlmacenamientoEntity:
    """
    Obtiene los detalles de un activo de almacenamiento por su ID
    
    Args:
        id_activo: ID del activo de almacenamiento a buscar
        repo: Repositorio de activos de almacenamiento
        
    Returns:
        ActivoAlmacenamientoEntity: Datos del activo de almacenamiento
        
    Raises:
        HTTPException: Si el activo de almacenamiento no existe
    """
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
    return activo