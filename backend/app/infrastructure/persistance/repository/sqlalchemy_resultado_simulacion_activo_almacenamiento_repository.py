from typing import List, Optional, Dict
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from app.infrastructure.persistance.models.resultado_simulacion_activo_almacenamiento_tabla import ResultadoSimulacionActivoAlmacenamiento

class SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(ResultadoSimulacionActivoAlmacenamientoRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def get_by_id(self, resultado_activo_alm_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        resultado = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idResultadoActivoAlm == resultado_activo_alm_id
        ).first()
        
        if resultado:
            return self._map_to_entity(resultado)
        return None
    
    def get_by_resultado_simulacion_id(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        resultados = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idResultadoSimulacion == resultado_simulacion_id
        ).all()
        
        return [self._map_to_entity(r) for r in resultados]
    
    def get_by_activo_almacenamiento_id(self, activo_almacenamiento_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        resultados = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idActivoAlmacenamiento == activo_almacenamiento_id
        ).all()
        
        return [self._map_to_entity(r) for r in resultados]
    
    def get_by_resultado_simulacion_and_activo(self, resultado_simulacion_id: int, activo_almacenamiento_id: int) -> Optional[ResultadoSimulacionActivoAlmacenamientoEntity]:
        resultado = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idResultadoSimulacion == resultado_simulacion_id,
            ResultadoSimulacionActivoAlmacenamiento.idActivoAlmacenamiento == activo_almacenamiento_id
        ).first()
        
        if resultado:
            return self._map_to_entity(resultado)
        return None
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        resultados = self.db.query(ResultadoSimulacionActivoAlmacenamiento).offset(skip).limit(limit).all()
        return [self._map_to_entity(r) for r in resultados]
    
    def create(self, resultado_activo_alm: ResultadoSimulacionActivoAlmacenamientoEntity) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        existing = self.get_by_resultado_simulacion_and_activo(
            resultado_activo_alm.idResultadoSimulacion,
            resultado_activo_alm.idActivoAlmacenamiento
        )
        
        if existing:
            return self.update(existing.idResultadoActivoAlm, resultado_activo_alm)
        
        db_resultado = ResultadoSimulacionActivoAlmacenamiento(
            energiaTotalCargada_kWh=resultado_activo_alm.energiaTotalCargada_kWh,
            energiaTotalDescargada_kWh=resultado_activo_alm.energiaTotalDescargada_kWh,
            ciclosEquivalentes=resultado_activo_alm.ciclosEquivalentes,
            perdidasEficiencia_kWh=resultado_activo_alm.perdidasEficiencia_kWh,
            socMedio_pct=resultado_activo_alm.socMedio_pct,
            socMin_pct=resultado_activo_alm.socMin_pct,
            socMax_pct=resultado_activo_alm.socMax_pct,
            degradacionEstimada_pct=resultado_activo_alm.degradacionEstimada_pct,
            throughputTotal_kWh=resultado_activo_alm.throughputTotal_kWh,
            idResultadoSimulacion=resultado_activo_alm.idResultadoSimulacion,
            idActivoAlmacenamiento=resultado_activo_alm.idActivoAlmacenamiento
        )
        
        self.db.add(db_resultado)
        self.db.commit()
        self.db.refresh(db_resultado)
        
        return self._map_to_entity(db_resultado)
    
    def update(self, resultado_activo_alm_id: int, resultado_activo_alm: ResultadoSimulacionActivoAlmacenamientoEntity) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        db_resultado = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idResultadoActivoAlm == resultado_activo_alm_id
        ).first()
        
        if not db_resultado:
            return None
        
        if resultado_activo_alm.energiaTotalCargada_kWh is not None:
            db_resultado.energiaTotalCargada_kWh = resultado_activo_alm.energiaTotalCargada_kWh
        if resultado_activo_alm.energiaTotalDescargada_kWh is not None:
            db_resultado.energiaTotalDescargada_kWh = resultado_activo_alm.energiaTotalDescargada_kWh
        if resultado_activo_alm.ciclosEquivalentes is not None:
            db_resultado.ciclosEquivalentes = resultado_activo_alm.ciclosEquivalentes
        if resultado_activo_alm.perdidasEficiencia_kWh is not None:
            db_resultado.perdidasEficiencia_kWh = resultado_activo_alm.perdidasEficiencia_kWh
        if resultado_activo_alm.socMedio_pct is not None:
            db_resultado.socMedio_pct = resultado_activo_alm.socMedio_pct
        if resultado_activo_alm.socMin_pct is not None:
            db_resultado.socMin_pct = resultado_activo_alm.socMin_pct
        if resultado_activo_alm.socMax_pct is not None:
            db_resultado.socMax_pct = resultado_activo_alm.socMax_pct
        if resultado_activo_alm.degradacionEstimada_pct is not None:
            db_resultado.degradacionEstimada_pct = resultado_activo_alm.degradacionEstimada_pct
        if resultado_activo_alm.throughputTotal_kWh is not None:
            db_resultado.throughputTotal_kWh = resultado_activo_alm.throughputTotal_kWh
            
        self.db.commit()
        self.db.refresh(db_resultado)
        
        return self._map_to_entity(db_resultado)
    
    def delete(self, resultado_activo_alm_id: int) -> None:
        db_resultado = self.db.query(ResultadoSimulacionActivoAlmacenamiento).filter(
            ResultadoSimulacionActivoAlmacenamiento.idResultadoActivoAlm == resultado_activo_alm_id
        ).first()
        
        if db_resultado:
            self.db.delete(db_resultado)
            self.db.commit()
    
    def _map_to_entity(self, db_resultado: ResultadoSimulacionActivoAlmacenamiento) -> ResultadoSimulacionActivoAlmacenamientoEntity:
        return ResultadoSimulacionActivoAlmacenamientoEntity(
            idResultadoActivoAlm=db_resultado.idResultadoActivoAlm,
            energiaTotalCargada_kWh=db_resultado.energiaTotalCargada_kWh,
            energiaTotalDescargada_kWh=db_resultado.energiaTotalDescargada_kWh,
            ciclosEquivalentes=db_resultado.ciclosEquivalentes,
            perdidasEficiencia_kWh=db_resultado.perdidasEficiencia_kWh,
            socMedio_pct=db_resultado.socMedio_pct,
            socMin_pct=db_resultado.socMin_pct,
            socMax_pct=db_resultado.socMax_pct,
            degradacionEstimada_pct=db_resultado.degradacionEstimada_pct,
            throughputTotal_kWh=db_resultado.throughputTotal_kWh,
            idResultadoSimulacion=db_resultado.idResultadoSimulacion,
            idActivoAlmacenamiento=db_resultado.idActivoAlmacenamiento
        )
    
    def create_bulk(self, resultados: List[ResultadoSimulacionActivoAlmacenamientoEntity], resultado_global_id: int) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        if not resultados:
            return []
            
        models = []
        try:
            for resultado in resultados:
                model = ResultadoSimulacionActivoAlmacenamiento(
                    energiaTotalCargada_kWh=resultado.energiaTotalCargada_kWh or 0,
                    energiaTotalDescargada_kWh=resultado.energiaTotalDescargada_kWh or 0,
                    ciclosEquivalentes=resultado.ciclosEquivalentes or 0,
                    perdidasEficiencia_kWh=resultado.perdidasEficiencia_kWh or 0,
                    socMedio_pct=resultado.socMedio_pct or 0,
                    socMin_pct=resultado.socMin_pct or 0,
                    socMax_pct=resultado.socMax_pct or 0,
                    degradacionEstimada_pct=resultado.degradacionEstimada_pct or 0,
                    throughputTotal_kWh=resultado.throughputTotal_kWh or 0,
                    idResultadoSimulacion=resultado_global_id,
                    idActivoAlmacenamiento=resultado.idActivoAlmacenamiento
                )
                self.db.add(model)
                models.append(model)
            
            # Hacer commit de todos los cambios a la vez
            if models:
                self.db.commit()
                
                # Refrescar todos los modelos para obtener sus IDs generados
                for model in models:
                    self.db.refresh(model)
            
            # Mapear modelos a entidades
            return [self._map_to_entity(model) for model in models]
        
        except SQLAlchemyError as e:
            self.db.rollback()
            print(f"Error al crear resultados de activos de almacenamiento en bloque: {e}")
            raise e