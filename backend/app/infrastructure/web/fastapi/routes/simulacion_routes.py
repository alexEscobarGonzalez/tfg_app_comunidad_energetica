from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_simulacion import (
    SimulacionCreate,
    SimulacionResponse,
    SimulacionUpdate,
)
from app.domain.entities.simulacion import SimulacionEntity, EstadoSimulacion, TipoEstrategiaExcedentes
from app.domain.use_cases.simulacion.create_simulacion import crear_simulacion_use_case
from app.domain.use_cases.simulacion.get_simulacion import mostrar_simulacion_use_case
from app.domain.use_cases.simulacion.list_simulaciones import listar_simulaciones_use_case, listar_simulaciones_por_comunidad_use_case, listar_simulaciones_por_usuario_use_case
from app.domain.use_cases.simulacion.update_simulacion import modificar_simulacion_use_case, actualizar_estado_simulacion_use_case
from app.domain.use_cases.simulacion.delete_simulacion import eliminar_simulacion_use_case
from app.domain.use_cases.simulacion.motor_simulacion.motor_simulacion import MotorSimulacion
from app.infrastructure.persistance.repository.sqlalchemy_simulacion_repository import SqlAlchemySimulacionRepository
from typing import List
import time
from app.interfaces.schemas_resultado_simulacion import ResultadoSimulacionCreate
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
from app.domain.entities.estado_simulacion import EstadoSimulacion

router = APIRouter(prefix="/simulaciones", tags=["simulaciones"])

@router.post("", response_model=SimulacionResponse)
def crear_simulacion(simulacion: SimulacionCreate, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    simulacion_entity = SimulacionEntity(
        nombreSimulacion=simulacion.nombreSimulacion,
        fechaInicio=simulacion.fechaInicio,
        fechaFin=simulacion.fechaFin,
        tiempo_medicion=simulacion.tiempo_medicion,
        estado=EstadoSimulacion.PENDIENTE,
        tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(simulacion.tipoEstrategiaExcedentes.value),
        idUsuario_creador=simulacion.idUsuario_creador,
        idComunidadEnergetica=simulacion.idComunidadEnergetica
    )
    return crear_simulacion_use_case(simulacion_entity, repo)

@router.get("/{id_simulacion}", response_model=SimulacionResponse)
def obtener_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    return mostrar_simulacion_use_case(id_simulacion, repo)

@router.get("/comunidad/{id_comunidad}", response_model=List[SimulacionResponse])
def listar_simulaciones_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    return listar_simulaciones_por_comunidad_use_case(id_comunidad, repo)

@router.get("/usuario/{id_usuario}", response_model=List[SimulacionResponse])
def listar_simulaciones_por_usuario(id_usuario: int, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    return listar_simulaciones_por_usuario_use_case(id_usuario, repo)

@router.get("", response_model=List[SimulacionResponse])
def listar_simulaciones(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    return listar_simulaciones_use_case(repo, skip, limit)

@router.put("/{id_simulacion}", response_model=SimulacionResponse)
def actualizar_simulacion(id_simulacion: int, simulacion: SimulacionUpdate, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    simulacion_existente = mostrar_simulacion_use_case(id_simulacion, repo)
    if not simulacion_existente:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    simulacion_entity = SimulacionEntity(
        idSimulacion=id_simulacion,
        nombreSimulacion=simulacion.nombreSimulacion if simulacion.nombreSimulacion is not None else simulacion_existente.nombreSimulacion,
        fechaInicio=simulacion.fechaInicio if simulacion.fechaInicio is not None else simulacion_existente.fechaInicio,
        fechaFin=simulacion.fechaFin if simulacion.fechaFin is not None else simulacion_existente.fechaFin,
        tiempo_medicion=simulacion.tiempo_medicion if simulacion.tiempo_medicion is not None else simulacion_existente.tiempo_medicion,
        estado=EstadoSimulacion(simulacion.estado.value) if simulacion.estado is not None else simulacion_existente.estado,
        tipoEstrategiaExcedentes=TipoEstrategiaExcedentes(simulacion.tipoEstrategiaExcedentes.value) if simulacion.tipoEstrategiaExcedentes is not None else simulacion_existente.tipoEstrategiaExcedentes,
        idUsuario_creador=simulacion_existente.idUsuario_creador,
        idComunidadEnergetica=simulacion_existente.idComunidadEnergetica
    )
    return modificar_simulacion_use_case(id_simulacion, simulacion_entity, repo)

@router.delete("/{id_simulacion}")
def eliminar_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    repo = SqlAlchemySimulacionRepository(db)
    return eliminar_simulacion_use_case(id_simulacion, repo)

@router.post("/{id_simulacion}/ejecutar", status_code=202)
def ejecutar_simulacion(id_simulacion: int, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    Ejecuta el motor de simulación avanzado para una simulación existente
    """
    # Verificar que la simulación existe
    repo = SqlAlchemySimulacionRepository(db)
    simulacion = mostrar_simulacion_use_case(id_simulacion, repo)
    
    if not simulacion:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    # Verificar que la simulación esté en estado que permita ejecución
    estados_permitidos = [EstadoSimulacion.PENDIENTE.value, EstadoSimulacion.FALLIDA.value]
    if simulacion.estado not in estados_permitidos:
        raise HTTPException(
            status_code=400, 
            detail=f"La simulación no puede ser ejecutada desde el estado '{simulacion.estado}'"
        )
    
    # Función para ejecutar el motor de simulación en segundo plano
    def ejecutar_motor_simulacion(sim_id: int, db_session: Session):
        try:
            # Importar los repositorios necesarios
            from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository
            from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository
            from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
            from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository
            from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository
            from app.infrastructure.persistance.repository.sqlalchemy_contrato_autoconsumo_repository import SqlAlchemyContratoAutoconsumoRepository
            from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
            from app.infrastructure.persistance.repository.sqlalchemy_datos_ambientales_repository import SqlAlchemyDatosAmbientalesRepository
            from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
            from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_participante_repository import SqlAlchemyResultadoSimulacionParticipanteRepository
            from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_generacion_repository import SqlAlchemyResultadoSimulacionActivoGeneracionRepository
            from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_activo_almacenamiento_repository import SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository
            from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_participante_repository import SqlAlchemyDatosIntervaloParticipanteRepository
            from app.infrastructure.persistance.repository.sqlalchemy_datos_intervalo_activo_repository import SqlAlchemyDatosIntervaloActivoRepository
            from app.infrastructure.pvgis.datos_ambientales_api_repository import DatosAmbientalesApiRepository
            
            # Inicializar todos los repositorios necesarios
            simulacion_repo = SqlAlchemySimulacionRepository(db_session)
            comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db_session)
            participante_repo = SqlAlchemyParticipanteRepository(db_session)
            activo_gen_repo = SqlAlchemyActivoGeneracionRepository(db_session)
            activo_alm_repo = SqlAlchemyActivoAlmacenamientoRepository(db_session)
            coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db_session)
            contrato_repo = SqlAlchemyContratoAutoconsumoRepository(db_session)
            registro_consumo_repo = SqlAlchemyRegistroConsumoRepository(db_session)
            datos_ambientales_repo = SqlAlchemyDatosAmbientalesRepository(db_session)
            resultado_simulacion_repo = SqlAlchemyResultadoSimulacionRepository(db_session)
            resultado_participante_repo = SqlAlchemyResultadoSimulacionParticipanteRepository(db_session)
            resultado_activo_gen_repo = SqlAlchemyResultadoSimulacionActivoGeneracionRepository(db_session)
            resultado_activo_alm_repo = SqlAlchemyResultadoSimulacionActivoAlmacenamientoRepository(db_session)
            datos_intervalo_participante_repo = SqlAlchemyDatosIntervaloParticipanteRepository(db_session)
            datos_intervalo_activo_repo = SqlAlchemyDatosIntervaloActivoRepository(db_session)
            datos_ambientales_api_repo = DatosAmbientalesApiRepository()
            
        
            
            # Inicializar el motor de simulación con todos los repositorios requeridos
            motor = MotorSimulacion(
                simulacion_repo=simulacion_repo,
                comunidad_repo=comunidad_repo,
                participante_repo=participante_repo,
                activo_gen_repo=activo_gen_repo,
                activo_alm_repo=activo_alm_repo,
                coeficiente_repo=coeficiente_repo,
                contrato_repo=contrato_repo,
                registro_consumo_repo=registro_consumo_repo,
                datos_ambientales_repo=datos_ambientales_repo,
                resultado_simulacion_repo=resultado_simulacion_repo,
                resultado_participante_repo=resultado_participante_repo,
                resultado_activo_gen_repo=resultado_activo_gen_repo,
                resultado_activo_alm_repo=resultado_activo_alm_repo,
                datos_intervalo_participante_repo=datos_intervalo_participante_repo,
                datos_intervalo_activo_repo=datos_intervalo_activo_repo,
                datos_ambientales_api_repo=datos_ambientales_api_repo,
                db_session=db_session
            )
            
            # Ejecutar la simulación
            print(f"Iniciando motor de simulación avanzado para simulación ID: {sim_id}")
            motor.ejecutar_simulacion(sim_id)
            print(f"Simulación {sim_id} procesada correctamente con el motor avanzado")
        except Exception as e:
            print(f"Error al ejecutar la simulación {sim_id}: {str(e)}")
            # Actualizar el estado a error en caso de fallo
            try:
                repo = SqlAlchemySimulacionRepository(db_session)
                actualizar_estado_simulacion_use_case(sim_id, EstadoSimulacion.FALLIDA.value, repo)
            except Exception as update_error:
                print(f"Error adicional al actualizar el estado: {str(update_error)}")
    
    # Actualizar el estado a 'En ejecución'
    actualizar_estado_simulacion_use_case(id_simulacion, EstadoSimulacion.EJECUTANDO.value, repo)
    
    # Programar la ejecución en segundo plano
    background_tasks.add_task(ejecutar_motor_simulacion, id_simulacion, db)
    
    return {"mensaje": f"Simulación {id_simulacion} iniciada correctamente", "status": "procesando"}