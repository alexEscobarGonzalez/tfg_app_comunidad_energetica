from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_activo_generacion import (
    InstalacionFotovoltaicaCreate, 
    AerogeneradorCreate, 
    ActivoGeneracionRead, 
    InstalacionFotovoltaicaUpdate, 
    AerogeneradorUpdate
)
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.domain.use_cases.activo_generacion.crear_instalacion_fotovoltaica import crear_instalacion_fotovoltaica_use_case
from app.domain.use_cases.activo_generacion.crear_aerogenerador import crear_aerogenerador_use_case
from app.domain.use_cases.activo_generacion.mostrar_activo_generacion import mostrar_activo_generacion_use_case
from app.domain.use_cases.activo_generacion.modificar_instalacion_fotovoltaica import modificar_instalacion_fotovoltaica_use_case
from app.domain.use_cases.activo_generacion.modificar_aerogenerador import modificar_aerogenerador_use_case
from app.domain.use_cases.activo_generacion.eliminar_activo_generacion import eliminar_activo_generacion_use_case
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
from typing import List
from datetime import date

router = APIRouter(prefix="/activos-generacion", tags=["activos-generacion"])

@router.post("", response_model=ActivoGeneracionRead)
def crear_activo_generacion(instalacion: InstalacionFotovoltaicaCreate, db: Session = Depends(get_db)):
    return crear_instalacion_fotovoltaica(instalacion, db)

@router.post("/instalacion-fotovoltaica", response_model=ActivoGeneracionRead)
def crear_instalacion_fotovoltaica(instalacion: InstalacionFotovoltaicaCreate, db: Session = Depends(get_db)):
    activo_entity = ActivoGeneracionEntity(
        nombreDescriptivo=instalacion.nombreDescriptivo,
        fechaInstalacion=instalacion.fechaInstalacion,
        costeInstalacion_eur=instalacion.costeInstalacion_eur,
        vidaUtil_anios=instalacion.vidaUtil_anios,
        latitud=instalacion.latitud,
        longitud=instalacion.longitud,
        potenciaNominal_kWp=instalacion.potenciaNominal_kWp,
        idComunidadEnergetica=instalacion.idComunidadEnergetica,
        tipo_activo=TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA,
        inclinacionGrados=instalacion.inclinacionGrados,
        azimutGrados=instalacion.azimutGrados,
        tecnologiaPanel=instalacion.tecnologiaPanel,
        perdidaSistema=instalacion.perdidaSistema,
        posicionMontaje=instalacion.posicionMontaje
    )
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    activo_repo = SqlAlchemyActivoGeneracionRepository(db)
    return crear_instalacion_fotovoltaica_use_case(activo_entity, comunidad_repo, activo_repo)

@router.post("/aerogenerador", response_model=ActivoGeneracionRead)
def crear_aerogenerador(aerogenerador: AerogeneradorCreate, db: Session = Depends(get_db)):
    activo_entity = ActivoGeneracionEntity(
        nombreDescriptivo=aerogenerador.nombreDescriptivo,
        fechaInstalacion=aerogenerador.fechaInstalacion,
        costeInstalacion_eur=aerogenerador.costeInstalacion_eur,
        vidaUtil_anios=aerogenerador.vidaUtil_anios,
        latitud=aerogenerador.latitud,
        longitud=aerogenerador.longitud,
        potenciaNominal_kWp=aerogenerador.potenciaNominal_kWp,
        idComunidadEnergetica=aerogenerador.idComunidadEnergetica,
        tipo_activo=TipoActivoGeneracion.AEROGENERADOR,
        curvaPotencia=aerogenerador.curvaPotencia
    )
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    activo_repo = SqlAlchemyActivoGeneracionRepository(db)
    return crear_aerogenerador_use_case(activo_entity, comunidad_repo, activo_repo)

@router.get("/{id_activo}", response_model=ActivoGeneracionRead)
def obtener_activo(id_activo: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    return mostrar_activo_generacion_use_case(id_activo, repo)

@router.get("/comunidad/{id_comunidad}", response_model=List[ActivoGeneracionRead])
def listar_activos_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activos = repo.get_by_comunidad(id_comunidad)
    return activos

@router.get("/comunidad/{id_comunidad}/fotovoltaicas", response_model=List[ActivoGeneracionRead])
def listar_instalaciones_fotovoltaicas_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activos = repo.get_by_comunidad_y_tipo(id_comunidad, TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA)
    return activos

@router.get("/comunidad/{id_comunidad}/aerogeneradores", response_model=List[ActivoGeneracionRead])
def listar_aerogeneradores_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activos = repo.get_by_comunidad_y_tipo(id_comunidad, TipoActivoGeneracion.AEROGENERADOR)
    return activos

@router.put("/instalacion-fotovoltaica/{id_activo}", response_model=ActivoGeneracionRead)
def actualizar_instalacion_fotovoltaica(id_activo: int, instalacion: InstalacionFotovoltaicaUpdate, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activo_entity = ActivoGeneracionEntity(
        nombreDescriptivo=instalacion.nombreDescriptivo,
        costeInstalacion_eur=instalacion.costeInstalacion_eur,
        vidaUtil_anios=instalacion.vidaUtil_anios,
        potenciaNominal_kWp=instalacion.potenciaNominal_kWp,
        inclinacionGrados=instalacion.inclinacionGrados,
        azimutGrados=instalacion.azimutGrados,
        tecnologiaPanel=instalacion.tecnologiaPanel,
        perdidaSistema=instalacion.perdidaSistema,
        posicionMontaje=instalacion.posicionMontaje
    )
    return modificar_instalacion_fotovoltaica_use_case(id_activo, activo_entity, repo)

@router.put("/aerogenerador/{id_activo}", response_model=ActivoGeneracionRead)
def actualizar_aerogenerador(id_activo: int, aerogenerador: AerogeneradorUpdate, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    activo_entity = ActivoGeneracionEntity(
        nombreDescriptivo=aerogenerador.nombreDescriptivo,
        costeInstalacion_eur=aerogenerador.costeInstalacion_eur,
        vidaUtil_anios=aerogenerador.vidaUtil_anios,
        potenciaNominal_kWp=aerogenerador.potenciaNominal_kWp,
        curvaPotencia=aerogenerador.curvaPotencia
    )
    return modificar_aerogenerador_use_case(id_activo, activo_entity, repo)

@router.delete("/{id_activo}")
def eliminar_activo(id_activo: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyActivoGeneracionRepository(db)
    eliminar_activo_generacion_use_case(id_activo, repo)
    return {"mensaje": "Activo de generación eliminado correctamente"}