from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from datetime import datetime

from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.use_cases.datos_intervalo_activo.get_datos_intervalo_activo_by_id import get_datos_intervalo_activo_by_id_use_case
from app.domain.use_cases.datos_intervalo_activo.get_datos_intervalo_activo_by_resultado_ids import (
    get_datos_intervalo_activo_by_resultado_activo_gen_id_use_case,
    get_datos_intervalo_activo_by_resultado_activo_alm_id_use_case
)
from app.domain.use_cases.datos_intervalo_activo.get_datos_intervalo_activo_by_timestamp_range import get_datos_intervalo_activo_by_timestamp_range_use_case
from app.domain.use_cases.datos_intervalo_activo.create_bulk_datos_intervalo_activo import create_bulk_datos_intervalo_activo_use_case
from app.domain.repositories.datos_intervalo_activo_repository import DatosIntervaloActivoRepository
from app.infrastructure.persistance.database import get_db
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_activo_repository import SqlAlchemyDatosIntervaloActivoRepository
from app.interfaces.schemas_datos_intervalo_activo import (
    DatosIntervaloActivoRead,
    DatosIntervaloActivoBulkCreate
)

router = APIRouter(
    prefix="/datos-intervalo-activo",
    tags=["Datos Intervalo Activo"],
    responses={404: {"description": "No encontrado"}},
)


@router.get("/{datos_intervalo_id}", response_model=DatosIntervaloActivoRead)
def get_datos_intervalo(datos_intervalo_id: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyDatosIntervaloActivoRepository(db)
    datos = get_datos_intervalo_activo_by_id_use_case(datos_intervalo_id, repo)
    if datos is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados"
        )
    return datos

@router.get("/activo-generacion/{resultado_activo_gen_id}", response_model=List[DatosIntervaloActivoRead])
def get_datos_by_activo_generacion(
    resultado_activo_gen_id: int, 
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloActivoRepository(db)
    if start_time and end_time:
        return get_datos_intervalo_activo_by_timestamp_range_use_case(resultado_activo_gen_id, True, start_time, end_time, repo)
    return get_datos_intervalo_activo_by_resultado_activo_gen_id_use_case(resultado_activo_gen_id, repo)

@router.get("/activo-almacenamiento/{resultado_activo_alm_id}", response_model=List[DatosIntervaloActivoRead])
def get_datos_by_activo_almacenamiento(
    resultado_activo_alm_id: int, 
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloActivoRepository(db)
    if start_time and end_time:
        return get_datos_intervalo_activo_by_timestamp_range_use_case(resultado_activo_alm_id, False, start_time, end_time, repo)
    return get_datos_intervalo_activo_by_resultado_activo_alm_id_use_case(resultado_activo_alm_id, repo)

@router.get("/", response_model=List[DatosIntervaloActivoRead])
def list_datos_intervalo(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloActivoRepository(db)
    datos = repo.list(skip=skip, limit=limit)
    return datos

@router.post("/bulk", response_model=List[DatosIntervaloActivoRead], status_code=status.HTTP_201_CREATED)
def create_many_datos_intervalo(
    bulk_datos: DatosIntervaloActivoBulkCreate,
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloActivoRepository(db)
    # Verificar que cada elemento tiene al menos uno de los IDs de resultado activo
    for i, datos in enumerate(bulk_datos.datos):
        if datos.idResultadoActivoGen is None and datos.idResultadoActivoAlm is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"El elemento {i} debe tener al menos uno de idResultadoActivoGen o idResultadoActivoAlm presente"
            )
    
    # Convertir schemas a entities
    entities = [
        DatosIntervaloActivoEntity(
            timestamp=datos.timestamp,
            energiaGenerada_kWh=datos.energiaGenerada_kWh,
            energiaCargada_kWh=datos.energiaCargada_kWh,
            energiaDescargada_kWh=datos.energiaDescargada_kWh,
            SoC_kWh=datos.SoC_kWh,
            idResultadoActivoGen=datos.idResultadoActivoGen,
            idResultadoActivoAlm=datos.idResultadoActivoAlm
        ) for datos in bulk_datos.datos
    ]
    
    return create_bulk_datos_intervalo_activo_use_case(entities, repo)