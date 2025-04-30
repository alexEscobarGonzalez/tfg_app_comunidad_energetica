from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_resultado_simulacion import ResultadoSimulacionCreate, ResultadoSimulacionRead, ResultadoSimulacionUpdate
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
from app.domain.use_cases.resultado_simulacion.get_resultado_simulacion import GetResultadoSimulacion, GetResultadoBySimulacion
from app.domain.use_cases.resultado_simulacion.list_resultados_simulacion import ListResultadosSimulacion
from app.domain.use_cases.resultado_simulacion.create_resultado_simulacion import CreateResultadoSimulacion
from app.domain.use_cases.resultado_simulacion.update_resultado_simulacion import UpdateResultadoSimulacion
from app.domain.use_cases.resultado_simulacion.delete_resultado_simulacion import DeleteResultadoSimulacion

router = APIRouter(
    prefix="/resultados-simulacion",
    tags=["resultados-simulacion"],
    responses={404: {"description": "Resultado de simulación no encontrado"}}
)

@router.post("", response_model=ResultadoSimulacionRead, status_code=status.HTTP_201_CREATED)
def crear_resultado_simulacion(resultado: ResultadoSimulacionCreate, db: Session = Depends(get_db)):
    """
    Crea un nuevo resultado de simulación para una simulación específica.
    """
    # Verificar si ya existe un resultado para esta simulación
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    resultado_existente = GetResultadoBySimulacion(repo).execute(resultado.idSimulacion)
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
        energiaCompartidaInterna_kWh=resultado.energiaCompartidaInterna_kWh,
        reduccionPicoDemanda_kW=resultado.reduccionPicoDemanda_kW,
        reduccionPicoDemanda_pct=resultado.reduccionPicoDemanda_pct,
        reduccionCO2_kg=resultado.reduccionCO2_kg,
        idSimulacion=resultado.idSimulacion
    )
    
    use_case = CreateResultadoSimulacion(repo)
    return use_case.execute(resultado_entity)

@router.get("/{id_resultado}", response_model=ResultadoSimulacionRead)
def obtener_resultado(id_resultado: int, db: Session = Depends(get_db)):
    """
    Obtiene un resultado de simulación por su ID
    """
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    use_case = GetResultadoSimulacion(repo)
    resultado = use_case.execute(id_resultado)
    
    if resultado is None:
        raise HTTPException(
            status_code=404,
            detail=f"Resultado de simulación con ID {id_resultado} no encontrado"
        )
        
    return resultado

@router.get("/simulacion/{id_simulacion}", response_model=ResultadoSimulacionRead)
def obtener_resultado_por_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    """
    Obtiene el resultado asociado a una simulación específica
    """
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    use_case = GetResultadoBySimulacion(repo)
    resultado = use_case.execute(id_simulacion)
    
    if resultado is None:
        raise HTTPException(
            status_code=404,
            detail=f"No se encontró resultado para la simulación con ID {id_simulacion}"
        )
        
    return resultado

@router.get("", response_model=List[ResultadoSimulacionRead])
def listar_resultados(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Lista todos los resultados de simulaciones
    """
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    use_case = ListResultadosSimulacion(repo)
    return use_case.execute(skip, limit)

@router.put("/{id_resultado}", response_model=ResultadoSimulacionRead)
def actualizar_resultado(id_resultado: int, resultado: ResultadoSimulacionUpdate, db: Session = Depends(get_db)):
    """
    Actualiza un resultado de simulación existente
    """
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    
    # Verificar si el resultado existe
    get_use_case = GetResultadoSimulacion(repo)
    resultado_existente = get_use_case.execute(id_resultado)
    if resultado_existente is None:
        raise HTTPException(
            status_code=404, 
            detail=f"Resultado de simulación con ID {id_resultado} no encontrado"
        )
    
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
        energiaCompartidaInterna_kWh=resultado.energiaCompartidaInterna_kWh if resultado.energiaCompartidaInterna_kWh is not None else resultado_existente.energiaCompartidaInterna_kWh,
        reduccionPicoDemanda_kW=resultado.reduccionPicoDemanda_kW if resultado.reduccionPicoDemanda_kW is not None else resultado_existente.reduccionPicoDemanda_kW,
        reduccionPicoDemanda_pct=resultado.reduccionPicoDemanda_pct if resultado.reduccionPicoDemanda_pct is not None else resultado_existente.reduccionPicoDemanda_pct,
        reduccionCO2_kg=resultado.reduccionCO2_kg if resultado.reduccionCO2_kg is not None else resultado_existente.reduccionCO2_kg,
        idSimulacion=resultado_existente.idSimulacion
    )
    
    update_use_case = UpdateResultadoSimulacion(repo)
    return update_use_case.execute(id_resultado, resultado_entity)

@router.delete("/{id_resultado}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_resultado(id_resultado: int, db: Session = Depends(get_db)):
    """
    Elimina un resultado de simulación
    """
    repo = SqlAlchemyResultadoSimulacionRepository(db)
    
    # Verificar si el resultado existe
    get_use_case = GetResultadoSimulacion(repo)
    resultado_existente = get_use_case.execute(id_resultado)
    if resultado_existente is None:
        raise HTTPException(
            status_code=404, 
            detail=f"Resultado de simulación con ID {id_resultado} no encontrado"
        )
    
    delete_use_case = DeleteResultadoSimulacion(repo)
    delete_use_case.execute(id_resultado)
    
    return None