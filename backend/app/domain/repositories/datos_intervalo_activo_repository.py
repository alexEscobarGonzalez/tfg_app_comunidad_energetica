from typing import List, Optional
from datetime import datetime
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity

class DatosIntervaloActivoRepository:
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    def get_by_resultado_activo_gen_id(self, resultado_activo_gen_id: int) -> List[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    def get_by_resultado_activo_alm_id(self, resultado_activo_alm_id: int) -> List[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    def get_by_timestamp_range(self, resultado_activo_id: int, is_generacion: bool, start_time: datetime, end_time: datetime) -> List[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    def create(self, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        raise NotImplementedError
    
    def create_many(self, datos_intervalos: List[DatosIntervaloActivoEntity]) -> List[DatosIntervaloActivoEntity]:
        raise NotImplementedError
    
    # Alias para mantener compatibilidad con el código existente
    def create_bulk(self, datos_intervalos: List[DatosIntervaloActivoEntity]) -> List[DatosIntervaloActivoEntity]:
        return self.create_many(datos_intervalos)
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        raise NotImplementedError
    
    def delete(self, datos_intervalo_id: int) -> None:
        raise NotImplementedError