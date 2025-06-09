from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.domain.repositories.participante_repository import ParticipanteRepository
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def crear_participante_use_case(participante: ParticipanteEntity, comunidad_repo: ComunidadEnergeticaRepository, participante_repo: ParticipanteRepository) -> ParticipanteEntity:
    
    # Verificar que la comunidad energética existe
    comunidad = comunidad_repo.get_by_id(participante.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Crear el participante
    return participante_repo.create(participante)