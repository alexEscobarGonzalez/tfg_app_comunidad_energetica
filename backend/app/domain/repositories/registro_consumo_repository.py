from typing import List, Optional
from datetime import datetime
from app.domain.entities.registro_consumo import RegistroConsumoEntity

class RegistroConsumoRepository:
    def get_by_id(self, idRegistroConsumo: int) -> Optional[RegistroConsumoEntity]:
        raise NotImplementedError

    def get_by_participante(self, idParticipante: int) -> List[RegistroConsumoEntity]:
        raise NotImplementedError
    
    def get_by_periodo(self, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        raise NotImplementedError
    
    def get_by_participante_y_periodo(self, idParticipante: int, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        raise NotImplementedError
    
    def get_range_for_participantes(self, id_participantes: List[int], fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        raise NotImplementedError
    
    def list(self) -> List[RegistroConsumoEntity]:
        raise NotImplementedError

    def create(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        raise NotImplementedError

    def update(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        raise NotImplementedError

    def delete(self, idRegistroConsumo: int) -> None:
        raise NotImplementedError
    
    def delete_all_by_participante(self, idParticipante: int) -> int:
        raise NotImplementedError