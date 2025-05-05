from typing import List, Optional, Dict
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from app.infrastructure.persistance.models.resultado_simulacion_activo_generacion_tabla import ResultadoSimulacionActivoGeneracion

class SqlAlchemyResultadoSimulacionActivoGeneracionRepository(ResultadoSimulacionActivoGeneracionRepository):
    def __init__(self, session: Session):
        self.session = session
        
    def _to_entity(self, model: ResultadoSimulacionActivoGeneracion) -> ResultadoSimulacionActivoGeneracionEntity:
        return ResultadoSimulacionActivoGeneracionEntity(
            idResultadoActivoGen=model.idResultadoActivoGen,
            energiaTotalGenerada_kWh=model.energiaTotalGenerada_kWh,
            factorCapacidad_pct=model.factorCapacidad_pct,
            performanceRatio_pct=model.performanceRatio_pct,
            horasOperacionEquivalentes=model.horasOperacionEquivalentes,
            idResultadoSimulacion=model.idResultadoSimulacion,
            idActivoGeneracion=model.idActivoGeneracion
        )
        
    def _to_model(self, entity: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracion:
        return ResultadoSimulacionActivoGeneracion(
            idResultadoActivoGen=entity.idResultadoActivoGen,
            energiaTotalGenerada_kWh=entity.energiaTotalGenerada_kWh,
            factorCapacidad_pct=entity.factorCapacidad_pct,
            performanceRatio_pct=entity.performanceRatio_pct,
            horasOperacionEquivalentes=entity.horasOperacionEquivalentes,
            idResultadoSimulacion=entity.idResultadoSimulacion,
            idActivoGeneracion=entity.idActivoGeneracion
        )
        
    def get_by_id(self, resultado_activo_gen_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        resultado = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idResultadoActivoGen == resultado_activo_gen_id
        ).first()
        return self._to_entity(resultado) if resultado else None
    
    def get_by_resultado_simulacion_id(self, resultado_simulacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        resultados = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idResultadoSimulacion == resultado_simulacion_id
        ).all()
        return [self._to_entity(r) for r in resultados]
    
    def get_by_activo_generacion_id(self, activo_generacion_id: int) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        resultados = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idActivoGeneracion == activo_generacion_id
        ).all()
        return [self._to_entity(r) for r in resultados]
    
    def get_by_resultado_simulacion_and_activo(self, resultado_simulacion_id: int, activo_generacion_id: int) -> Optional[ResultadoSimulacionActivoGeneracionEntity]:
        resultado = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idResultadoSimulacion == resultado_simulacion_id,
            ResultadoSimulacionActivoGeneracion.idActivoGeneracion == activo_generacion_id
        ).first()
        return self._to_entity(resultado) if resultado else None
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        resultados = self.session.query(ResultadoSimulacionActivoGeneracion).offset(skip).limit(limit).all()
        return [self._to_entity(r) for r in resultados]
    
    def create(self, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        db_resultado = self._to_model(resultado_activo_gen)
        db_resultado.idResultadoActivoGen = None  # Aseguramos que se autoincrementa
        
        self.session.add(db_resultado)
        self.session.commit()
        self.session.refresh(db_resultado)
        
        return self._to_entity(db_resultado)
    
    def update(self, resultado_activo_gen_id: int, resultado_activo_gen: ResultadoSimulacionActivoGeneracionEntity) -> ResultadoSimulacionActivoGeneracionEntity:
        db_resultado = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idResultadoActivoGen == resultado_activo_gen_id
        ).first()
        
        if not db_resultado:
            raise ValueError(f"Resultado con id {resultado_activo_gen_id} no encontrado")
        
        # Actualizar atributos
        db_resultado.energiaTotalGenerada_kWh = resultado_activo_gen.energiaTotalGenerada_kWh
        db_resultado.factorCapacidad_pct = resultado_activo_gen.factorCapacidad_pct
        db_resultado.performanceRatio_pct = resultado_activo_gen.performanceRatio_pct
        db_resultado.horasOperacionEquivalentes = resultado_activo_gen.horasOperacionEquivalentes
        
        self.session.commit()
        self.session.refresh(db_resultado)
        
        return self._to_entity(db_resultado)
    
    def delete(self, resultado_activo_gen_id: int) -> None:
        db_resultado = self.session.query(ResultadoSimulacionActivoGeneracion).filter(
            ResultadoSimulacionActivoGeneracion.idResultadoActivoGen == resultado_activo_gen_id
        ).first()
        
        if not db_resultado:
            raise ValueError(f"Resultado con id {resultado_activo_gen_id} no encontrado")
        
        self.session.delete(db_resultado)
        self.session.commit()
    
    def create_bulk(self, resultados: List[Dict]) -> List[ResultadoSimulacionActivoGeneracionEntity]:
        """
        Crea múltiples registros de resultados de simulación de activos de generación a la vez.
        
        Args:
            resultados: Lista de diccionarios con los resultados de activos a guardar
            
        Returns:
            Lista de entidades ResultadoSimulacionActivoGeneracionEntity creadas
        """
        models = []
        try:
            for resultado in resultados:
                # Crear modelo a partir del diccionario de datos
                model = ResultadoSimulacionActivoGeneracion(
                    energiaTotalGenerada_kWh=resultado.get('energiaGeneradaTotal_kWh', 0),
                    factorCapacidad_pct=resultado.get('factorCapacidad', 0),
                    performanceRatio_pct=resultado.get('eficienciaUtilizacion', 0),
                    horasOperacionEquivalentes=resultado.get('horasProduccion', 0),
                    idResultadoSimulacion=resultado.get('idSimulacion'),
                    idActivoGeneracion=resultado.get('idActivoGeneracion')
                )
                self.session.add(model)
                models.append(model)
            
            # Hacer commit de todos los cambios a la vez
            self.session.commit()
            
            # Refrescar todos los modelos para obtener sus IDs generados
            for model in models:
                self.session.refresh(model)
            
            # Mapear modelos a entidades
            return [self._to_entity(model) for model in models]
        
        except SQLAlchemyError as e:
            self.session.rollback()
            print(f"Error al crear resultados de activos de generación en bloque: {e}")
            raise e