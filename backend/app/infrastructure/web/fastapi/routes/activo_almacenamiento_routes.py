from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_activo_almacenamiento import (
    ActivoAlmacenamientoCreate, 
    ActivoAlmacenamientoRead, 
    ActivoAlmacenamientoUpdate
)
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.use_cases.activo_almacenamiento.crear_activo_almacenamiento import crear_activo_almacenamiento_use_case
from app.domain.use_cases.activo_almacenamiento.mostrar_activo_almacenamiento import mostrar_activo_almacenamiento_use_case
from app.domain.use_cases.activo_almacenamiento.modificar_activo_almacenamiento import modificar_activo_almacenamiento_use_case
from app.domain.use_cases.activo_almacenamiento.eliminar_activo_almacenamiento import eliminar_activo_almacenamiento_use_case
from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
from typing import List

router = APIRouter(prefix="/activos-almacenamiento", tags=["activos-almacenamiento"])

@router.post("", response_model=ActivoAlmacenamientoRead)
def crear_activo_almacenamiento(activo: ActivoAlmacenamientoCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo activo de almacenamiento en una comunidad energética
    """
    activo_entity = ActivoAlmacenamientoEntity(
        capacidadNominal_kWh=activo.capacidadNominal_kWh,
        potenciaMaximaCarga_kW=activo.potenciaMaximaCarga_kW,
        potenciaMaximaDescarga_kW=activo.potenciaMaximaDescarga_kW,
        eficienciaCicloCompleto_pct=activo.eficienciaCicloCompleto_pct,
        profundidadDescargaMax_pct=activo.profundidadDescargaMax_pct,
        idComunidadEnergetica=activo.idComunidadEnergetica
    )
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    activo_repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    return crear_activo_almacenamiento_use_case(activo_entity, comunidad_repo, activo_repo)

@router.get("/{id_activo}", response_model=ActivoAlmacenamientoRead)
def obtener_activo(id_activo: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de un activo de almacenamiento por su ID
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    return mostrar_activo_almacenamiento_use_case(id_activo, repo)

@router.get("/comunidad/{id_comunidad}", response_model=List[ActivoAlmacenamientoRead])
def listar_activos_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    """
    Lista todos los activos de almacenamiento de una comunidad energética
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    activos = repo.get_by_comunidad(id_comunidad)
    return activos

@router.get("", response_model=List[ActivoAlmacenamientoRead])
def listar_activos(db: Session = Depends(get_db)):
    """
    Lista todos los activos de almacenamiento registrados
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    return repo.list()

@router.put("/{id_activo}", response_model=ActivoAlmacenamientoRead)
def actualizar_activo(id_activo: int, activo: ActivoAlmacenamientoUpdate, db: Session = Depends(get_db)):
    """
    Actualiza los datos de un activo de almacenamiento existente
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    activo_existente = repo.get_by_id(id_activo)
    if not activo_existente:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
    activo_entity = ActivoAlmacenamientoEntity(
        capacidadNominal_kWh=activo.capacidadNominal_kWh if activo.capacidadNominal_kWh is not None else activo_existente.capacidadNominal_kWh,
        potenciaMaximaCarga_kW=activo.potenciaMaximaCarga_kW if activo.potenciaMaximaCarga_kW is not None else activo_existente.potenciaMaximaCarga_kW,
        potenciaMaximaDescarga_kW=activo.potenciaMaximaDescarga_kW if activo.potenciaMaximaDescarga_kW is not None else activo_existente.potenciaMaximaDescarga_kW,
        eficienciaCicloCompleto_pct=activo.eficienciaCicloCompleto_pct if activo.eficienciaCicloCompleto_pct is not None else activo_existente.eficienciaCicloCompleto_pct,
        profundidadDescargaMax_pct=activo.profundidadDescargaMax_pct if activo.profundidadDescargaMax_pct is not None else activo_existente.profundidadDescargaMax_pct,
        idComunidadEnergetica=activo_existente.idComunidadEnergetica
    )
    return modificar_activo_almacenamiento_use_case(id_activo, activo_entity, repo)

@router.delete("/{id_activo}")
def eliminar_activo(id_activo: int, db: Session = Depends(get_db)):
    """
    Elimina un activo de almacenamiento existente
    """
    repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    eliminar_activo_almacenamiento_use_case(id_activo, repo)
    return {"mensaje": "Activo de almacenamiento eliminado correctamente"}