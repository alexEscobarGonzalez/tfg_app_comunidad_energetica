from typing import List, Optional
from datetime import datetime
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity

class DatosIntervaloParticipanteRepository:
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloParticipanteEntity]:
        raise NotImplementedError
    
    def get_by_resultado_participante_id(self, resultado_participante_id: int) -> List[DatosIntervaloParticipanteEntity]:
        raise NotImplementedError
    
    def get_by_timestamp_range(self, resultado_participante_id: int, start_time: datetime, end_time: datetime) -> List[DatosIntervaloParticipanteEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloParticipanteEntity]:
        raise NotImplementedError
    
    def create(self, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        raise NotImplementedError
    
    def create_many(self, datos_intervalos: List[DatosIntervaloParticipanteEntity]) -> List[DatosIntervaloParticipanteEntity]:
        raise NotImplementedError
    
    # Alias para mantener compatibilidad con el código existente
    def create_bulk(self, datos_intervalos: List[DatosIntervaloParticipanteEntity]) -> List[DatosIntervaloParticipanteEntity]:
        return self.create_many(datos_intervalos)
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        raise NotImplementedError
    
    def delete(self, datos_intervalo_id: int) -> None:
        raise NotImplementedError