from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def crear_contrato_autoconsumo_use_case(contrato: ContratoAutoconsumoEntity, db: Session) -> ContratoAutoconsumoEntity:
    """
    Crea un nuevo contrato de autoconsumo asociado a un participante
    
    Args:
        contrato: Entidad con los datos del nuevo contrato
        db: Sesión de base de datos
        
    Returns:
        ContratoAutoconsumoEntity: La entidad contrato creada con su ID asignado
        
    Raises:
        HTTPException: Si el participante no existe o ya tiene un contrato
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(contrato.idParticipante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Verificar que el participante no tenga ya un contrato (debe ser único)
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contrato_existente = contrato_repo.get_by_participante(contrato.idParticipante)
    if contrato_existente:
        raise HTTPException(status_code=400, detail="El participante ya tiene un contrato asociado")
    
    # Crear el contrato
    return contrato_repo.create(contrato)