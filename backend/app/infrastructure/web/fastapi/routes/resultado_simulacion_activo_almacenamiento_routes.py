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
    GetResultadoActivoAlmacenamiento,
    GetResultadosActivosAlmacenamientoByResultadoSimulacion,
    GetResultadosActivoAlmacenamiento,
    GetResultadoBySimulacionAndActivo
)
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.list_resultados_activo_almacenamiento import ListResultadosActivoAlmacenamiento
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.create_resultado_activo_almacenamiento import CreateResultadoActivoAlmacenamiento
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.update_resultado_activo_almacenamiento import UpdateResultadoActivoAlmacenamiento
from app.domain.use_cases.resultado_simulacion_activo_almacenamiento.delete_resultado_activo_almacenamiento import DeleteResultadoActivoAlmacenamiento

router = APIRouter(
    prefix="/resultados-activos-almacenamiento",
    tags=["resultados-activos-almacenamiento"],
    responses={404: {"description": "Resultado de activo de almacenamiento no encontrado"}}
)

@router.post("", response_model=ResultadoSimulacionActivoAlmacenamientoRead, status_code=status.HTTP_201_CREATED)
def crear_resultado_activo_almacenamiento(resultado: ResultadoSimulacionActivoAlmacenamientoCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo resultado de simulación para un activo de almacenamiento específico
    """
    # Primero verificamos si ya existe un resultado para esa combinación de resultado de simulación y activo de almacenamiento
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    existing = GetResultadoBySimulacionAndActivo(repo).execute(
        resultado.idResultadoSimulacion,
        resultado.idActivoAlmacenamiento
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
    
    use_case = CreateResultadoActivoAlmacenamiento(repo)
    return use_case.execute(resultado_entity)

@router.get("/{id_resultado}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def obtener_resultado_activo_almacenamiento(id_resultado: int, db: Session = Depends(get_db)):
    """
    Obtiene un resultado específico por su ID
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    use_case = GetResultadoActivoAlmacenamiento(repo)
    resultado = use_case.execute(id_resultado)
    
    if not resultado:
        raise HTTPException(
            status_code=404,
            detail=f"Resultado de activo de almacenamiento con ID {id_resultado} no encontrado"
        )
        
    return resultado

@router.get("/resultado-simulacion/{id_resultado_simulacion}", response_model=List[ResultadoSimulacionActivoAlmacenamientoRead])
def obtener_resultados_por_simulacion(id_resultado_simulacion: int, db: Session = Depends(get_db)):
    """
    Obtiene todos los resultados de activos de almacenamiento asociados a un resultado de simulación
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    use_case = GetResultadosActivosAlmacenamientoByResultadoSimulacion(repo)
    return use_case.execute(id_resultado_simulacion)

@router.get("/activo-almacenamiento/{id_activo}", response_model=List[ResultadoSimulacionActivoAlmacenamientoRead])
def obtener_resultados_por_activo(id_activo: int, db: Session = Depends(get_db)):
    """
    Obtiene todos los resultados de simulación para un activo de almacenamiento específico
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    use_case = GetResultadosActivoAlmacenamiento(repo)
    return use_case.execute(id_activo)

@router.get("/resultado-simulacion/{id_resultado_simulacion}/activo-almacenamiento/{id_activo}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def obtener_resultado_por_simulacion_y_activo(id_resultado_simulacion: int, id_activo: int, db: Session = Depends(get_db)):
    """
    Obtiene el resultado específico para una combinación de resultado de simulación y activo de almacenamiento
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    use_case = GetResultadoBySimulacionAndActivo(repo)
    resultado = use_case.execute(id_resultado_simulacion, id_activo)
    
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
    use_case = ListResultadosActivoAlmacenamiento(repo)
    return use_case.execute(skip, limit)

@router.put("/{id_resultado}", response_model=ResultadoSimulacionActivoAlmacenamientoRead)
def actualizar_resultado(id_resultado: int, resultado: ResultadoSimulacionActivoAlmacenamientoUpdate, db: Session = Depends(get_db)):
    """
    Actualiza un resultado existente
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    
    # Verificar si el resultado existe
    get_use_case = GetResultadoActivoAlmacenamiento(repo)
    resultado_existente = get_use_case.execute(id_resultado)
    if not resultado_existente:
        raise HTTPException(
            status_code=404, 
            detail=f"Resultado de activo de almacenamiento con ID {id_resultado} no encontrado"
        )
    
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
    
    update_use_case = UpdateResultadoActivoAlmacenamiento(repo)
    return update_use_case.execute(id_resultado, resultado_entity)

@router.delete("/{id_resultado}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_resultado(id_resultado: int, db: Session = Depends(get_db)):
    """
    Elimina un resultado existente
    """
    repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db)
    
    # Verificar si el resultado existe
    get_use_case = GetResultadoActivoAlmacenamiento(repo)
    resultado_existente = get_use_case.execute(id_resultado)
    if not resultado_existente:
        raise HTTPException(
            status_code=404, 
            detail=f"Resultado de activo de almacenamiento con ID {id_resultado} no encontrado"
        )
    
    delete_use_case = DeleteResultadoActivoAlmacenamiento(repo)
    delete_use_case.execute(id_resultado)
    
    return None