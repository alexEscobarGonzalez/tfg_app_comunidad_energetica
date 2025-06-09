from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository

def mostrar_activo_generacion_use_case(id_activo: int, db: Session) -> ActivoGeneracionEntity:
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activo = repo.get_by_id(id_activo)
    if not activo:
        raise HTTPException(status_code=404, detail="Activo de generación no encontrado")
    return activo