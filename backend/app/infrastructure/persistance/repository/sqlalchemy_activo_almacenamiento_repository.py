from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.infrastructure.persistance.models.activo_almacenamiento_tabla import ActivoAlmacenamiento
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

class SqlAlchemyActivoAlmacenamientoRepository(ActivoAlmacenamientoRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: ActivoAlmacenamiento) -> ActivoAlmacenamientoEntity:
        return ActivoAlmacenamientoEntity(
            idActivoAlmacenamiento=model.idActivoAlmacenamiento,
            capacidadNominal_kWh=model.capacidadNominal_kWh,
            potenciaMaximaCarga_kW=model.potenciaMaximaCarga_kW,
            potenciaMaximaDescarga_kW=model.potenciaMaximaDescarga_kW,
            eficienciaCicloCompleto_pct=model.eficienciaCicloCompleto_pct,
            profundidadDescargaMax_pct=model.profundidadDescargaMax_pct,
            idComunidadEnergetica=model.idComunidadEnergetica
        )
        
    def get_by_id(self, idActivoAlmacenamiento: int) -> Optional[ActivoAlmacenamientoEntity]:
        model = self.db.query(ActivoAlmacenamiento).filter_by(idActivoAlmacenamiento=idActivoAlmacenamiento).first()
        if model:
            return self._map_to_entity(model)
        return None
        
    def get_by_comunidad(self, idComunidadEnergetica: int) -> List[ActivoAlmacenamientoEntity]:
        models = self.db.query(ActivoAlmacenamiento).filter_by(idComunidadEnergetica=idComunidadEnergetica).all()
        return [self._map_to_entity(model) for model in models]
    
    def list(self) -> List[ActivoAlmacenamientoEntity]:
        models = self.db.query(ActivoAlmacenamiento).all()
        return [self._map_to_entity(model) for model in models]
        
    def create(self, activo: ActivoAlmacenamientoEntity) -> ActivoAlmacenamientoEntity:
        model = ActivoAlmacenamiento(
            capacidadNominal_kWh=activo.capacidadNominal_kWh,
            potenciaMaximaCarga_kW=activo.potenciaMaximaCarga_kW,
            potenciaMaximaDescarga_kW=activo.potenciaMaximaDescarga_kW,
            eficienciaCicloCompleto_pct=activo.eficienciaCicloCompleto_pct,
            profundidadDescargaMax_pct=activo.profundidadDescargaMax_pct,
            idComunidadEnergetica=activo.idComunidadEnergetica
        )
            
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return self._map_to_entity(model)
        
    def update(self, activo: ActivoAlmacenamientoEntity) -> ActivoAlmacenamientoEntity:
        model = self.db.query(ActivoAlmacenamiento).filter_by(idActivoAlmacenamiento=activo.idActivoAlmacenamiento).first()
        if model:
            model.capacidadNominal_kWh = activo.capacidadNominal_kWh
            model.potenciaMaximaCarga_kW = activo.potenciaMaximaCarga_kW
            model.potenciaMaximaDescarga_kW = activo.potenciaMaximaDescarga_kW
            model.eficienciaCicloCompleto_pct = activo.eficienciaCicloCompleto_pct
            model.profundidadDescargaMax_pct = activo.profundidadDescargaMax_pct
            
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None
        
    def delete(self, idActivoAlmacenamiento: int) -> None:
        model = self.db.query(ActivoAlmacenamiento).filter_by(idActivoAlmacenamiento=idActivoAlmacenamiento).first()
        if model:
            self.db.delete(model)
            self.db.commit()