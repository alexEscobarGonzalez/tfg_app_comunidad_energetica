from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository

def eliminar_activo_almacenamiento_use_case(id_activo: int, db: Session) -> None:
    """
    Elimina un activo de almacenamiento existente
    
    Args:
        id_activo: ID del activo de almacenamiento a eliminar
        db: Sesión de base de datos
        
    Raises:
        HTTPException: Si el activo de almacenamiento no existe
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    
    # Verificar que el activo existe
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
        
    # Eliminar el activo
    repo.delete(id_activo)