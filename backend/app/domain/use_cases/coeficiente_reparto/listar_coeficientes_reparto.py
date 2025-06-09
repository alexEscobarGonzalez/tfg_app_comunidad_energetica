from fastapi import HTTPException
from typing import List
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def listar_coeficientes_reparto_by_participante_use_case(id_participante: int, participante_repo: ParticipanteRepository, coeficiente_repo: CoeficienteRepartoRepository) -> List[CoeficienteRepartoEntity]:
    
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
        
    # Buscar los coeficientes de reparto
    coeficientes = coeficiente_repo.get_by_participante(id_participante)
    
    return coeficientes

def listar_todos_coeficientes_reparto_use_case(coeficiente_repo: CoeficienteRepartoRepository) -> List[CoeficienteRepartoEntity]:
    
    return coeficiente_repo.list()