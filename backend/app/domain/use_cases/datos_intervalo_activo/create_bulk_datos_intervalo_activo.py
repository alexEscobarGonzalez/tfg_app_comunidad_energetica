from fastapi import HTTPException
from typing import List
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository

def create_bulk_datos_intervalo_activo_use_case(datos_list: List[DatosIntervaloActivoEntity], repo: DatosIntervaloActivoRepository) -> List[DatosIntervaloActivoEntity]:
    return repo.create_bulk(datos_list)
