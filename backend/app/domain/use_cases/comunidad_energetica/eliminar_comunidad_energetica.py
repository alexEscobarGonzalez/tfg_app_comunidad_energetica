from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

def eliminar_comunidad_energetica_use_case(id_comunidad: int, db: Session) -> None:
    repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = repo.get_by_id(id_comunidad)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad no encontrada")
    repo.delete(id_comunidad)
