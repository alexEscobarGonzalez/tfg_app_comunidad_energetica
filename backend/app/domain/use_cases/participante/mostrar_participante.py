from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def mostrar_participante_use_case(id_participante: int, db: Session) -> ParticipanteEntity:
    """
    Obtiene los detalles de un participante por su ID
    
    Args:
        id_participante: ID del participante a buscar
        db: Sesión de base de datos
        
    Returns:
        ParticipanteEntity: Datos del participante
        
    Raises:
        HTTPException: Si el participante no existe
    """
    repo = SqlAlchemyParticipanteRepository(db)
    participante = repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    return participante