from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from datetime import datetime

from app.domain.entities.datos_intervalo_activo import DatosIntervaloActivoEntity
from app.domain.use_cases.datos_intervalo_activo_use_cases import DatosIntervaloActivoUseCases
from app.infrastructure.persistance.database import get_db
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_activo_repository import SqlAlchemyDatosIntervaloActivoRepository
from app.interfaces.schemas_datos_intervalo_activo import (
    DatosIntervaloActivoRead,
    DatosIntervaloActivoCreate,
    DatosIntervaloActivoBulkCreate,
    DatosIntervaloActivoUpdate
)

router = APIRouter(
    prefix="/datos-intervalo-activo",
    tags=["Datos Intervalo Activo"],
    responses={404: {"description": "No encontrado"}},
)

def get_use_cases(db: Session = Depends(get_db)):
    repository = SqlAlchemyDatosIntervaloActivoRepository(db)
    return DatosIntervaloActivoUseCases(repository)

@router.get("/{datos_intervalo_id}", response_model=DatosIntervaloActivoRead)
def get_datos_intervalo(datos_intervalo_id: int, use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)):
    datos = use_cases.get_by_id(datos_intervalo_id)
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
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    if start_time and end_time:
        return use_cases.get_by_timestamp_range(resultado_activo_gen_id, True, start_time, end_time)
    return use_cases.get_by_resultado_activo_gen_id(resultado_activo_gen_id)

@router.get("/activo-almacenamiento/{resultado_activo_alm_id}", response_model=List[DatosIntervaloActivoRead])
def get_datos_by_activo_almacenamiento(
    resultado_activo_alm_id: int, 
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    if start_time and end_time:
        return use_cases.get_by_timestamp_range(resultado_activo_alm_id, False, start_time, end_time)
    return use_cases.get_by_resultado_activo_alm_id(resultado_activo_alm_id)

@router.get("/", response_model=List[DatosIntervaloActivoRead])
def list_datos_intervalo(
    skip: int = 0, 
    limit: int = 100, 
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    datos = use_cases.list(skip=skip, limit=limit)
    return datos

@router.post("/", response_model=DatosIntervaloActivoRead, status_code=status.HTTP_201_CREATED)
def create_datos_intervalo(
    datos: DatosIntervaloActivoCreate, 
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    # Verificar que al menos uno de los IDs de resultado activo está presente
    if datos.idResultadoActivoGen is None and datos.idResultadoActivoAlm is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Al menos uno de idResultadoActivoGen o idResultadoActivoAlm debe estar presente"
        )
    
    # Convertir de schema a entity
    entity = DatosIntervaloActivoEntity(
        timestamp=datos.timestamp,
        energiaGenerada_kWh=datos.energiaGenerada_kWh,
        energiaCargada_kWh=datos.energiaCargada_kWh,
        energiaDescargada_kWh=datos.energiaDescargada_kWh,
        SoC_kWh=datos.SoC_kWh,
        idResultadoActivoGen=datos.idResultadoActivoGen,
        idResultadoActivoAlm=datos.idResultadoActivoAlm
    )
    
    return use_cases.create(entity)

@router.post("/bulk", response_model=List[DatosIntervaloActivoRead], status_code=status.HTTP_201_CREATED)
def create_many_datos_intervalo(
    bulk_datos: DatosIntervaloActivoBulkCreate,
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
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
    
    return use_cases.create_many(entities)

@router.put("/{datos_intervalo_id}", response_model=DatosIntervaloActivoRead)
def update_datos_intervalo(
    datos_intervalo_id: int,
    datos_update: DatosIntervaloActivoUpdate,
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    # Primero verificamos que existe
    datos_existente = use_cases.get_by_id(datos_intervalo_id)
    if datos_existente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados"
        )
    
    # Actualizar solo los campos proporcionados
    update_data = datos_existente
    
    if datos_update.timestamp is not None:
        update_data.timestamp = datos_update.timestamp
    if datos_update.energiaGenerada_kWh is not None:
        update_data.energiaGenerada_kWh = datos_update.energiaGenerada_kWh
    if datos_update.energiaCargada_kWh is not None:
        update_data.energiaCargada_kWh = datos_update.energiaCargada_kWh
    if datos_update.energiaDescargada_kWh is not None:
        update_data.energiaDescargada_kWh = datos_update.energiaDescargada_kWh
    if datos_update.SoC_kWh is not None:
        update_data.SoC_kWh = datos_update.SoC_kWh
    if datos_update.idResultadoActivoGen is not None:
        update_data.idResultadoActivoGen = datos_update.idResultadoActivoGen
    if datos_update.idResultadoActivoAlm is not None:
        update_data.idResultadoActivoAlm = datos_update.idResultadoActivoAlm
    
    # Verificar que al menos uno de los IDs de resultado activo está presente
    if update_data.idResultadoActivoGen is None and update_data.idResultadoActivoAlm is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Al menos uno de idResultadoActivoGen o idResultadoActivoAlm debe estar presente"
        )
    
    return use_cases.update(datos_intervalo_id, update_data)

@router.delete("/{datos_intervalo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_datos_intervalo(
    datos_intervalo_id: int,
    use_cases: DatosIntervaloActivoUseCases = Depends(get_use_cases)
):
    datos_existente = use_cases.get_by_id(datos_intervalo_id)
    if datos_existente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados"
        )
    
    use_cases.delete(datos_intervalo_id)
    return None