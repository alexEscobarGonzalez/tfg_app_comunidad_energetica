from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.participante import ParticipanteEntity
from app.infrastructure.persistance.models.participante_tabla import Participante as ParticipanteModel
from app.domain.repositories.participante_repository import ParticipanteRepository

class SqlAlchemyParticipanteRepository(ParticipanteRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: ParticipanteModel) -> ParticipanteEntity:
        
        return ParticipanteEntity(
            idParticipante=model.idParticipante,
            nombre=model.nombre,
            idComunidadEnergetica=model.idComunidadEnergetica
        )

    def get_by_id(self, participante_id: int) -> Optional[ParticipanteEntity]:
        model = self.db.query(ParticipanteModel).filter_by(idParticipante=participante_id).first()
        if model:
            return self._map_to_entity(model)
        return None

    def get_by_comunidad(self, comunidad_id: int) -> List[ParticipanteEntity]:
        models = self.db.query(ParticipanteModel).filter_by(idComunidadEnergetica=comunidad_id).all()
        return [self._map_to_entity(model) for model in models]

    def list(self, skip: int = 0, limit: int = 100) -> List[ParticipanteEntity]:
        models = self.db.query(ParticipanteModel).offset(skip).limit(limit).all()
        return [self._map_to_entity(model) for model in models]

    def create(self, participante: ParticipanteEntity) -> ParticipanteEntity:
        model = ParticipanteModel(
            nombre=participante.nombre,
            idComunidadEnergetica=participante.idComunidadEnergetica
        )
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)

    def update(self, participante_id: int, participante: ParticipanteEntity) -> ParticipanteEntity:
        model = self.db.query(ParticipanteModel).filter_by(idParticipante=participante_id).first()
        if model:
            model.nombre = participante.nombre
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None

    def delete(self, participante_id: int) -> None:
        model = self.db.query(ParticipanteModel).filter_by(idParticipante=participante_id).first()
        if model:
            self.db.delete(model)
            self.db.commit()