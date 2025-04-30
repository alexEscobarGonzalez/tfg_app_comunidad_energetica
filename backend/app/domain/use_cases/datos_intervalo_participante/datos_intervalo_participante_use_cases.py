from typing import List, Optional
from datetime import datetime
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository

class DatosIntervaloParticipanteUseCases:
    def __init__(self, repository: DatosIntervaloParticipanteRepository):
        self.repository = repository
    
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloParticipanteEntity]:
        return self.repository.get_by_id(datos_intervalo_id)
    
    def get_by_resultado_participante_id(self, resultado_participante_id: int) -> List[DatosIntervaloParticipanteEntity]:
        return self.repository.get_by_resultado_participante_id(resultado_participante_id)
    
    def get_by_timestamp_range(self, resultado_participante_id: int, start_time: datetime, end_time: datetime) -> List[DatosIntervaloParticipanteEntity]:
        return self.repository.get_by_timestamp_range(resultado_participante_id, start_time, end_time)
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloParticipanteEntity]:
        return self.repository.list(skip, limit)
    
    def create(self, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        return self.repository.create(datos_intervalo)
    
    def create_many(self, datos_intervalos: List[DatosIntervaloParticipanteEntity]) -> List[DatosIntervaloParticipanteEntity]:
        return self.repository.create_many(datos_intervalos)
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        return self.repository.update(datos_intervalo_id, datos_intervalo)
    
    def delete(self, datos_intervalo_id: int) -> None:
        self.repository.delete(datos_intervalo_id)