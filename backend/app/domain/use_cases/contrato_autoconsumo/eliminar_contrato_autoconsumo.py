from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository

def eliminar_contrato_autoconsumo_use_case(id_contrato: int, db: Session) -> None:
    """
    Elimina un contrato de autoconsumo existente
    
    Args:
        id_contrato: ID del contrato a eliminar
        db: Sesión de base de datos
        
    Raises:
        HTTPException: Si el contrato no existe
    """
    repo = SqlAlchemyContratoAutoconsumoRepository(db)
    
    # Verificar que el contrato existe
    contrato = repo.get_by_id(id_contrato)
    if not contrato:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
        
    # Eliminar el contrato
    repo.delete(id_contrato)