from fastapi import HTTPException
from typing import List
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository

def get_datos_intervalo_activo_by_resultado_activo_gen_id_use_case(resultado_activo_gen_id: int, repo: DatosIntervaloActivoRepository) -> List[DatosIntervaloActivoEntity]:
    return repo.get_by_resultado_activo_gen_id(resultado_activo_gen_id)

def get_datos_intervalo_activo_by_resultado_activo_alm_id_use_case(resultado_activo_alm_id: int, repo: DatosIntervaloActivoRepository) -> List[DatosIntervaloActivoEntity]:
    return repo.get_by_resultado_activo_alm_id(resultado_activo_alm_id)
