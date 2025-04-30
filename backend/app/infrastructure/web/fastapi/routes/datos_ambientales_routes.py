# backend/app/infrastructure/web/fastapi/routes/datos_ambientales_routes.py

from fastapi import APIRouter, Depends, status, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_datos_ambientales import DatosAmbientalesCreate, DatosAmbientalesRead
from app.domain.entities.datos_ambientales import DatosAmbientalesEntity
# Importa los casos de uso necesarios
from app.domain.use_cases.datos_ambientales.crear_datos_ambientales import crear_datos_ambientales_use_case

router = APIRouter(
    prefix="/datos-ambientales",
    tags=["datos-ambientales"],
    responses={404: {"description": "Dato ambiental no encontrado"}}
)

@router.post("", response_model=DatosAmbientalesRead, status_code=status.HTTP_201_CREATED)
def crear_dato_ambiental(dato: DatosAmbientalesCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo registro de datos ambientales para una simulación.
    """
    dato_entity = DatosAmbientalesEntity(
        timestamp=dato.timestamp,
        fuenteDatos=dato.fuenteDatos,
        radiacionGlobalHoriz_Wh_m2=dato.radiacionGlobalHoriz_Wh_m2,
        temperaturaAmbiente_C=dato.temperaturaAmbiente_C,
        velocidadViento_m_s=dato.velocidadViento_m_s,
        idSimulacion=dato.idSimulacion
    )
    return crear_datos_ambientales_use_case(dato_entity, db)
