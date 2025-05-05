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
        # Verificar si ya existe un resultado para esa combinación de simulación y activo
        existing = self.get_by_resultado_simulacion_and_activo(
            resultado_activo_alm.idResultadoSimulacion,
            resultado_activo_alm.idActivoAlmacenamiento
        )
        
        if existing:
            # Si ya existe, actualizamos en lugar de crear uno nuevo
            return self.update(existing.idResultadoActivoAlm, resultado_activo_alm)
        
        # Crear nuevo registro
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
        
        # Actualizar campos del resultado
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
        """Convierte un modelo de la base de datos a una entidad de dominio"""
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
    
    def create_bulk(self, resultados: List[Dict]) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
        """
        Crea múltiples registros de resultados de simulación de activos de almacenamiento a la vez.
        
        Args:
            resultados: Lista de diccionarios con los resultados de activos a guardar
            
        Returns:
            Lista de entidades ResultadoSimulacionActivoAlmacenamientoEntity creadas
        """
        if not resultados:
            return []
            
        models = []
        try:
            for resultado in resultados:
                # Filtrar solo los resultados que contengan tipo_activo='almacenamiento'
                if resultado.get('tipo_activo', '') != 'almacenamiento':
                    continue
                
                # Crear modelo a partir del diccionario de datos
                model = ResultadoSimulacionActivoAlmacenamiento(
                    energiaTotalCargada_kWh=resultado.get('energiaAlmacenadaTotal_kWh', 0),
                    energiaTotalDescargada_kWh=resultado.get('energiaLiberadaTotal_kWh', 0),
                    ciclosEquivalentes=max(resultado.get('ciclosCarga', 0), resultado.get('ciclosDescarga', 0)),
                    perdidasEficiencia_kWh=0,  # Calculado posteriormente si es necesario
                    socMedio_pct=0,  # Requiere datos de intervalo para calcular
                    socMin_pct=0,  # Requiere datos de intervalo para calcular
                    socMax_pct=0,  # Requiere datos de intervalo para calcular
                    degradacionEstimada_pct=0,  # Se calculará más adelante si es necesario
                    throughputTotal_kWh=resultado.get('energiaAlmacenadaTotal_kWh', 0) + resultado.get('energiaLiberadaTotal_kWh', 0),
                    idResultadoSimulacion=resultado.get('idSimulacion'),
                    idActivoAlmacenamiento=resultado.get('idActivoAlmacenamiento')
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