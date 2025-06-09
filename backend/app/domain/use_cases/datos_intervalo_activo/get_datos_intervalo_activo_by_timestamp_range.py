from fastapi import HTTPException
from typing import List
from datetime import datetime
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository

def get_datos_intervalo_activo_by_timestamp_range_use_case(
    resultado_activo_id: int,
    is_generacion: bool,
    start_time: datetime,
    end_time: datetime,
    repo: DatosIntervaloActivoRepository
) -> List[DatosIntervaloActivoEntity]:
    return repo.get_by_timestamp_range(resultado_activo_id, is_generacion, start_time, end_time)
