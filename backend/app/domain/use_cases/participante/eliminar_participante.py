from fastapi import HTTPException
from app.domain.repositories.participante_repository import ParticipanteRepository

def eliminar_participante_use_case(id_participante: int, repo: ParticipanteRepository) -> None:
    
    # Verificar que el participante existe
    participante = repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
        
    # Eliminar el participante
    repo.delete(id_participante)