from fastapi import HTTPException
from app.domain.entities.participante import ParticipanteEntity
from app.domain.repositories.participante_repository import ParticipanteRepository

def modificar_participante_use_case(id_participante: int, participante_datos: ParticipanteEntity, repo: ParticipanteRepository) -> ParticipanteEntity:
    
    # Verificar que el participante existe
    participante_existente = repo.get_by_id(id_participante)
    if not participante_existente:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Actualizar los datos manteniendo el ID original y la comunidad energética
    participante_datos.idParticipante = id_participante
    participante_datos.idComunidadEnergetica = participante_existente.idComunidadEnergetica
    
    # Actualizar en la base de datos
    participante_actualizado = repo.update(id_participante, participante_datos)
    return participante_actualizado