from app.infrastructure.persistance.models.comunidad_energetica_tabla import ComunidadEnergetica as ComunidadEnergeticaModel
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes
from sqlalchemy.orm import Session
from typing import List, Optional

class SqlAlchemyComunidadEnergeticaRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, idComunidadEnergetica: int) -> Optional[ComunidadEnergeticaEntity]:
        model = self.db.query(ComunidadEnergeticaModel).filter_by(idComunidadEnergetica=idComunidadEnergetica).first()
        if model:
            return ComunidadEnergeticaEntity(
                idComunidadEnergetica=model.idComunidadEnergetica,
                nombre=model.nombre,
                latitud=model.latitud,
                longitud=model.longitud,
                tipoEstrategiaExcedentes=model.tipoEstrategiaExcedentes,
                idUsuario=model.idUsuario
            )
        return None

    def list(self) -> List[ComunidadEnergeticaEntity]:
        return [
            ComunidadEnergeticaEntity(
                idComunidadEnergetica=m.idComunidadEnergetica,
                nombre=m.nombre,
                latitud=m.latitud,
                longitud=m.longitud,
                tipoEstrategiaExcedentes=m.tipoEstrategiaExcedentes,
                idUsuario=m.idUsuario
            ) for m in self.db.query(ComunidadEnergeticaModel).all()
        ]

    def create(self, comunidad: ComunidadEnergeticaEntity) -> ComunidadEnergeticaEntity:
        model = ComunidadEnergeticaModel(
            nombre=comunidad.nombre,
            latitud=comunidad.latitud,
            longitud=comunidad.longitud,
            tipoEstrategiaExcedentes=comunidad.tipoEstrategiaExcedentes,
            idUsuario=comunidad.idUsuario
        )
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        comunidad.idComunidadEnergetica = model.idComunidadEnergetica
        comunidad.idUsuario = model.idUsuario
        return comunidad

    def update(self, comunidad: ComunidadEnergeticaEntity) -> ComunidadEnergeticaEntity:
        model = self.db.query(ComunidadEnergeticaModel).filter_by(idComunidadEnergetica=comunidad.idComunidadEnergetica).first()
        if model:
            model.nombre = comunidad.nombre
            model.latitud = comunidad.latitud
            model.longitud = comunidad.longitud
            model.tipoEstrategiaExcedentes = comunidad.tipoEstrategiaExcedentes
            self.db.commit()
            self.db.refresh(model)
        return comunidad

    def delete(self, idComunidadEnergetica: int) -> None:
        model = self.db.query(ComunidadEnergeticaModel).filter_by(idComunidadEnergetica=idComunidadEnergetica).first()
        if model:
            self.db.delete(model)
            self.db.commit()
