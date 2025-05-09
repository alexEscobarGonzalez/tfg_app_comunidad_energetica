from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_resultado_simulacion_activo_almacenamiento import (
    ResultadoSimulacionActivoAlmacenamientoCreate,
    ResultadoSimulacionActivoAlmacenamientoRead,
    ResultadoSimulacionActivoAlmacenamientoUpdate
)
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_almacenamiento_repository import SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.get_resultado_activo_almacenamiento import (
    obtener_resultado_activo_almacenamiento_use_case,
    obtener_resultados_por_simulacion_use_case, 
    obtener_resultado_por_simulacion_y_activo_use_case
)
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.list_resultados_activo_almacenamiento import listar_resultados_activo_almacenamiento_use_case
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.create_resultado_activo_almacenamiento import crear_resultado_activo_almacenamiento_use_case
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.update_resultado_activo_almacenamiento import modificar_resultado_activo_almacenamiento_use_case
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.delete_resultado_activo_almacenamiento import eliminar_resultado_activo_almacenamiento_use_case

router = APIRouter(
    prefix="/resultados-activos-almacenamiento",
    tags=["resultados-activos-almacenamiento"],
    responses={404: {"description": "Resultado de activo de almacenamiento no encontrado"}}
)

@router.post("", response_model=ResultadoSimulacionActivoAlmacenamientoRead, status_code=status.HTTP_201_CREATED)
def crear_resultado_activo_almacenamiento(resultado: ResultadoSimulacionActivoAlmacenamientoCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo resultado para un activo de almacenamiento en una simulación
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    
    # Verificar si ya existe un resultado para esta combinación
    existing = obtener_resultado_por_simulacion_y_activo_use_case(
        resultado.idResultadoSimulacion,
        resultado.idActivoAlmacenamiento,
        repo
    )
    
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Ya existe un resultado para la combinación de resultado de simulación ID {resultado.idResultadoSimulacion} y activo de almacenamiento ID {resultado.idActivoAlmacenamiento}"
        )
    
    resultado_entity = ResultadoSimulacionActivoAlmacenamientoEntity(
        energiaTotalCargada_kWh=resultado.energiaTotalCargada_kWh,
        energiaTotalDescargada_kWh=resultado.energiaTotalDescargada_kWh,
        ciclosEquivalentes=resultado.ciclosEquivalentes,
        perdidasEficiencia_kWh=resultado.perdidasEficiencia_kWh,
        socMedio_pct=resultado.socMedio_pct,
        socMin_pct=resultado.socMin_pct,
        socMax_pct=resultado.socMax_pct,
        degradacionEstimada_pct=resultado.degradacionEstimada_pct,
        throughputTotal_kWh=resultado.throughputTotal_kWh,
        idResultadoSimulacion=resultado.idResultadoSimulacion,
        idActivoAlmacenamiento=resultado.idActivoAlmacenamiento
    )
    
    return crear_resultado_activo_almacenamiento_use_case(resultado_entity, repo)

@router.get("/{id_resultado}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def obtener_resultado_activo_almacenamiento(id_resultado: int, db: Session = Depends(get_db)):
    """
    Obtiene un resultado de activo de almacenamiento por su ID
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    return obtener_resultado_activo_almacenamiento_use_case(id_resultado, repo)

@router.get("/resultado-simulacion/{id_resultado_simulacion}", response_model=List[ResultadoSimulacionActivoAlmacenamientoRead])
def obtener_resultados_por_simulacion(id_resultado_simulacion: int, db: Session = Depends(get_db)):
    """
    Obtiene todos los resultados de activos de almacenamiento para una simulación específica
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    return obtener_resultados_por_simulacion_use_case(id_resultado_simulacion, repo)

@router.get("/resultado-simulacion/{id_resultado_simulacion}/activo-almacenamiento/{id_activo}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def obtener_resultado_por_simulacion_y_activo(id_resultado_simulacion: int, id_activo: int, db: Session = Depends(get_db)):
    """
    Obtiene un resultado específico por su combinación de simulación y activo de almacenamiento
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    resultado = obtener_resultado_por_simulacion_y_activo_use_case(id_resultado_simulacion, id_activo, repo)
    
    if not resultado:
        raise HTTPException(
            status_code=404,
            detail=f"No se encontró resultado para la combinación de resultado de simulación ID {id_resultado_simulacion} y activo de almacenamiento ID {id_activo}"
        )
    
    return resultado

@router.get("", response_model=List[ResultadoSimulacionActivoAlmacenamientoRead])
def listar_resultados(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Lista todos los resultados de activos de almacenamiento
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    return listar_resultados_activo_almacenamiento_use_case(repo, skip, limit)

@router.put("/{id_resultado}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def actualizar_resultado(id_resultado: int, resultado: ResultadoSimulacionActivoAlmacenamientoUpdate, db: Session = Depends(get_db)):
    """
    Actualiza un resultado de activo de almacenamiento existente
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    
    # Verificar que el resultado existe
    resultado_existente = obtener_resultado_activo_almacenamiento_use_case(id_resultado, repo)
    
    # Crear entidad con los campos actualizados
    resultado_entity = ResultadoSimulacionActivoAlmacenamientoEntity(
        idResultadoActivoAlm=id_resultado,
        energiaTotalCargada_kWh=resultado.energiaTotalCargada_kWh if resultado.energiaTotalCargada_kWh is not None else resultado_existente.energiaTotalCargada_kWh,
        energiaTotalDescargada_kWh=resultado.energiaTotalDescargada_kWh if resultado.energiaTotalDescargada_kWh is not None else resultado_existente.energiaTotalDescargada_kWh,
        ciclosEquivalentes=resultado.ciclosEquivalentes if resultado.ciclosEquivalentes is not None else resultado_existente.ciclosEquivalentes,
        perdidasEficiencia_kWh=resultado.perdidasEficiencia_kWh if resultado.perdidasEficiencia_kWh is not None else resultado_existente.perdidasEficiencia_kWh,
        socMedio_pct=resultado.socMedio_pct if resultado.socMedio_pct is not None else resultado_existente.socMedio_pct,
        socMin_pct=resultado.socMin_pct if resultado.socMin_pct is not None else resultado_existente.socMin_pct,
        socMax_pct=resultado.socMax_pct if resultado.socMax_pct is not None else resultado_existente.socMax_pct,
        degradacionEstimada_pct=resultado.degradacionEstimada_pct if resultado.degradacionEstimada_pct is not None else resultado_existente.degradacionEstimada_pct,
        throughputTotal_kWh=resultado.throughputTotal_kWh if resultado.throughputTotal_kWh is not None else resultado_existente.throughputTotal_kWh,
        idResultadoSimulacion=resultado_existente.idResultadoSimulacion,
        idActivoAlmacenamiento=resultado_existente.idActivoAlmacenamiento
    )
    
    return modificar_resultado_activo_almacenamiento_use_case(id_resultado, resultado_entity, repo)

@router.delete("/{id_resultado}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_resultado(id_resultado: int, db: Session = Depends(get_db)):
    """
    Elimina un resultado de activo de almacenamiento
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    
    # Verificar que el resultado existe
    obtener_resultado_activo_almacenamiento_use_case(id_resultado, repo)
    
    eliminar_resultado_activo_almacenamiento_use_case(id_resultado, repo)
    
    return None