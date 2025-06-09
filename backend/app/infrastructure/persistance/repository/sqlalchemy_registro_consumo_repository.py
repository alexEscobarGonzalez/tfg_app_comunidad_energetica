from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import between, and_, or_

from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.infrastructure.persistance.models.registro_consumo_tabla import RegistroConsumo

class SqlAlchemyRegistroConsumoRepository(RegistroConsumoRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: RegistroConsumo) -> RegistroConsumoEntity:
        
        return RegistroConsumoEntity(
            idRegistroConsumo=model.idRegistroConsumo,
            timestamp=model.timestamp,
            consumoEnergia=model.consumoEnergia,
            idParticipante=model.idParticipante
        )
        
    def get_by_id(self, idRegistroConsumo: int) -> Optional[RegistroConsumoEntity]:
        model = self.db.query(RegistroConsumo).filter_by(idRegistroConsumo=idRegistroConsumo).first()
        if model:
            return self._map_to_entity(model)
        return None
        
    def get_by_participante(self, idParticipante: int) -> List[RegistroConsumoEntity]:
        models = self.db.query(RegistroConsumo).filter_by(idParticipante=idParticipante).order_by(RegistroConsumo.timestamp).all()
        return [self._map_to_entity(model) for model in models]
    
    def get_by_periodo(self, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        models = self.db.query(RegistroConsumo).filter(
            between(RegistroConsumo.timestamp, fecha_inicio, fecha_fin)
        ).order_by(RegistroConsumo.timestamp).all()
        return [self._map_to_entity(model) for model in models]
    
    def get_by_participante_y_periodo(self, idParticipante: int, fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        models = self.db.query(RegistroConsumo).filter(
            RegistroConsumo.idParticipante == idParticipante,
            between(RegistroConsumo.timestamp, fecha_inicio, fecha_fin)
        ).order_by(RegistroConsumo.timestamp).all()
        return [self._map_to_entity(model) for model in models]
    
    def get_range_for_participantes(self, id_participantes: List[int], fecha_inicio: datetime, fecha_fin: datetime) -> List[RegistroConsumoEntity]:
        
        # Si no hay participantes, devolver lista vacía
        if not id_participantes:
            return []
        
        # Consulta para obtener registros de múltiples participantes en un rango de tiempo
        models = self.db.query(RegistroConsumo).filter(
            RegistroConsumo.idParticipante.in_(id_participantes),
            between(RegistroConsumo.timestamp, fecha_inicio, fecha_fin)
        ).order_by(RegistroConsumo.timestamp).all()
        
        return [self._map_to_entity(model) for model in models]
    
    def list(self) -> List[RegistroConsumoEntity]:
        models = self.db.query(RegistroConsumo).order_by(RegistroConsumo.timestamp).all()
        return [self._map_to_entity(model) for model in models]
        
    def create(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        model = RegistroConsumo(
            timestamp=registro.timestamp,
            consumoEnergia=registro.consumoEnergia,
            idParticipante=registro.idParticipante
        )
            
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)
        
    def update(self, registro: RegistroConsumoEntity) -> RegistroConsumoEntity:
        model = self.db.query(RegistroConsumo).filter_by(idRegistroConsumo=registro.idRegistroConsumo).first()
        if model:
            model.timestamp = registro.timestamp
            model.consumoEnergia = registro.consumoEnergia
            
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None
        
    def delete(self, idRegistroConsumo: int) -> None:
        model = self.db.query(RegistroConsumo).filter_by(idRegistroConsumo=idRegistroConsumo).first()
        if model:
            self.db.delete(model)
            self.db.commit()
    
    def delete_all_by_participante(self, idParticipante: int) -> int:
        
        deleted_count = self.db.query(RegistroConsumo).filter_by(idParticipante=idParticipante).delete()
        self.db.commit()
        return deleted_count