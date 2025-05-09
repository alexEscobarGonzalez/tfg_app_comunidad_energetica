from fastapi import HTTPException
from typing import Optional
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository

def get_datos_intervalo_activo_by_id_use_case(datos_intervalo_id: int, repo: DatosIntervaloActivoRepository) -> Optional[DatosIntervaloActivoEntity]:
    datos = repo.get_by_id(datos_intervalo_id)
    if not datos:
        raise HTTPException(status_code=404, detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados")
    return datos
