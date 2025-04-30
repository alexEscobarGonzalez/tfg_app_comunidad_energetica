from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository

def eliminar_activo_generacion_use_case(id_activo: int, db: Session) -> None:
    """
    Elimina un activo de generación existente
    
    Args:
        id_activo: ID del activo de generación a eliminar
        db: Sesión de base de datos
        
    Raises:
        HTTPException: Si el activo de generación no existe
    """
    repo = SqlAlchemyActivoGeneracionRepository(db)
    
    # Verificar que el activo existe
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de generación no encontrado")
        
    # Eliminar el activo
    repo.delete(id_activo)