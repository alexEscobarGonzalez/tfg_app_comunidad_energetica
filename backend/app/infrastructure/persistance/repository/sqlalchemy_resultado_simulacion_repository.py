from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.infrastructure.persistance.models.resultado_simulacion_tabla import ResultadoSimulacion

class SqlAlchemyResultadoSimulacionRepository(ResultadoSimulacionRepository):
    def __init__(self, db: Session):
        self.db = db
        
    def get_by_id(self, resultado_id: int) -> Optional[ResultadoSimulacionEntity]:
        resultado = self.db.query(ResultadoSimulacion).filter(ResultadoSimulacion.idResultado == resultado_id).first()
        if resultado:
            return self._map_to_entity(resultado)
        return None
    
    def get_by_simulacion_id(self, simulacion_id: int) -> Optional[ResultadoSimulacionEntity]:
        resultado = self.db.query(ResultadoSimulacion).filter(ResultadoSimulacion.idSimulacion == simulacion_id).first()
        if resultado:
            return self._map_to_entity(resultado)
        return None
    
    def list(self, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionEntity]:
        resultados = self.db.query(ResultadoSimulacion).offset(skip).limit(limit).all()
        return [self._map_to_entity(r) for r in resultados]
    
    def create(self, resultado: ResultadoSimulacionEntity) -> ResultadoSimulacionEntity:
        db_resultado = ResultadoSimulacion(
            fechaCreacion=resultado.fechaCreacion,
            costeTotalEnergia_eur=resultado.costeTotalEnergia_eur,
            ahorroTotal_eur=resultado.ahorroTotal_eur,
            ingresoTotalExportacion_eur=resultado.ingresoTotalExportacion_eur,
            paybackPeriod_anios=resultado.paybackPeriod_anios,
            roi_pct=resultado.roi_pct,
            tasaAutoconsumoSCR_pct=resultado.tasaAutoconsumoSCR_pct,
            tasaAutosuficienciaSSR_pct=resultado.tasaAutosuficienciaSSR_pct,
            energiaTotalImportada_kWh=resultado.energiaTotalImportada_kWh,
            energiaTotalExportada_kWh=resultado.energiaTotalExportada_kWh,
            energiaCompartidaInterna_kWh=resultado.energiaCompartidaInterna_kWh,
            reduccionPicoDemanda_kW=resultado.reduccionPicoDemanda_kW,
            reduccionPicoDemanda_pct=resultado.reduccionPicoDemanda_pct,
            reduccionCO2_kg=resultado.reduccionCO2_kg,
            idSimulacion=resultado.idSimulacion
        )
        
        self.db.add(db_resultado)
        self.db.commit()
        self.db.refresh(db_resultado)
        
        return self._map_to_entity(db_resultado)
    
    def update(self, resultado_id: int, resultado: ResultadoSimulacionEntity) -> ResultadoSimulacionEntity:
        db_resultado = self.db.query(ResultadoSimulacion).filter(ResultadoSimulacion.idResultado == resultado_id).first()
        if not db_resultado:
            return None
        
        # Actualizar campos
        if resultado.fechaCreacion:
            db_resultado.fechaCreacion = resultado.fechaCreacion
        if resultado.costeTotalEnergia_eur is not None:
            db_resultado.costeTotalEnergia_eur = resultado.costeTotalEnergia_eur
        if resultado.ahorroTotal_eur is not None:
            db_resultado.ahorroTotal_eur = resultado.ahorroTotal_eur
        if resultado.ingresoTotalExportacion_eur is not None:
            db_resultado.ingresoTotalExportacion_eur = resultado.ingresoTotalExportacion_eur
        if resultado.paybackPeriod_anios is not None:
            db_resultado.paybackPeriod_anios = resultado.paybackPeriod_anios
        if resultado.roi_pct is not None:
            db_resultado.roi_pct = resultado.roi_pct
        if resultado.tasaAutoconsumoSCR_pct is not None:
            db_resultado.tasaAutoconsumoSCR_pct = resultado.tasaAutoconsumoSCR_pct
        if resultado.tasaAutosuficienciaSSR_pct is not None:
            db_resultado.tasaAutosuficienciaSSR_pct = resultado.tasaAutosuficienciaSSR_pct
        if resultado.energiaTotalImportada_kWh is not None:
            db_resultado.energiaTotalImportada_kWh = resultado.energiaTotalImportada_kWh
        if resultado.energiaTotalExportada_kWh is not None:
            db_resultado.energiaTotalExportada_kWh = resultado.energiaTotalExportada_kWh
        if resultado.energiaCompartidaInterna_kWh is not None:
            db_resultado.energiaCompartidaInterna_kWh = resultado.energiaCompartidaInterna_kWh
        if resultado.reduccionPicoDemanda_kW is not None:
            db_resultado.reduccionPicoDemanda_kW = resultado.reduccionPicoDemanda_kW
        if resultado.reduccionPicoDemanda_pct is not None:
            db_resultado.reduccionPicoDemanda_pct = resultado.reduccionPicoDemanda_pct
        if resultado.reduccionCO2_kg is not None:
            db_resultado.reduccionCO2_kg = resultado.reduccionCO2_kg
            
        self.db.commit()
        self.db.refresh(db_resultado)
        
        return self._map_to_entity(db_resultado)
    
    def delete(self, resultado_id: int) -> None:
        db_resultado = self.db.query(ResultadoSimulacion).filter(ResultadoSimulacion.idResultado == resultado_id).first()
        if db_resultado:
            self.db.delete(db_resultado)
            self.db.commit()
            
    def _map_to_entity(self, db_resultado: ResultadoSimulacion) -> ResultadoSimulacionEntity:
        """Mapea un objeto de la base de datos a una entidad de dominio"""
        return ResultadoSimulacionEntity(
            idResultado=db_resultado.idResultado,
            fechaCreacion=db_resultado.fechaCreacion,
            costeTotalEnergia_eur=db_resultado.costeTotalEnergia_eur,
            ahorroTotal_eur=db_resultado.ahorroTotal_eur,
            ingresoTotalExportacion_eur=db_resultado.ingresoTotalExportacion_eur,
            paybackPeriod_anios=db_resultado.paybackPeriod_anios,
            roi_pct=db_resultado.roi_pct,
            tasaAutoconsumoSCR_pct=db_resultado.tasaAutoconsumoSCR_pct,
            tasaAutosuficienciaSSR_pct=db_resultado.tasaAutosuficienciaSSR_pct,
            energiaTotalImportada_kWh=db_resultado.energiaTotalImportada_kWh,
            energiaTotalExportada_kWh=db_resultado.energiaTotalExportada_kWh,
            energiaCompartidaInterna_kWh=db_resultado.energiaCompartidaInterna_kWh,
            reduccionPicoDemanda_kW=db_resultado.reduccionPicoDemanda_kW,
            reduccionPicoDemanda_pct=db_resultado.reduccionPicoDemanda_pct,
            reduccionCO2_kg=db_resultado.reduccionCO2_kg,
            idSimulacion=db_resultado.idSimulacion
        )