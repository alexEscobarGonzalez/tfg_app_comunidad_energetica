from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.infrastructure.persistance.models.contrato_autoconsumo_tabla import ContratoAutoconsumo
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository

class SqlAlchemyContratoAutoconsumoRepository(ContratoAutoconsumoRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _map_to_entity(self, model: ContratoAutoconsumo) -> ContratoAutoconsumoEntity:
        """Convierte un modelo de tabla a una entidad de dominio"""
        return ContratoAutoconsumoEntity(
            idContrato=model.idContrato,
            tipoContrato=model.tipoContrato,
            precioEnergiaImportacion_eur_kWh=model.precioEnergiaImportacion_eur_kWh,
            precioCompensacionExcedentes_eur_kWh=model.precioCompensacionExcedentes_eur_kWh,
            potenciaContratada_kW=model.potenciaContratada_kW,
            precioPotenciaContratado_eur_kWh=model.precioPotenciaContratado_eur_kWh,
            idParticipante=model.idParticipante
        )
        
    def get_by_id(self, idContrato: int) -> Optional[ContratoAutoconsumoEntity]:
        model = self.db.query(ContratoAutoconsumo).filter_by(idContrato=idContrato).first()
        if model:
            return self._map_to_entity(model)
        return None
        
    def get_by_participante(self, idParticipante: int) -> Optional[ContratoAutoconsumoEntity]:
        model = self.db.query(ContratoAutoconsumo).filter_by(idParticipante=idParticipante).first()
        if model:
            return self._map_to_entity(model)
        return None
    
    def list(self) -> List[ContratoAutoconsumoEntity]:
        models = self.db.query(ContratoAutoconsumo).all()
        return [self._map_to_entity(model) for model in models]
        
    def create(self, contrato: ContratoAutoconsumoEntity) -> ContratoAutoconsumoEntity:
        model = ContratoAutoconsumo(
            tipoContrato=contrato.tipoContrato,
            precioEnergiaImportacion_eur_kWh=contrato.precioEnergiaImportacion_eur_kWh,
            precioCompensacionExcedentes_eur_kWh=contrato.precioCompensacionExcedentes_eur_kWh,
            potenciaContratada_kW=contrato.potenciaContratada_kW,
            precioPotenciaContratado_eur_kWh=contrato.precioPotenciaContratado_eur_kWh,
            idParticipante=contrato.idParticipante
        )
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        contrato.idContrato = model.idContrato
        return contrato
        
    def update(self, contrato: ContratoAutoconsumoEntity) -> ContratoAutoconsumoEntity:
        model = self.db.query(ContratoAutoconsumo).filter_by(idContrato=contrato.idContrato).first()
        if model:
            model.tipoContrato = contrato.tipoContrato
            model.precioEnergiaImportacion_eur_kWh = contrato.precioEnergiaImportacion_eur_kWh
            model.precioCompensacionExcedentes_eur_kWh = contrato.precioCompensacionExcedentes_eur_kWh
            model.potenciaContratada_kW = contrato.potenciaContratada_kW
            model.precioPotenciaContratado_eur_kWh = contrato.precioPotenciaContratado_eur_kWh
            # No actualizamos el idParticipante ya que es una relación fija (clave única)
            
            self.db.commit()
            self.db.refresh(model)
            return self._map_to_entity(model)
        return None
        
    def delete(self, idContrato: int) -> None:
        model = self.db.query(ContratoAutoconsumo).filter_by(idContrato=idContrato).first()
        if model:
            self.db.delete(model)
            self.db.commit()