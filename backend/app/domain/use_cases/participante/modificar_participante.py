from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def modificar_participante_use_case(id_participante: int, participante_datos: ParticipanteEntity, db: Session) -> ParticipanteEntity:
    """
    Modifica los datos de un participante existente
    
    Args:
        id_participante: ID del participante a modificar
        participante_datos: Nuevos datos para el participante
        db: Sesión de base de datos
        
    Returns:
        ParticipanteEntity: Datos actualizados del participante
        
    Raises:
        HTTPException: Si el participante no existe
    """
    repo = SqlAlchemyParticipanteRepository(db)
    
    # Verificar que el participante existe
    participante_existente = repo.get_by_id(id_participante)
    if not participante_existente:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Actualizar los datos manteniendo el ID original y la comunidad energética
    participante_datos.idParticipante = id_participante
    participante_datos.idComunidadEnergetica = participante_existente.idComunidadEnergetica
    
    # Actualizar en la base de datos
    participante_actualizado = repo.update(participante_datos)
    return participante_actualizado