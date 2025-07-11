from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_resultado_simulacion import ResultadoSimulacionCreate, ResultadoSimulacionRead, ResultadoSimulacionUpdate
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
from app.domain.use_cases.resultado_simulacion.get_resultado_simulacion import mostrar_resultado_simulacion_use_case, mostrar_resultado_por_simulacion_use_case
from app.domain.use_cases.resultado_simulacion.list_resultados_simulacion import listar_resultados_simulacion_use_case
from app.domain.use_cases.resultado_simulacion.create_resultado_simulacion import crear_resultado_simulacion_use_case
from app.domain.use_cases.resultado_simulacion.update_resultado_simulacion import modificar_resultado_simulacion_use_case
from app.domain.use_cases.resultado_simulacion.delete_resultado_simulacion import eliminar_resultado_simulacion_use_case

router = APIRouter(
    prefix="/resultados-simulacion",
    tags=["resultados-simulacion"],
    responses={404: {"description": "Resultado de simulación no encontrado"}}
)

@router.post("", response_model=ResultadoSimulacionRead, status_code=status.HTTP_201_CREATED)
def crear_resultado_simulacion(resultado: ResultadoSimulacionCreate, db: Session = Depends(get_db)):
    # Verificar si ya existe un resultado para esta simulación
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    resultado_existente = mostrar_resultado_por_simulacion_use_case(resultado.idSimulacion, repo)
    if resultado_existente:
        raise HTTPException(
            status_code=400,
            detail=f"Ya existe un resultado para la simulación con ID {resultado.idSimulacion}"
        )
    
    resultado_entity = ResultadoSimulacionEntity(
        costeTotalEnergia_eur=resultado.costeTotalEnergia_eur,
        ahorroTotal_eur=resultado.ahorroTotal_eur,
        ingresoTotalExportacion_eur=resultado.ingresoTotalExportacion_eur,
        paybackPeriod_anios=resultado.paybackPeriod_anios,
        roi_pct=resultado.roi_pct,
        tasaAutoconsumoSCR_pct=resultado.tasaAutoconsumoSCR_pct,
        tasaAutosuficienciaSSR_pct=resultado.tasaAutosuficienciaSSR_pct,
        energiaTotalImportada_kWh=resultado.energiaTotalImportada_kWh,
        energiaTotalExportada_kWh=resultado.energiaTotalExportada_kWh,
        reduccionCO2_kg=resultado.reduccionCO2_kg,
        idSimulacion=resultado.idSimulacion
    )
    
    return crear_resultado_simulacion_use_case(resultado_entity, repo)

@router.get("/{id_resultado}", response_model=ResultadoSimulacionRead)
def obtener_resultado(id_resultado: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    # La función ya maneja el caso de no encontrar el resultado y lanza una excepción HTTPException
    return mostrar_resultado_simulacion_use_case(id_resultado, repo)

@router.get("/simulacion/{id_simulacion}", response_model=ResultadoSimulacionRead)
def obtener_resultado_por_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    resultado = mostrar_resultado_por_simulacion_use_case(id_simulacion, repo)
    
    if resultado is None:
        raise HTTPException(
            status_code=404,
            detail=f"No se encontró resultado para la simulación con ID {id_simulacion}"
        )
        
    return resultado

@router.get("", response_model=List[ResultadoSimulacionRead])
def listar_resultados(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    return listar_resultados_simulacion_use_case(repo, skip, limit)

@router.put("/{id_resultado}", response_model=ResultadoSimulacionRead)
def actualizar_resultado(id_resultado: int, resultado: ResultadoSimulacionUpdate, db: Session = Depends(get_db)):
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    
    # Verificar si el resultado existe - esta verificación la hace la función modificar_resultado_simulacion_use_case
    resultado_existente = mostrar_resultado_simulacion_use_case(id_resultado, repo)
    
    # Crear entidad con los campos actualizados
    resultado_entity = ResultadoSimulacionEntity(
        idResultado=id_resultado,
        fechaCreacion=resultado_existente.fechaCreacion,
        costeTotalEnergia_eur=resultado.costeTotalEnergia_eur if resultado.costeTotalEnergia_eur is not None else resultado_existente.costeTotalEnergia_eur,
        ahorroTotal_eur=resultado.ahorroTotal_eur if resultado.ahorroTotal_eur is not None else resultado_existente.ahorroTotal_eur,
        ingresoTotalExportacion_eur=resultado.ingresoTotalExportacion_eur if resultado.ingresoTotalExportacion_eur is not None else resultado_existente.ingresoTotalExportacion_eur,
        paybackPeriod_anios=resultado.paybackPeriod_anios if resultado.paybackPeriod_anios is not None else resultado_existente.paybackPeriod_anios,
        roi_pct=resultado.roi_pct if resultado.roi_pct is not None else resultado_existente.roi_pct,
        tasaAutoconsumoSCR_pct=resultado.tasaAutoconsumoSCR_pct if resultado.tasaAutoconsumoSCR_pct is not None else resultado_existente.tasaAutoconsumoSCR_pct,
        tasaAutosuficienciaSSR_pct=resultado.tasaAutosuficienciaSSR_pct if resultado.tasaAutosuficienciaSSR_pct is not None else resultado_existente.tasaAutosuficienciaSSR_pct,
        energiaTotalImportada_kWh=resultado.energiaTotalImportada_kWh if resultado.energiaTotalImportada_kWh is not None else resultado_existente.energiaTotalImportada_kWh,
        energiaTotalExportada_kWh=resultado.energiaTotalExportada_kWh if resultado.energiaTotalExportada_kWh is not None else resultado_existente.energiaTotalExportada_kWh,
        reduccionCO2_kg=resultado.reduccionCO2_kg if resultado.reduccionCO2_kg is not None else resultado_existente.reduccionCO2_kg,
        idSimulacion=resultado_existente.idSimulacion
    )
    
    return modificar_resultado_simulacion_use_case(id_resultado, resultado_entity, repo)

@router.delete("/{id_resultado}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_resultado(id_resultado: int, db: Session = Depends(get_db)):
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    
    # Verificar si el resultado existe - ahora esta verificación la hace la función eliminar_resultado_simulacion_use_case
    eliminar_resultado_simulacion_use_case(id_resultado, repo)
    
    return None