from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository

def modificar_contrato_autoconsumo_use_case(id_contrato: int, contrato_datos: ContratoAutoconsumoEntity, db: Session) -> ContratoAutoconsumoEntity:
    """
    Modifica los datos de un contrato de autoconsumo existente
    
    Args:
        id_contrato: ID del contrato a modificar
        contrato_datos: Nuevos datos para el contrato
        db: Sesión de base de datos
        
    Returns:
        ContratoAutoconsumoEntity: Datos actualizados del contrato
        
    Raises:
        HTTPException: Si el contrato no existe
    """
    repo = SqlAlchemyContratoAutoconsumoRepository(db)
    
    # Verificar que el contrato existe
    contrato_existente = repo.get_by_id(id_contrato)
    if not contrato_existente:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
    
    # Actualizar los datos manteniendo el ID original y el participante
    contrato_datos.idContrato = id_contrato
    contrato_datos.idParticipante = contrato_existente.idParticipante
    
    # Actualizar en la base de datos
    contrato_actualizado = repo.update(contrato_datos)
    return contrato_actualizado