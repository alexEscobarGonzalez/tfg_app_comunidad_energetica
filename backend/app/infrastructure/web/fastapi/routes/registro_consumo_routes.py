from fastapi import APIRouter, Depends, status, Query, File, UploadFile, Form, Body
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime
import json
from pydantic import BaseModel

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_registro_consumo import (
    RegistroConsumoCreate, 
    RegistroConsumoUpdate, 
    RegistroConsumoRead
)
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.use_cases.registro_consumo.crear_registro_consumo import crear_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.mostrar_registro_consumo import mostrar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.modificar_registro_consumo import modificar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.eliminar_registro_consumo import eliminar_registro_consumo_use_case
from app.domain.use_cases.registro_consumo.importar_registros_consumo import importar_registros_consumo_use_case
from app.domain.use_cases.registro_consumo.listar_registros_consumo import (
    listar_registros_consumo_by_participante_use_case,
    listar_registros_consumo_by_periodo_use_case,
    listar_registros_consumo_by_participante_y_periodo_use_case,
    listar_todos_registros_consumo_use_case
)

router = APIRouter(
    prefix="/registros-consumo",
    tags=["registros-consumo"],
    responses={404: {"description": "Registro de consumo no encontrado"}}
)

@router.post("", response_model=RegistroConsumoRead, status_code=status.HTTP_201_CREATED)
def crear_registro_consumo(registro_data: RegistroConsumoCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo registro de consumo energético asociado a un participante
    """
    registro_entity = RegistroConsumoEntity(
        timestamp=registro_data.timestamp,
        consumoEnergia=registro_data.consumoEnergia,
        idParticipante=registro_data.idParticipante
    )
    return crear_registro_consumo_use_case(registro_entity, db)


@router.post("/importar/{id_participante}", response_model=Dict[str, Any])
def importar_registros_consumo(
    id_participante: int,
    datos: List[Dict[str, Any]] = Body(...),
    db: Session = Depends(get_db)
):
    """
    Importa múltiples registros de consumo para un participante desde un JSON
    
    El formato esperado del JSON es:
    [
        {"timestamp": "2025-04-23T10:00:00", "consumoEnergia": 2.5},
        {"timestamp": "2025-04-23T11:00:00", "consumoEnergia": 3.2},
        ...
    ]
    """
    # Convertir la lista de diccionarios a un string JSON
    datos_json = json.dumps(datos)
    return importar_registros_consumo_use_case(datos_json, id_participante, db)


@router.get("", response_model=List[RegistroConsumoRead])
def listar_registros_consumo(
    fecha_inicio: datetime = None, 
    fecha_fin: datetime = None, 
    db: Session = Depends(get_db)
):
    """
    Obtiene todos los registros de consumo del sistema.
    Opcionalmente se pueden filtrar por rango de fechas.
    """
    if fecha_inicio and fecha_fin:
        return listar_registros_consumo_by_periodo_use_case(fecha_inicio, fecha_fin, db)
    return listar_todos_registros_consumo_use_case(db)

@router.get("/participante/{id_participante}", response_model=List[RegistroConsumoRead])
def listar_registros_consumo_por_participante(
    id_participante: int, 
    fecha_inicio: datetime = None, 
    fecha_fin: datetime = None, 
    db: Session = Depends(get_db)
):
    """
    Obtiene todos los registros de consumo asociados a un participante específico.
    Opcionalmente se pueden filtrar por rango de fechas.
    """
    if fecha_inicio and fecha_fin:
        return listar_registros_consumo_by_participante_y_periodo_use_case(id_participante, fecha_inicio, fecha_fin, db)
    return listar_registros_consumo_by_participante_use_case(id_participante, db)

@router.get("/{id_registro}", response_model=RegistroConsumoRead)
def mostrar_registro_consumo(id_registro: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de un registro de consumo específico por su ID
    """
    return mostrar_registro_consumo_use_case(id_registro, db)

@router.put("/{id_registro}", response_model=RegistroConsumoRead)
def modificar_registro_consumo(
    id_registro: int, 
    registro_data: RegistroConsumoUpdate, 
    db: Session = Depends(get_db)
):
    """
    Modifica los datos de un registro de consumo existente
    """
    registro_entity = RegistroConsumoEntity(
        timestamp=registro_data.timestamp,
        consumoEnergia=registro_data.consumoEnergia
    )
    return modificar_registro_consumo_use_case(id_registro, registro_entity, db)

@router.delete("/{id_registro}", response_model=Dict[str, Any])
def eliminar_registro_consumo(id_registro: int, db: Session = Depends(get_db)):
    """
    Elimina un registro de consumo existente
    """
    return eliminar_registro_consumo_use_case(id_registro, db)