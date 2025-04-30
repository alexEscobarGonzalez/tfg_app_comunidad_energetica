from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository

def mostrar_activo_generacion_use_case(id_activo: int, db: Session) -> ActivoGeneracionEntity:
    """
    Obtiene los detalles de un activo de generación por su ID
    
    Args:
        id_activo: ID del activo de generación a buscar
        db: Sesión de base de datos
        
    Returns:
        ActivoGeneracionEntity: Datos del activo de generación
        
    Raises:
        HTTPException: Si el activo de generación no existe
    """
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de generación no encontrado")
    return activo