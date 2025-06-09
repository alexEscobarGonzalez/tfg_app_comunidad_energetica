from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.use_cases.resultado_simulacion_activo_generacion.resultado_simulacion_activo_generacion_use_cases import ResultadoSimulacionActivoGeneracionUseCases
from app.infrastructure.persistance.database import get_db
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_generacion_repository import SqlAlchemyResultadoSimulacionActivoGeneracionRepository
from app.interfaces.schemas_resultado_simulacion_activo_generacion import (
    ResultadoSimulacionActivoGeneracionCreate,
    ResultadoSimulacionActivoGeneracionRead,
    ResultadoSimulacionActivoGeneracionUpdate
)

router = APIRouter(
    prefix="/resultados-simulacion-activo-generacion",
    tags=["Resultados Simulación Activo Generación"],
    responses={404: {"description": "No encontrado"}},
)

def get_use_cases(db: Session = Depends(get_db)):
    repository = SqlAlchemyResultadoSimulacionActivoGeneracionRepository(db)
    return ResultadoSimulacionActivoGeneracionUseCases(repository)

@router.get("/{resultado_activo_id}", response_model=ResultadoSimulacionActivoGeneracionRead)
def get_resultado_activo_gen(resultado_activo_id: int, use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)):
    resultado = use_cases.get_by_id(resultado_activo_id)
    if resultado is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resultado de simulación por activo de generación con ID {resultado_activo_id} no encontrado"
        )
    return resultado

@router.get("/simulacion/{resultado_simulacion_id}", response_model=List[ResultadoSimulacionActivoGeneracionRead])
def get_resultados_by_simulacion(resultado_simulacion_id: int, use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)):
    resultados = use_cases.get_by_resultado_simulacion_id(resultado_simulacion_id)
    return resultados

@router.get("/activo-generacion/{activo_generacion_id}", response_model=List[ResultadoSimulacionActivoGeneracionRead])
def get_resultados_by_activo_generacion(activo_generacion_id: int, use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)):
    resultados = use_cases.get_by_activo_generacion_id(activo_generacion_id)
    return resultados

@router.get("/", response_model=List[ResultadoSimulacionActivoGeneracionRead])
def list_resultados_activo_gen(
    skip: int = 0, 
    limit: int = 100, 
    use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)
):
    resultados = use_cases.list(skip=skip, limit=limit)
    return resultados

@router.post("/", response_model=ResultadoSimulacionActivoGeneracionRead, status_code=status.HTTP_201_CREATED)
def create_resultado_activo_gen(
    resultado_data: ResultadoSimulacionActivoGeneracionCreate, 
    use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)
):
    # Convertir de schema a entity
    entity = ResultadoSimulacionActivoGeneracionEntity(
        energiaTotalGenerada_kWh=resultado_data.energiaTotalGenerada_kWh,
        factorCapacidad_pct=resultado_data.factorCapacidad_pct,
        performanceRatio_pct=resultado_data.performanceRatio_pct,
        horasOperacionEquivalentes=resultado_data.horasOperacionEquivalentes,
        idResultadoSimulacion=resultado_data.idResultadoSimulacion,
        idActivoGeneracion=resultado_data.idActivoGeneracion
    )
    
    return use_cases.create(entity)

@router.put("/{resultado_activo_id}", response_model=ResultadoSimulacionActivoGeneracionRead)
def update_resultado_activo_gen(
    resultado_activo_id: int,
    resultado_data: ResultadoSimulacionActivoGeneracionUpdate,
    use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)
):
    # Primero verificamos que existe
    resultado_existente = use_cases.get_by_id(resultado_activo_id)
    if resultado_existente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resultado de simulación por activo de generación con ID {resultado_activo_id} no encontrado"
        )
    
    # Actualizar solo los campos proporcionados
    update_data = resultado_existente
    
    if resultado_data.energiaTotalGenerada_kWh is not None:
        update_data.energiaTotalGenerada_kWh = resultado_data.energiaTotalGenerada_kWh
    if resultado_data.factorCapacidad_pct is not None:
        update_data.factorCapacidad_pct = resultado_data.factorCapacidad_pct
    if resultado_data.performanceRatio_pct is not None:
        update_data.performanceRatio_pct = resultado_data.performanceRatio_pct
    if resultado_data.horasOperacionEquivalentes is not None:
        update_data.horasOperacionEquivalentes = resultado_data.horasOperacionEquivalentes
    
    return use_cases.update(resultado_activo_id, update_data)

@router.delete("/{resultado_activo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_resultado_activo_gen(
    resultado_activo_id: int,
    use_cases: ResultadoSimulacionActivoGeneracionUseCases = Depends(get_use_cases)
):
    resultado_existente = use_cases.get_by_id(resultado_activo_id)
    if resultado_existente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Resultado de simulación por activo de generación con ID {resultado_activo_id} no encontrado"
        )
    
    use_cases.delete(resultado_activo_id)
    return None