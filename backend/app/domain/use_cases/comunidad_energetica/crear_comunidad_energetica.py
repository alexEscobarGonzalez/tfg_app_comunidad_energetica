from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository


def crear_comunidad_energetica_use_case(comunidad: ComunidadEnergeticaEntity, db: Session) -> ComunidadEnergeticaEntity:
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    return repo.create(comunidad)
