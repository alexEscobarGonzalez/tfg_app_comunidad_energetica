# backend/app/infrastructure/web/fastapi/routes/datos_ambientales_routes.py

from fastapi import APIRouter, Depends, status, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_datos_ambientales import DatosAmbientalesCreate, DatosAmbientalesRead
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
from app.domain.use_cases.datos_ambientales.crear_datos_ambientales import crear_datos_ambientales_use_case
from app.infrastructure.persistance.repository.sqlalchemy_datos_ambientales_repository import SqlAlchemyDatosAmbientalesRepository
from app.infrastructure.persistance.repository.sqlalchemy_simulacion_repository import SqlAlchemySimulacionRepository

router = APIRouter(
    prefix="/datos-ambientales",
    tags=["datos-ambientales"],
    responses={404: {"description": "Dato ambiental no encontrado"}}
)

@router.post("", response_model=DatosAmbientalesRead, status_code=status.HTTP_201_CREATED)
def crear_dato_ambiental(dato: DatosAmbientalesCreate, db: Session = Depends(get_db)):
    dato_entity = DatosAmbientalesEntity(
        timestamp=dato.timestamp,
        fuenteDatos=dato.fuenteDatos,
        radiacionGlobalHoriz_Wh_m2=dato.radiacionGlobalHoriz_Wh_m2,
        temperaturaAmbiente_C=dato.temperaturaAmbiente_C,
        velocidadViento_m_s=dato.velocidadViento_m_s,
        idSimulacion=dato.idSimulacion
    )
    simulacion_repo = SqlAlchemySimulacionRepository(db)
    datos_repo = SqlAlchemyDatosAmbientalesRepository(db)
    return crear_datos_ambientales_use_case(dato_entity, simulacion_repo, datos_repo)
