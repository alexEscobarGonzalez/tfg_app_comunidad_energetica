from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository

def mostrar_coeficiente_reparto_use_case(id_coeficiente: int, db: Session) -> CoeficienteRepartoEntity:
    """
    Obtiene los detalles de un coeficiente de reparto por su ID
    
    Args:
        id_coeficiente: ID del coeficiente de reparto a buscar
        db: Sesión de base de datos
        
    Returns:
        CoeficienteRepartoEntity: Datos del coeficiente de reparto
        
    Raises:
        HTTPException: Si el coeficiente de reparto no existe
    """
    repo = SqlAlchemyCoeficienteRepartoRepository(db)
    coeficiente = repo.get_by_id(id_coeficiente)
    if not coeficiente:
        raise HTTPException(status_code=404, detail="Coeficiente de reparto no encontrado")
    return coeficiente