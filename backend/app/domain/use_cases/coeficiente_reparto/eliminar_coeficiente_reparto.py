from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository

def eliminar_coeficiente_reparto_use_case(id_coeficiente: int, db: Session) -> dict:
    """
    Elimina un coeficiente de reparto existente
    
    Args:
        id_coeficiente: ID del coeficiente de reparto a eliminar
        db: Sesión de base de datos
        
    Returns:
        dict: Mensaje de confirmación de la eliminación
        
    Raises:
        HTTPException: Si el coeficiente de reparto no existe
    """
    repo = SqlAlchemyCoeficienteRepartoRepository(db)
    
    # Verificar que el coeficiente existe
    coeficiente_existente = repo.get_by_id(id_coeficiente)
    if not coeficiente_existente:
        raise HTTPException(status_code=404, detail="Coeficiente de reparto no encontrado")
    
    # Eliminar el coeficiente
    repo.delete(id_coeficiente)
    
    # Retornar mensaje de confirmación
    return {"mensaje": f"Coeficiente de reparto con ID {id_coeficiente} eliminado correctamente"}