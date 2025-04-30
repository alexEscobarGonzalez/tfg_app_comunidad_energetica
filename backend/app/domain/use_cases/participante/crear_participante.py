from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

def crear_participante_use_case(participante: ParticipanteEntity, db: Session) -> ParticipanteEntity:
    """
    Crea un nuevo participante asociado a una comunidad energética
    
    Args:
        participante: Entidad con los datos del nuevo participante
        db: Sesión de base de datos
        
    Returns:
        ParticipanteEntity: La entidad participante creada con su ID asignado
        
    Raises:
        HTTPException: Si la comunidad energética no existe
    """
    # Verificar que la comunidad energética existe
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = comunidad_repo.get_by_id(participante.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Crear el participante
    participante_repo = SqlAlchemyParticipanteRepository(db)
    return participante_repo.create(participante)