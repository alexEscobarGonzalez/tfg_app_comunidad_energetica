from typing import List, Optional
from sqlalchemy.orm import Session
from app.domain.entities.simulacion import SimulacionEntity, EstadoSimulacion, TipoEstrategiaExcedentes
from app.infrastructure.persistance.models.simulacion_tabla import Simulacion
from app.domain.repositories.simulacion_repository import SimulacionRepository

class SqlAlchemySimulacionRepository(SimulacionRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, simulacion_id: int) -> Optional[SimulacionEntity]:
        simulacion = self.db.query(Simulacion).filter(Simulacion.idSimulacion == simulacion_id).first()
        if simulacion:
            return SimulacionEntity(
                idSimulacion=simulacion.idSimulacion,
                nombreSimulacion=simulacion.nombreSimulacion,
                fechaInicio=simulacion.fechaInicio,
                fechaFin=simulacion.fechaFin,
                tiempo_medicion=simulacion.tiempo_medicion,
                estado=EstadoSimulacion(simulacion.estado),
                tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(simulacion.tipoEstrategiaExcedentes),
                idUsuario_creador=simulacion.idUsuario_creador,
                idComunidadEnergetica=simulacion.idComunidadEnergetica
            )
        return None

    def list(self, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        simulaciones = self.db.query(Simulacion).offset(skip).limit(limit).all()
        return [
            SimulacionEntity(
                idSimulacion=s.idSimulacion,
                nombreSimulacion=s.nombreSimulacion,
                fechaInicio=s.fechaInicio,
                fechaFin=s.fechaFin,
                tiempo_medicion=s.tiempo_medicion,
                estado=EstadoSimulacion(s.estado),
                tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(s.tipoEstrategiaExcedentes),
                idUsuario_creador=s.idUsuario_creador,
                idComunidadEnergetica=s.idComunidadEnergetica
            ) for s in simulaciones
        ]

    def list_by_comunidad(self, comunidad_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        simulaciones = self.db.query(Simulacion).filter(
            Simulacion.idComunidadEnergetica == comunidad_id
        ).offset(skip).limit(limit).all()
        
        return [
            SimulacionEntity(
                idSimulacion=s.idSimulacion,
                nombreSimulacion=s.nombreSimulacion,
                fechaInicio=s.fechaInicio,
                fechaFin=s.fechaFin,
                tiempo_medicion=s.tiempo_medicion,
                estado=EstadoSimulacion(s.estado),
                tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(s.tipoEstrategiaExcedentes),
                idUsuario_creador=s.idUsuario_creador,
                idComunidadEnergetica=s.idComunidadEnergetica
            ) for s in simulaciones
        ]

    def list_by_usuario(self, usuario_id: int, skip: int = 0, limit: int = 100) -> List[SimulacionEntity]:
        simulaciones = self.db.query(Simulacion).filter(
            Simulacion.idUsuario_creador == usuario_id
        ).offset(skip).limit(limit).all()
        
        return [
            SimulacionEntity(
                idSimulacion=s.idSimulacion,
                nombreSimulacion=s.nombreSimulacion,
                fechaInicio=s.fechaInicio,
                fechaFin=s.fechaFin,
                tiempo_medicion=s.tiempo_medicion,
                estado=EstadoSimulacion(s.estado),
                tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(s.tipoEstrategiaExcedentes),
                idUsuario_creador=s.idUsuario_creador,
                idComunidadEnergetica=s.idComunidadEnergetica
            ) for s in simulaciones
        ]

    def create(self, simulacion: SimulacionEntity) -> SimulacionEntity:
        db_simulacion = Simulacion(
            nombreSimulacion=simulacion.nombreSimulacion,
            fechaInicio=simulacion.fechaInicio,
            fechaFin=simulacion.fechaFin,
            tiempo_medicion=simulacion.tiempo_medicion,
            estado=simulacion.estado.value,
            tipoEstrategiaExcedentes=simulacion.tipoEstrategiaExcedentes.value,
            idUsuario_creador=simulacion.idUsuario_creador,
            idComunidadEnergetica=simulacion.idComunidadEnergetica
        )
        self.db.add(db_simulacion)
        self.db.commit()
        self.db.refresh(db_simulacion)
        
        return SimulacionEntity(
            idSimulacion=db_simulacion.idSimulacion,
            nombreSimulacion=db_simulacion.nombreSimulacion,
            fechaInicio=db_simulacion.fechaInicio,
            fechaFin=db_simulacion.fechaFin,
            tiempo_medicion=db_simulacion.tiempo_medicion,
            estado=EstadoSimulacion(db_simulacion.estado),
            tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(db_simulacion.tipoEstrategiaExcedentes),
            idUsuario_creador=db_simulacion.idUsuario_creador,
            idComunidadEnergetica=db_simulacion.idComunidadEnergetica
        )

    def update(self, simulacion_id: int, simulacion: SimulacionEntity) -> SimulacionEntity:
        db_simulacion = self.db.query(Simulacion).filter(Simulacion.idSimulacion == simulacion_id).first()
        if not db_simulacion:
            return None
        
        db_simulacion.nombreSimulacion = simulacion.nombreSimulacion
        db_simulacion.fechaInicio = simulacion.fechaInicio
        db_simulacion.fechaFin = simulacion.fechaFin
        db_simulacion.tiempo_medicion = simulacion.tiempo_medicion
        db_simulacion.estado = simulacion.estado.value
        db_simulacion.tipoEstrategiaExcedentes = simulacion.tipoEstrategiaExcedentes.value
        db_simulacion.idUsuario_creador = simulacion.idUsuario_creador
        db_simulacion.idComunidadEnergetica = simulacion.idComunidadEnergetica
        
        self.db.commit()
        self.db.refresh(db_simulacion)
        
        return SimulacionEntity(
            idSimulacion=db_simulacion.idSimulacion,
            nombreSimulacion=db_simulacion.nombreSimulacion,
            fechaInicio=db_simulacion.fechaInicio,
            fechaFin=db_simulacion.fechaFin,
            tiempo_medicion=db_simulacion.tiempo_medicion,
            estado=EstadoSimulacion(db_simulacion.estado),
            tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(db_simulacion.tipoEstrategiaExcedentes),
            idUsuario_creador=db_simulacion.idUsuario_creador,
            idComunidadEnergetica=db_simulacion.idComunidadEnergetica
        )

    def update_estado(self, simulacion_id: int, estado: str) -> SimulacionEntity:
        db_simulacion = self.db.query(Simulacion).filter(Simulacion.idSimulacion == simulacion_id).first()
        if not db_simulacion:
            return None
        
        db_simulacion.estado = estado
        self.db.commit()
        self.db.refresh(db_simulacion)
        
        return SimulacionEntity(
            idSimulacion=db_simulacion.idSimulacion,
            nombreSimulacion=db_simulacion.nombreSimulacion,
            fechaInicio=db_simulacion.fechaInicio,
            fechaFin=db_simulacion.fechaFin,
            tiempo_medicion=db_simulacion.tiempo_medicion,
            estado=EstadoSimulacion(db_simulacion.estado),
            tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(db_simulacion.tipoEstrategiaExcedentes),
            idUsuario_creador=db_simulacion.idUsuario_creador,
            idComunidadEnergetica=db_simulacion.idComunidadEnergetica
        )

    def delete(self, simulacion_id: int) -> None:
        db_simulacion = self.db.query(Simulacion).filter(Simulacion.idSimulacion == simulacion_id).first()
        if db_simulacion:
            self.db.delete(db_simulacion)
            self.db.commit()