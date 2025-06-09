from typing import List, Optional
from app.domain.entities.participante import ParticipanteEntity

class ParticipanteRepository:
    def get_by_id(self, participante_id: int) -> Optional[ParticipanteEntity]:
        raise NotImplementedError

    def get_by_comunidad(self, comunidad_id: int) -> List[ParticipanteEntity]:
        raise NotImplementedError
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ParticipanteEntity]:
        raise NotImplementedError

    def create(self, participante: ParticipanteEntity) -> ParticipanteEntity:
        raise NotImplementedError

    def update(self, participante_id: int, participante: ParticipanteEntity) -> ParticipanteEntity:
        raise NotImplementedError

    def delete(self, participante_id: int) -> None:
        raise NotImplementedError