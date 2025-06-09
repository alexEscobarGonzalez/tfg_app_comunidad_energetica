from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.infrastructure.persistance.models.coeficiente_reparto_tabla import CoeficienteReparto as CoeficienteRepartoModel
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository

class SqlAlchemyCoeficienteRepartoRepository(CoeficienteRepartoRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: CoeficienteRepartoModel) -> CoeficienteRepartoEntity:
        return CoeficienteRepartoEntity(
            idCoeficienteReparto=model.idCoeficienteReparto,
            tipoReparto=model.tipoReparto,
            parametros=model.parametros,
            idParticipante=model.idParticipante
        )
        
    def get_by_id(self, coeficiente_id: int) -> Optional[CoeficienteRepartoEntity]:
        model = self.db.query(CoeficienteRepartoModel).filter_by(idCoeficienteReparto=coeficiente_id).first()
        if model:
            return self._map_to_entity(model)
        return None
        
    def get_by_participante(self, participante_id: int) -> List[CoeficienteRepartoEntity]:
        models = self.db.query(CoeficienteRepartoModel).filter_by(idParticipante=participante_id).all()
        return [self._map_to_entity(model) for model in models]
    
    def get_by_participante_single(self, participante_id: int) -> Optional[CoeficienteRepartoEntity]:
        
        model = self.db.query(CoeficienteRepartoModel).filter_by(idParticipante=participante_id).first()
        if model:
            return self._map_to_entity(model)
        return None
    
    def list(self, skip: int = 0, limit: int = 100) -> List[CoeficienteRepartoEntity]:
        models = self.db.query(CoeficienteRepartoModel).offset(skip).limit(limit).all()
        return [self._map_to_entity(model) for model in models]
        
    def create(self, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        model = CoeficienteRepartoModel(
            tipoReparto=coeficiente.tipoReparto,
            parametros=coeficiente.parametros,
            idParticipante=coeficiente.idParticipante
        )
            
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)
        
    def create_or_update(self, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        
        # Buscar si ya existe un coeficiente para este participante
        existing_model = self.db.query(CoeficienteRepartoModel).filter_by(idParticipante=coeficiente.idParticipante).first()
        
        if existing_model:
            # Actualizar el existente
            existing_model.tipoReparto = coeficiente.tipoReparto
            existing_model.parametros = coeficiente.parametros
            self.db.commit()
            self.db.refresh(existing_model)
            return self._map_to_entity(existing_model)
        else:
            # Crear uno nuevo
            model = CoeficienteRepartoModel(
                tipoReparto=coeficiente.tipoReparto,
                parametros=coeficiente.parametros,
                idParticipante=coeficiente.idParticipante
            )
            self.db.add(model)
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        
    def update(self, coeficiente_id: int, coeficiente: CoeficienteRepartoEntity) -> CoeficienteRepartoEntity:
        model = self.db.query(CoeficienteRepartoModel).filter_by(idCoeficienteReparto=coeficiente_id).first()
        if model:
            model.tipoReparto = coeficiente.tipoReparto
            model.parametros = coeficiente.parametros
            
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None
        
    def delete(self, coeficiente_id: int) -> None:
        model = self.db.query(CoeficienteRepartoModel).filter_by(idCoeficienteReparto=coeficiente_id).first()
        if model:
            self.db.delete(model)
            self.db.commit()
    
    def delete_by_participante(self, participante_id: int) -> None:
        
        model = self.db.query(CoeficienteRepartoModel).filter_by(idParticipante=participante_id).first()
        if model:
            self.db.delete(model)
            self.db.commit()