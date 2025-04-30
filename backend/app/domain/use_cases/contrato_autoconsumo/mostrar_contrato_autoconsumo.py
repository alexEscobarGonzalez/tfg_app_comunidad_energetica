from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository

def mostrar_contrato_autoconsumo_use_case(id_contrato: int, db: Session) -> ContratoAutoconsumoEntity:
    """
    Obtiene los detalles de un contrato de autoconsumo por su ID
    
    Args:
        id_contrato: ID del contrato a buscar
        db: Sesión de base de datos
        
    Returns:
        ContratoAutoconsumoEntity: Datos del contrato
        
    Raises:
        HTTPException: Si el contrato no existe
    """
    repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contrato = repo.get_by_id(id_contrato)
    if not contrato:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
    return contrato