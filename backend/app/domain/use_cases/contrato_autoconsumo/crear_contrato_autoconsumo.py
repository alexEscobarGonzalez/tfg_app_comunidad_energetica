from fastapi import HTTPException
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def crear_contrato_autoconsumo_use_case(contrato: ContratoAutoconsumoEntity, participante_repo: ParticipanteRepository, contrato_repo: ContratoAutoconsumoRepository) -> ContratoAutoconsumoEntity:
    
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(contrato.idParticipante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Verificar que el participante no tenga ya un contrato (debe ser único)
    contrato_existente = contrato_repo.get_by_participante(contrato.idParticipante)
    if contrato_existente:
        raise HTTPException(status_code=400, detail="El participante ya tiene un contrato asociado")
    
    # Crear el contrato
    return contrato_repo.create(contrato)