from typing import Optional
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository
from fastapi import HTTPException

def get_datos_intervalo_participante_by_id_use_case(datos_intervalo_id: int, repo: DatosIntervaloParticipanteRepository) -> Optional[DatosIntervaloParticipanteEntity]:
    datos = repo.get_by_id(datos_intervalo_id)
    if not datos:
        raise HTTPException(status_code=404, detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados")
    return datos
