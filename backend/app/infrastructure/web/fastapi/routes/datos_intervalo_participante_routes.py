from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from app.infrastructure.persistance.database import get_db
from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_participante_repository import SqlAlchemyDatosIntervaloParticipanteRepository
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.use_cases.datos_intervalo_participante.create_bulk_datos_intervalo_participante import create_bulk_datos_intervalo_participante_use_case
from app.domain.use_cases.datos_intervalo_participante.get_datos_intervalo_participante_by_id import get_datos_intervalo_participante_by_id_use_case
from app.domain.use_cases.datos_intervalo_participante.get_datos_intervalo_participante_by_resultado_id import get_datos_intervalo_participante_by_resultado_id_use_case
from app.domain.use_cases.datos_intervalo_participante.get_datos_intervalo_participante_by_timestamp_range import get_datos_intervalo_participante_by_timestamp_range_use_case
from app.interfaces.schemas_datos_intervalo_participante import (
    DatosIntervaloParticipanteRead,
    DatosIntervaloParticipanteCreate,
    DatosIntervaloParticipanteBulkCreate
)

router = APIRouter(
    prefix="/datos-intervalo-participante",
    tags=["Datos Intervalo Participante"],
    responses={404: {"description": "No encontrado"}},
)

@router.get("/{datos_intervalo_id}", response_model=DatosIntervaloParticipanteRead)
def get_datos_intervalo(datos_intervalo_id: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyDatosIntervaloParticipanteRepository(db)
    return get_datos_intervalo_participante_by_id_use_case(datos_intervalo_id, repo)

@router.get("/resultado-participante/{resultado_participante_id}", response_model=List[DatosIntervaloParticipanteRead])
def get_datos_by_resultado_participante(
    resultado_participante_id: int, 
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloParticipanteRepository(db)
    if start_time and end_time:
        return get_datos_intervalo_participante_by_timestamp_range_use_case(resultado_participante_id, start_time, end_time, repo)
    return get_datos_intervalo_participante_by_resultado_id_use_case(resultado_participante_id, repo)

@router.post("/bulk", response_model=List[DatosIntervaloParticipanteRead], status_code=status.HTTP_201_CREATED)
def create_many_datos_intervalo(
    bulk_datos: DatosIntervaloParticipanteBulkCreate,
    db: Session = Depends(get_db)
):
    repo = SqlAlchemyDatosIntervaloParticipanteRepository(db)
    entities = [
        DatosIntervaloParticipanteEntity(
            timestamp=datos.timestamp,
            consumoReal_kWh=datos.consumoReal_kWh,
            autoconsumo_kWh=datos.autoconsumo_kWh,
            energiaRecibidaReparto_kWh=datos.energiaRecibidaReparto_kWh,
            energiaAlmacenamiento_kWh=datos.energiaAlmacenamiento_kWh,
            energiaDiferencia_kWh=datos.energiaDiferencia_kWh,
            excedenteVertidoCompensado_kWh=datos.excedenteVertidoCompensado_kWh,
            precioImportacionIntervalo=datos.precioImportacionIntervalo,
            precioExportacionIntervalo=datos.precioExportacionIntervalo,
            idResultadoParticipante=datos.idResultadoParticipante
        ) for datos in bulk_datos.datos
    ]
    return create_bulk_datos_intervalo_participante_use_case(entities, repo)