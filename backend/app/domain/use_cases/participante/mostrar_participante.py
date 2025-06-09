from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.domain.repositories.participante_repository import ParticipanteRepository

def mostrar_participante_use_case(id_participante: int, repo: ParticipanteRepository) -> ParticipanteEntity:
    
    participante = repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    return participante