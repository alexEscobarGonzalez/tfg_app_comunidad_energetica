from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_contrato_autoconsumo import ContratoAutoconsumoCreate, ContratoAutoconsumoRead, ContratoAutoconsumoUpdate
from app.domain.entities.contrato_autoconsumo import ContratoAutoconsumoEntity
from app.domain.use_cases.contrato_autoconsumo.crear_contrato_autoconsumo import crear_contrato_autoconsumo_use_case
from app.domain.use_cases.contrato_autoconsumo.mostrar_contrato_autoconsumo import mostrar_contrato_autoconsumo_use_case
from app.domain.use_cases.contrato_autoconsumo.modificar_contrato_autoconsumo import modificar_contrato_autoconsumo_use_case
from app.domain.use_cases.contrato_autoconsumo.eliminar_contrato_autoconsumo import eliminar_contrato_autoconsumo_use_case
from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
from typing import List

router = APIRouter(prefix="/contratos", tags=["contratos"])
router_alias = APIRouter(prefix="/contratos-autoconsumo", tags=["contratos"])

@router.post("/", response_model=ContratoAutoconsumoRead)
@router_alias.post("/", response_model=ContratoAutoconsumoRead)
def crear_contrato(contrato: ContratoAutoconsumoCreate, db: Session = Depends(get_db)):
    contrato_entity = ContratoAutoconsumoEntity(
        tipoContrato=contrato.tipoContrato,
        precioEnergiaImportacion_eur_kWh=contrato.precioEnergiaImportacion_eur_kWh,
        precioCompensacionExcedentes_eur_kWh=contrato.precioCompensacionExcedentes_eur_kWh,
        potenciaContratada_kW=contrato.potenciaContratada_kW,
        precioPotenciaContratado_eur_kWh=contrato.precioPotenciaContratado_eur_kWh,
        idParticipante=contrato.idParticipante
    )
    participante_repo = SqlAlchemyParticipanteRepository(db)
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    nuevo_contrato = crear_contrato_autoconsumo_use_case(contrato_entity, participante_repo, contrato_repo)
    return ContratoAutoconsumoRead.from_orm(nuevo_contrato)

@router.get("/{id_contrato}", response_model=ContratoAutoconsumoRead)
def obtener_contrato(id_contrato: int, db: Session = Depends(get_db)):
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contrato = mostrar_contrato_autoconsumo_use_case(id_contrato, contrato_repo)
    return ContratoAutoconsumoRead.from_orm(contrato)

@router.get("/participante/{id_participante}", response_model=ContratoAutoconsumoRead)
def obtener_contrato_por_participante(id_participante: int, db: Session = Depends(get_db)):
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contrato = contrato_repo.get_by_participante(id_participante)
    if not contrato:
        raise HTTPException(status_code=404, detail="No se encontró ningún contrato para este participante")
    return ContratoAutoconsumoRead.from_orm(contrato)

@router.get("/", response_model=List[ContratoAutoconsumoRead])
def listar_contratos(db: Session = Depends(get_db)):
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contratos = contrato_repo.list()
    return [ContratoAutoconsumoRead.from_orm(c) for c in contratos]

@router.put("/{id_contrato}", response_model=ContratoAutoconsumoRead)
def actualizar_contrato(id_contrato: int, contrato: ContratoAutoconsumoUpdate, db: Session = Depends(get_db)):
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    contrato_existente = contrato_repo.get_by_id(id_contrato)
    if not contrato_existente:
        raise HTTPException(status_code=404, detail="Contrato no encontrado")
    contrato_entity = ContratoAutoconsumoEntity(
        idContrato=id_contrato,
        tipoContrato=contrato.tipoContrato or contrato_existente.tipoContrato,
        precioEnergiaImportacion_eur_kWh=contrato.precioEnergiaImportacion_eur_kWh if contrato.precioEnergiaImportacion_eur_kWh is not None else contrato_existente.precioEnergiaImportacion_eur_kWh,
        precioCompensacionExcedentes_eur_kWh=contrato.precioCompensacionExcedentes_eur_kWh if contrato.precioCompensacionExcedentes_eur_kWh is not None else contrato_existente.precioCompensacionExcedentes_eur_kWh,
        potenciaContratada_kW=contrato.potenciaContratada_kW if contrato.potenciaContratada_kW is not None else contrato_existente.potenciaContratada_kW,
        precioPotenciaContratado_eur_kWh=contrato.precioPotenciaContratado_eur_kWh if contrato.precioPotenciaContratado_eur_kWh is not None else contrato_existente.precioPotenciaContratado_eur_kWh,
        idParticipante=contrato_existente.idParticipante
    )
    contrato_actualizado = modificar_contrato_autoconsumo_use_case(id_contrato, contrato_entity, contrato_repo)
    return ContratoAutoconsumoRead.from_orm(contrato_actualizado)

@router.delete("/{id_contrato}")
def eliminar_contrato(id_contrato: int, db: Session = Depends(get_db)):
    contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db)
    eliminar_contrato_autoconsumo_use_case(id_contrato, contrato_repo)
    return {"mensaje": "Contrato eliminado correctamente"}