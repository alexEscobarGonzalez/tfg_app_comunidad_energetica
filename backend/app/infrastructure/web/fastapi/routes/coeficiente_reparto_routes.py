from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_coeficiente_reparto import (
    CoeficienteRepartoCreate, 
    CoeficienteRepartoCreateByParticipante,
    CoeficienteRepartoUpdate, 
    CoeficienteRepartoRead
)
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.domain.use_cases.coeficiente_reparto.crear_coeficiente_reparto import crear_coeficiente_reparto_use_case
from app.domain.use_cases.coeficiente_reparto.crear_o_actualizar_coeficiente_reparto import crear_o_actualizar_coeficiente_reparto_use_case
from app.domain.use_cases.coeficiente_reparto.obtener_coeficiente_por_participante import obtener_coeficiente_por_participante_use_case
from app.domain.use_cases.coeficiente_reparto.mostrar_coeficiente_reparto import mostrar_coeficiente_reparto_use_case
from app.domain.use_cases.coeficiente_reparto.modificar_coeficiente_reparto import modificar_coeficiente_reparto_use_case
from app.domain.use_cases.coeficiente_reparto.eliminar_coeficiente_reparto import eliminar_coeficiente_reparto_use_case
from app.domain.use_cases.coeficiente_reparto.listar_coeficientes_reparto import (
    listar_coeficientes_reparto_by_participante_use_case,
    listar_todos_coeficientes_reparto_use_case
)
from app.domain.entities.tipo_reparto import TipoReparto
from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

router = APIRouter(
    prefix="/coeficientes-reparto",
    tags=["coeficientes-reparto"],
    responses={404: {"description": "Coeficiente de reparto no encontrado"}}
)

@router.put("/participante/{id_participante}", response_model=CoeficienteRepartoRead, status_code=status.HTTP_200_OK)
def crear_o_actualizar_coeficiente_por_participante(
    id_participante: int, 
    coeficiente_data: CoeficienteRepartoCreateByParticipante, 
    db: Session = Depends(get_db)
):
    # Manejar tipo de reparto simplificado
    tipo_reparto = coeficiente_data.tipoReparto
    
    # Si es un string y no coincide con los valores del enum, intentar matchear
    if isinstance(tipo_reparto, str):
        tipo_reparto_upper = tipo_reparto.upper()
        if tipo_reparto_upper == "FIJO":
            tipo_reparto = TipoReparto.REPARTO_FIJO
        elif tipo_reparto_upper == "PROGRAMADO":
            tipo_reparto = TipoReparto.REPARTO_PROGRAMADO
    
    # Extraer el valor del enum como string para enviarlo a la entidad
    tipo_reparto_value = tipo_reparto.value if hasattr(tipo_reparto, 'value') else tipo_reparto
    
    coeficiente_entity = CoeficienteRepartoEntity(
        tipoReparto=tipo_reparto_value,
        parametros=coeficiente_data.parametros,
        idParticipante=id_participante  # Usar el ID del parámetro de la URL
    )
    participante_repo = SqlAlchemyParticipanteRepository(db)
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return crear_o_actualizar_coeficiente_reparto_use_case(coeficiente_entity, participante_repo, coeficiente_repo)

@router.get("/participante/{id_participante}/single", response_model=Optional[CoeficienteRepartoRead])
def obtener_coeficiente_por_participante(id_participante: int, db: Session = Depends(get_db)):
    participante_repo = SqlAlchemyParticipanteRepository(db)
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return obtener_coeficiente_por_participante_use_case(id_participante, participante_repo, coeficiente_repo)

@router.post("", response_model=CoeficienteRepartoRead, status_code=status.HTTP_201_CREATED)
def crear_coeficiente_reparto(coeficiente_data: CoeficienteRepartoCreate, db: Session = Depends(get_db)):
    # Manejar tipo de reparto simplificado
    tipo_reparto = coeficiente_data.tipoReparto
    
    # Si es un string y no coincide con los valores del enum, intentar matchear
    if isinstance(tipo_reparto, str):
        tipo_reparto_upper = tipo_reparto.upper()
        if tipo_reparto_upper == "FIJO":
            tipo_reparto = TipoReparto.REPARTO_FIJO
        elif tipo_reparto_upper == "PROGRAMADO":
            tipo_reparto = TipoReparto.REPARTO_PROGRAMADO
    
    # Extraer el valor del enum como string para enviarlo a la entidad
    tipo_reparto_value = tipo_reparto.value if hasattr(tipo_reparto, 'value') else tipo_reparto
    
    coeficiente_entity = CoeficienteRepartoEntity(
        tipoReparto=tipo_reparto_value,
        parametros=coeficiente_data.parametros,
        idParticipante=coeficiente_data.idParticipante
    )
    participante_repo = SqlAlchemyParticipanteRepository(db)
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return crear_coeficiente_reparto_use_case(coeficiente_entity, participante_repo, coeficiente_repo)

@router.get("", response_model=List[CoeficienteRepartoRead])
def listar_coeficientes_reparto(db: Session = Depends(get_db)):
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return listar_todos_coeficientes_reparto_use_case(coeficiente_repo)

@router.get("/participante/{id_participante}", response_model=List[CoeficienteRepartoRead])
def listar_coeficientes_reparto_por_participante(id_participante: int, db: Session = Depends(get_db)):
    participante_repo = SqlAlchemyParticipanteRepository(db)
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return listar_coeficientes_reparto_by_participante_use_case(id_participante, participante_repo, coeficiente_repo)

@router.get("/{id_coeficiente}", response_model=CoeficienteRepartoRead)
def mostrar_coeficiente_reparto(id_coeficiente: int, db: Session = Depends(get_db)):
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return mostrar_coeficiente_reparto_use_case(id_coeficiente, coeficiente_repo)

@router.put("/{id_coeficiente}", response_model=CoeficienteRepartoRead)
def modificar_coeficiente_reparto(
    id_coeficiente: int, 
    coeficiente_data: CoeficienteRepartoUpdate, 
    db: Session = Depends(get_db)
):
    # Extraer el valor del enum como string para enviarlo a la entidad
    coeficiente_entity = CoeficienteRepartoEntity(
        tipoReparto=coeficiente_data.tipoReparto.value if hasattr(coeficiente_data.tipoReparto, 'value') else coeficiente_data.tipoReparto,
        parametros=coeficiente_data.parametros
    )
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return modificar_coeficiente_reparto_use_case(id_coeficiente, coeficiente_entity, coeficiente_repo)

@router.delete("/{id_coeficiente}", response_model=Dict[str, Any])
def eliminar_coeficiente_reparto(id_coeficiente: int, db: Session = Depends(get_db)):
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return eliminar_coeficiente_reparto_use_case(id_coeficiente, coeficiente_repo)