from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository
from app.infrastructure.persistance.models.datos_intervalo_participante_tabla import DatosIntervaloParticipante

class SqlAlchemyDatosIntervaloParticipanteRepository(DatosIntervaloParticipanteRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def _to_entity(self, model: DatosIntervaloParticipante) -> DatosIntervaloParticipanteEntity:
        return DatosIntervaloParticipanteEntity(
            idDatosIntervaloParticipante=model.idDatosIntervaloParticipante,
            timestamp=model.timestamp,
            consumoReal_kWh=model.consumoReal_kWh,
            autoconsumo_kWh=model.autoconsumo_kWh,
            energiaRecibidaReparto_kWh=model.energiaRecibidaReparto_kWh,
            energiaAlmacenamiento_kWh=model.energiaAlmacenamiento_kWh,
            energiaDiferencia_kWh=model.energiaDiferencia_kWh,
            excedenteVertidoCompensado_kWh=model.excedenteVertidoCompensado_kWh,
            precioImportacionIntervalo=model.precioImportacionIntervalo,
            precioExportacionIntervalo=model.precioExportacionIntervalo,
            idResultadoParticipante=model.idResultadoParticipante
        )
        
    def _to_model(self, entity: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipante:
        return DatosIntervaloParticipante(
            idDatosIntervaloParticipante=entity.idDatosIntervaloParticipante,
            timestamp=entity.timestamp,
            consumoReal_kWh=entity.consumoReal_kWh,
            autoconsumo_kWh=entity.autoconsumo_kWh,
            energiaRecibidaReparto_kWh=entity.energiaRecibidaReparto_kWh,
            energiaAlmacenamiento_kWh=entity.energiaAlmacenamiento_kWh,
            energiaDiferencia_kWh=entity.energiaDiferencia_kWh,
            excedenteVertidoCompensado_kWh=entity.excedenteVertidoCompensado_kWh,
            precioImportacionIntervalo=entity.precioImportacionIntervalo,
            precioExportacionIntervalo=entity.precioExportacionIntervalo,
            idResultadoParticipante=entity.idResultadoParticipante
        )
        
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloParticipanteEntity]:
        datos = self.db.query(DatosIntervaloParticipante).filter(
            DatosIntervaloParticipante.idDatosIntervaloParticipante == datos_intervalo_id
        ).first()
        return self._to_entity(datos) if datos else None
    
    def get_by_resultado_participante_id(self, resultado_participante_id: int) -> List[DatosIntervaloParticipanteEntity]:
        datos_list = self.db.query(DatosIntervaloParticipante).filter(
            DatosIntervaloParticipante.idResultadoParticipante == resultado_participante_id
        ).order_by(DatosIntervaloParticipante.timestamp).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def get_by_timestamp_range(self, resultado_participante_id: int, start_time: datetime, end_time: datetime) -> List[DatosIntervaloParticipanteEntity]:
        datos_list = self.db.query(DatosIntervaloParticipante).filter(
            DatosIntervaloParticipante.idResultadoParticipante == resultado_participante_id,
            DatosIntervaloParticipante.timestamp >= start_time,
            DatosIntervaloParticipante.timestamp <= end_time
        ).order_by(DatosIntervaloParticipante.timestamp).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloParticipanteEntity]:
        datos_list = self.db.query(DatosIntervaloParticipante).order_by(
            DatosIntervaloParticipante.idResultadoParticipante, 
            DatosIntervaloParticipante.timestamp
        ).offset(skip).limit(limit).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def create(self, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        db_datos = self._to_model(datos_intervalo)
        db_datos.idDatosIntervaloParticipante = None  # Asegurar que se autoincrementa
        
        self.db.add(db_datos)
        self.db.commit()
        self.db.refresh(db_datos)
        
        return self._to_entity(db_datos)
    
    def create_bulk(self, datos_intervalos: List[DatosIntervaloParticipanteEntity]) -> List[DatosIntervaloParticipanteEntity]:
        db_datos_list = [self._to_model(datos) for datos in datos_intervalos]
        for db_datos in db_datos_list:
            db_datos.idDatosIntervaloParticipante = None  # Asegurar que se autoincrementa
        
        self.db.add_all(db_datos_list)
        self.db.commit()
        
        return [self._to_entity(db_datos) for db_datos in db_datos_list]
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloParticipanteEntity) -> DatosIntervaloParticipanteEntity:
        db_datos = self.db.query(DatosIntervaloParticipante).filter(
            DatosIntervaloParticipante.idDatosIntervaloParticipante == datos_intervalo_id
        ).first()
        
        if not db_datos:
            raise ValueError(f"Datos de intervalo con id {datos_intervalo_id} no encontrados")
        

        db_datos.timestamp = datos_intervalo.timestamp
        db_datos.consumoReal_kWh = datos_intervalo.consumoReal_kWh
        db_datos.autoconsumo_kWh = datos_intervalo.autoconsumo_kWh
        db_datos.energiaRecibidaReparto_kWh = datos_intervalo.energiaRecibidaReparto_kWh
        db_datos.energiaAlmacenamiento_kWh = datos_intervalo.energiaAlmacenamiento_kWh
        db_datos.energiaDiferencia_kWh = datos_intervalo.energiaDiferencia_kWh
        db_datos.excedenteVertidoCompensado_kWh = datos_intervalo.excedenteVertidoCompensado_kWh
        db_datos.precioImportacionIntervalo = datos_intervalo.precioImportacionIntervalo
        db_datos.precioExportacionIntervalo = datos_intervalo.precioExportacionIntervalo
        
        self.db.commit()
        self.db.refresh(db_datos)
        
        return self._to_entity(db_datos)
    
    def delete(self, datos_intervalo_id: int) -> None:
        db_datos = self.db.query(DatosIntervaloParticipante).filter(
            DatosIntervaloParticipante.idDatosIntervaloParticipante == datos_intervalo_id
        ).first()
        
        if not db_datos:
            raise ValueError(f"Datos de intervalo con id {datos_intervalo_id} no encontrados")
        
        self.db.delete(db_datos)
        self.db.commit()