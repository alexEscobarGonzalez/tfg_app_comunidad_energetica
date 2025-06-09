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
    """
    Obtiene el coeficiente de reparto de un participante específico (relación 1:1)
    
    Args:
        id_participante: ID del participante
        participante_repo: Repositorio de participantes
        coeficiente_repo: Repositorio de coeficientes de reparto
        
    Returns:
        Optional[CoeficienteRepartoEntity]: El coeficiente del participante o None si no existe
        
    Raises:
        HTTPException: Si el participante no existe
    """
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Obtener el coeficiente del participante
    return coeficiente_repo.get_by_participante_single(id_participante) 