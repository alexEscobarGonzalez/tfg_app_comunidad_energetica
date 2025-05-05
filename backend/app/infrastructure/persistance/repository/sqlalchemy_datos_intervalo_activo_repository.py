from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository
from app.infrastructure.persistance.models.datos_intervalo_activo_tabla import DatosIntervaloActivo

class SqlAlchemyDatosIntervaloActivoRepository(DatosIntervaloActivoRepository):
    def __init__(self, session: Session):
        self.session = session
        
    def _to_entity(self, model: DatosIntervaloActivo) -> DatosIntervaloActivoEntity:
        return DatosIntervaloActivoEntity(
            idDatosIntervaloActivo=model.idDatosIntervaloActivo,
            timestamp=model.timestamp,
            energiaGenerada_kWh=model.energiaGenerada_kWh,
            energiaCargada_kWh=model.energiaCargada_kWh,
            energiaDescargada_kWh=model.energiaDescargada_kWh,
            SoC_kWh=model.SoC_kWh,
            idResultadoActivoGen=model.idResultadoActivoGen,
            idResultadoActivoAlm=model.idResultadoActivoAlm
        )
        
    def _to_model(self, entity: DatosIntervaloActivoEntity) -> DatosIntervaloActivo:
        return DatosIntervaloActivo(
            idDatosIntervaloActivo=entity.idDatosIntervaloActivo,
            timestamp=entity.timestamp,
            energiaGenerada_kWh=entity.energiaGenerada_kWh,
            energiaCargada_kWh=entity.energiaCargada_kWh,
            energiaDescargada_kWh=entity.energiaDescargada_kWh,
            SoC_kWh=entity.SoC_kWh,
            idResultadoActivoGen=entity.idResultadoActivoGen,
            idResultadoActivoAlm=entity.idResultadoActivoAlm
        )
        
    def get_by_id(self, datos_intervalo_id: int) -> Optional[DatosIntervaloActivoEntity]:
        datos = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.idDatosIntervaloActivo == datos_intervalo_id
        ).first()
        return self._to_entity(datos) if datos else None
    
    def get_by_resultado_activo_gen_id(self, resultado_activo_gen_id: int) -> List[DatosIntervaloActivoEntity]:
        datos_list = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.idResultadoActivoGen == resultado_activo_gen_id
        ).order_by(DatosIntervaloActivo.timestamp).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def get_by_resultado_activo_alm_id(self, resultado_activo_alm_id: int) -> List[DatosIntervaloActivoEntity]:
        datos_list = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.idResultadoActivoAlm == resultado_activo_alm_id
        ).order_by(DatosIntervaloActivo.timestamp).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def get_by_timestamp_range(self, resultado_activo_id: int, is_generacion: bool, start_time: datetime, end_time: datetime) -> List[DatosIntervaloActivoEntity]:
        query = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.timestamp >= start_time,
            DatosIntervaloActivo.timestamp <= end_time
        )
        
        if is_generacion:
            query = query.filter(DatosIntervaloActivo.idResultadoActivoGen == resultado_activo_id)
        else:
            query = query.filter(DatosIntervaloActivo.idResultadoActivoAlm == resultado_activo_id)
            
        datos_list = query.order_by(DatosIntervaloActivo.timestamp).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def list(self, skip: int = 0, limit: int = 100) -> List[DatosIntervaloActivoEntity]:
        datos_list = self.session.query(DatosIntervaloActivo).order_by(
            DatosIntervaloActivo.timestamp
        ).offset(skip).limit(limit).all()
        return [self._to_entity(datos) for datos in datos_list]
    
    def create(self, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        db_datos = self._to_model(datos_intervalo)
        db_datos.idDatosIntervaloActivo = None  # Asegurar que se autoincrementa
        
        self.session.add(db_datos)
        self.session.commit()
        self.session.refresh(db_datos)
        
        return self._to_entity(db_datos)
    
    def create_bulk(self, datos_intervalos: List[DatosIntervaloActivoEntity]) -> List[DatosIntervaloActivoEntity]:
        db_datos_list = [self._to_model(datos) for datos in datos_intervalos]
        for db_datos in db_datos_list:
            db_datos.idDatosIntervaloActivo = None  # Asegurar que se autoincrementa
        
        self.session.add_all(db_datos_list)
        self.session.commit()
        
        # No podemos hacer refresh de múltiples objetos fácilmente
        # Devolvemos las entidades con los IDs generados
        return [self._to_entity(db_datos) for db_datos in db_datos_list]
    
    def update(self, datos_intervalo_id: int, datos_intervalo: DatosIntervaloActivoEntity) -> DatosIntervaloActivoEntity:
        db_datos = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.idDatosIntervaloActivo == datos_intervalo_id
        ).first()
        
        if not db_datos:
            raise ValueError(f"Datos de intervalo con id {datos_intervalo_id} no encontrados")
        
        # Actualizar atributos
        db_datos.timestamp = datos_intervalo.timestamp
        db_datos.energiaGenerada_kWh = datos_intervalo.energiaGenerada_kWh
        db_datos.energiaCargada_kWh = datos_intervalo.energiaCargada_kWh
        db_datos.energiaDescargada_kWh = datos_intervalo.energiaDescargada_kWh
        db_datos.SoC_kWh = datos_intervalo.SoC_kWh
        db_datos.idResultadoActivoGen = datos_intervalo.idResultadoActivoGen
        db_datos.idResultadoActivoAlm = datos_intervalo.idResultadoActivoAlm
        
        self.session.commit()
        self.session.refresh(db_datos)
        
        return self._to_entity(db_datos)
    
    def delete(self, datos_intervalo_id: int) -> None:
        db_datos = self.session.query(DatosIntervaloActivo).filter(
            DatosIntervaloActivo.idDatosIntervaloActivo == datos_intervalo_id
        ).first()
        
        if not db_datos:
            raise ValueError(f"Datos de intervalo con id {datos_intervalo_id} no encontrados")
        
        self.session.delete(db_datos)
        self.session.commit()