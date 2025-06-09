from typing import Optional
from fastapi import HTTPException
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def obtener_coeficiente_por_participante_use_case(
    id_participante: int,
    participante_repo: ParticipanteRepository,
    coeficiente_repo: CoeficienteRepartoRepository
) -> Optional[CoeficienteRepartoEntity]:
    
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Obtener el coeficiente del participante
    return coeficiente_repo.get_by_participante_single(id_participante) 