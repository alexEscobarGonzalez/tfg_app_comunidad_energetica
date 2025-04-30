from typing import List, Optional
from datetime import datetime
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository

class DatosIntervaloActivoUseCases:
    def __init__(self, repository: DatosIntervaloActivoRepository):
        self.repository = repository
    
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloActivoEntity]:
        return self.repository.get_by_id(datos_intervalo_id)
    
    def get_by_resultado_activo_gen_id(self, resultado_activo_gen_id: int) -> List[DatosIntervaloActivoEntity]:
        return self.repository.get_by_resultado_activo_gen_id(resultado_activo_gen_id)
    
    def get_by_resultado_activo_alm_id(self, resultado_activo_alm_id: int) -> List[DatosIntervaloActivoEntity]:
        return self.repository.get_by_resultado_activo_alm_id(resultado_activo_alm_id)
    
    def get_by_timestamp_range(self, resultado_activo_id: int, is_generacion: bool, start_time: datetime, end_time: datetime) -> List[DatosIntervaloActivoEntity]:
        return self.repository.get_by_timestamp_range(resultado_activo_id, is_generacion, start_time, end_time)
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloActivoEntity]:
        return self.repository.list(skip, limit)
    
    def create(self, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        return self.repository.create(datos_intervalo)
    
    def create_many(self, datos_intervalos: List[DatosIntervaloActivoEntity]) -> List[DatosIntervaloActivoEntity]:
        return self.repository.create_many(datos_intervalos)
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        return self.repository.update(datos_intervalo_id, datos_intervalo)
    
    def delete(self, datos_intervalo_id: int) -> None:
        self.repository.delete(datos_intervalo_id)