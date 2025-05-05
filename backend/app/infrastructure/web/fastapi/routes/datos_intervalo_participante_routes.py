from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from datetime import datetime

from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.use_cases.datos_intervalo_participante.datos_intervalo_participante_use_cases import DatosIntervaloParticipanteUseCases
from app.infrastructure.persistance.database import get_db
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_participante_repository import SqlAlchemyDatosIntervaloParticipanteRepository
from app.interfaces.schemas_datos_intervalo_participante import (
    DatosIntervaloParticipanteRead,
    DatosIntervaloParticipanteCreate,
    DatosIntervaloParticipanteBulkCreate,
    DatosIntervaloParticipanteUpdate
)

router = APIRouter(
    prefix="/datos-intervalo-participante",
    tags=["Datos Intervalo Participante"],
    responses={404: {"description": "No encontrado"}},
)

def get_use_cases(db: Session = Depends(get_db)):
    repository = SqlAlchemyDatosIntervaloParticipanteRepository(db)
    return DatosIntervaloParticipanteUseCases(repository)

@router.get("/{datos_intervalo_id}", response_model=DatosIntervaloParticipanteRead)
def get_datos_intervalo(datos_intervalo_id: int, use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)):
    datos = use_cases.get_by_id(datos_intervalo_id)
    if datos is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados"
        )
    return datos

@router.get("/resultado-participante/{resultado_participante_id}", response_model=List[DatosIntervaloParticipanteRead])
def get_datos_by_resultado_participante(
    resultado_participante_id: int, 
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
):
    if start_time and end_time:
        return use_cases.get_by_timestamp_range(resultado_participante_id, start_time, end_time)
    return use_cases.get_by_resultado_participante_id(resultado_participante_id)

@router.get("/", response_model=List[DatosIntervaloParticipanteRead])
def list_datos_intervalo(
    skip: int = 0, 
    limit: int = 100, 
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
):
    datos = use_cases.list(skip=skip, limit=limit)
    return datos

@router.post("/", response_model=DatosIntervaloParticipanteRead, status_code=status.HTTP_201_CREATED)
def create_datos_intervalo(
    datos: DatosIntervaloParticipanteCreate, 
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
):
    # Convertir de schema a entity
    entity = DatosIntervaloParticipanteEntity(
        timestamp=datos.timestamp,
        consumoReal_kWh=datos.consumoReal_kWh,
        produccionPropia_kWh=datos.produccionPropia_kWh,
        energiaRecibidaReparto_kWh=datos.energiaRecibidaReparto_kWh,
        energiaDesdeAlmacenamientoInd_kWh=datos.energiaDesdeAlmacenamientoInd_kWh,
        energiaHaciaAlmacenamientoInd_kWh=datos.energiaHaciaAlmacenamientoInd_kWh,
        energiaDesdeRed_kWh=datos.energiaDesdeRed_kWh,
        excedenteVertidoCompensado_kWh=datos.excedenteVertidoCompensado_kWh,
        estadoAlmacenamientoInd_kWh=datos.estadoAlmacenamientoInd_kWh,
        precioImportacionIntervalo=datos.precioImportacionIntervalo,
        precioExportacionIntervalo=datos.precioExportacionIntervalo,
        idResultadoParticipante=datos.idResultadoParticipante
    )
    
    return use_cases.create(entity)

@router.post("/bulk", response_model=List[DatosIntervaloParticipanteRead], status_code=status.HTTP_201_CREATED)
def create_many_datos_intervalo(
    bulk_datos: DatosIntervaloParticipanteBulkCreate,
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
):
    # Convertir schemas a entities
    entities = [
        DatosIntervaloParticipanteEntity(
            timestamp=datos.timestamp,
            consumoReal_kWh=datos.consumoReal_kWh,
            produccionPropia_kWh=datos.produccionPropia_kWh,
            energiaRecibidaReparto_kWh=datos.energiaRecibidaReparto_kWh,
            energiaDesdeAlmacenamientoInd_kWh=datos.energiaDesdeAlmacenamientoInd_kWh,
            energiaHaciaAlmacenamientoInd_kWh=datos.energiaHaciaAlmacenamientoInd_kWh,
            energiaDesdeRed_kWh=datos.energiaDesdeRed_kWh,
            excedenteVertidoCompensado_kWh=datos.excedenteVertidoCompensado_kWh,
            estadoAlmacenamientoInd_kWh=datos.estadoAlmacenamientoInd_kWh,
            precioImportacionIntervalo=datos.precioImportacionIntervalo,
            precioExportacionIntervalo=datos.precioExportacionIntervalo,
            idResultadoParticipante=datos.idResultadoParticipante
        ) for datos in bulk_datos.datos
    ]
    
    return use_cases.create_many(entities)

@router.put("/{datos_intervalo_id}", response_model=DatosIntervaloParticipanteRead)
def update_datos_intervalo(
    datos_intervalo_id: int,
    datos_update: DatosIntervaloParticipanteUpdate,
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
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
    if datos_update.consumoReal_kWh is not None:
        update_data.consumoReal_kWh = datos_update.consumoReal_kWh
    if datos_update.produccionPropia_kWh is not None:
        update_data.produccionPropia_kWh = datos_update.produccionPropia_kWh
    if datos_update.energiaRecibidaReparto_kWh is not None:
        update_data.energiaRecibidaReparto_kWh = datos_update.energiaRecibidaReparto_kWh
    if datos_update.energiaDesdeAlmacenamientoInd_kWh is not None:
        update_data.energiaDesdeAlmacenamientoInd_kWh = datos_update.energiaDesdeAlmacenamientoInd_kWh
    if datos_update.energiaHaciaAlmacenamientoInd_kWh is not None:
        update_data.energiaHaciaAlmacenamientoInd_kWh = datos_update.energiaHaciaAlmacenamientoInd_kWh
    if datos_update.energiaDesdeRed_kWh is not None:
        update_data.energiaDesdeRed_kWh = datos_update.energiaDesdeRed_kWh
    if datos_update.excedenteVertidoCompensado_kWh is not None:
        update_data.excedenteVertidoCompensado_kWh = datos_update.excedenteVertidoCompensado_kWh
    if datos_update.estadoAlmacenamientoInd_kWh is not None:
        update_data.estadoAlmacenamientoInd_kWh = datos_update.estadoAlmacenamientoInd_kWh
    if datos_update.precioImportacionIntervalo is not None:
        update_data.precioImportacionIntervalo = datos_update.precioImportacionIntervalo
    if datos_update.precioExportacionIntervalo is not None:
        update_data.precioExportacionIntervalo = datos_update.precioExportacionIntervalo
    
    return use_cases.update(datos_intervalo_id, update_data)

@router.delete("/{datos_intervalo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_datos_intervalo(
    datos_intervalo_id: int,
    use_cases: DatosIntervaloParticipanteUseCases = Depends(get_use_cases)
):
    datos_existente = use_cases.get_by_id(datos_intervalo_id)
    if datos_existente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Datos de intervalo con ID {datos_intervalo_id} no encontrados"
        )
    
    use_cases.delete(datos_intervalo_id)
    return None