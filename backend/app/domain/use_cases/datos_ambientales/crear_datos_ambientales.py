from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.infrastructure.persistance.repository.sqlalchemy_datos_ambientales_repository import SqlAlchemyDatosAmbientalesRepository
from app.infrastructure.persistance.repository.sqlalchemy_simulacion_repository import SqlAlchemySimulacionRepository # Asegúrate de tener este repo

def crear_datos_ambientales_use_case(datos: DatosAmbientalesEntity, db: Session) -> DatosAmbientalesEntity:
    # Verificar que la simulación existe
    simulacion_repo = SqlAlchemySimulacionRepository(db)
    if not simulacion_repo.get_by_id(datos.idSimulacion):
         raise HTTPException(status_code=404, detail=f"Simulación con ID {datos.idSimulacion} no encontrada")

    repo = SqlAlchemyDatosAmbientalesRepository(db)
    return repo.create(datos)