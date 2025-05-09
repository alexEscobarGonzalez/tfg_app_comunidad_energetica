from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.domain.repositories.participante_repository import ParticipanteRepository
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def crear_participante_use_case(participante: ParticipanteEntity, comunidad_repo: ComunidadEnergeticaRepository, participante_repo: ParticipanteRepository) -> ParticipanteEntity:
    """
    Crea un nuevo participante asociado a una comunidad energética
    
    Args:
        participante: Entidad con los datos del nuevo participante
        comunidad_repo: Repositorio de la comunidad energetica
        participante_repo: Repositorio del participante
        
    Returns:
        ParticipanteEntity: La entidad participante creada con su ID asignado
        
    Raises:
        HTTPException: Si la comunidad energética no existe
    """
    # Verificar que la comunidad energética existe
    comunidad = comunidad_repo.get_by_id(participante.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Crear el participante
    return participante_repo.create(participante)