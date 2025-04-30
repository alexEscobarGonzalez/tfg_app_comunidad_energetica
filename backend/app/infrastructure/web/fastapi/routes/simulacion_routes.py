from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.infrastructure.persistance.database import get_db
from app.interfaces.schemas_simulacion import (
    SimulacionCreate,
    SimulacionResponse,
    SimulacionUpdate,
)
from app.domain.entities.simulacion import SimulacionEntity, EstadoSimulacion, TipoEstrategiaExcedentes
from app.domain.use_cases.simulacion.get_simulacion import GetSimulacion
from app.domain.use_cases.simulacion.list_simulaciones import ListSimulaciones, ListSimulacionesByComunidad, ListSimulacionesByUsuario
from app.domain.use_cases.simulacion.create_simulacion import CreateSimulacion
from app.domain.use_cases.simulacion.update_simulacion import UpdateSimulacion, UpdateEstadoSimulacion
from app.domain.use_cases.simulacion.delete_simulacion import DeleteSimulacion
from app.domain.use_cases.simulacion.motor_simulacion.motor_simulacion import MotorSimulacion
from app.infrastructure.persistance.repository.sqlalchemy_simulacion_repository import SqlAlchemySimulacionRepository
from typing import List
import time
from app.interfaces.schemas_resultado_simulacion import ResultadoSimulacionCreate
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.infrastructure.persistance.repository.sqlalchemy_resultado_simulacion_repository import SqlAlchemyResultadoSimulacionRepository
from app.domain.use_cases.resultado_simulacion.create_resultado_simulacion import CreateResultadoSimulacion
from app.domain.entities.estado_simulacion import EstadoSimulacion

router = APIRouter(prefix="/simulaciones", tags=["simulaciones"])

@router.post("", response_model=SimulacionResponse)
def crear_simulacion(simulacion: SimulacionCreate, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    Crea una nueva simulación para una comunidad energética y programa su procesamiento
    """
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
    
    repo = SqlAlchemySimulacionRepository(db)
    use_case = CreateSimulacion(repo)
    nueva_simulacion = use_case.execute(simulacion_entity)
    
    
    return nueva_simulacion

@router.get("/{id_simulacion}", response_model=SimulacionResponse)
def obtener_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de una simulación por su ID
    """
    repo = SqlAlchemySimulacionRepository(db)
    use_case = GetSimulacion(repo)
    simulacion = use_case.execute(id_simulacion)
    
    if not simulacion:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    return simulacion

@router.get("/comunidad/{id_comunidad}", response_model=List[SimulacionResponse])
def listar_simulaciones_por_comunidad(id_comunidad: int, db: Session = Depends(get_db)):
    """
    Lista todas las simulaciones de una comunidad energética
    """
    repo = SqlAlchemySimulacionRepository(db)
    use_case = ListSimulacionesByComunidad(repo)
    return use_case.execute(id_comunidad)

@router.get("/usuario/{id_usuario}", response_model=List[SimulacionResponse])
def listar_simulaciones_por_usuario(id_usuario: int, db: Session = Depends(get_db)):
    """
    Lista todas las simulaciones creadas por un usuario
    """
    repo = SqlAlchemySimulacionRepository(db)
    use_case = ListSimulacionesByUsuario(repo)
    return use_case.execute(id_usuario)

@router.get("", response_model=List[SimulacionResponse])
def listar_simulaciones(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Lista todas las simulaciones registradas
    """
    repo = SqlAlchemySimulacionRepository(db)
    use_case = ListSimulaciones(repo)
    return use_case.execute(skip, limit)

@router.put("/{id_simulacion}", response_model=SimulacionResponse)
def actualizar_simulacion(id_simulacion: int, simulacion: SimulacionUpdate, db: Session = Depends(get_db)):
    """
    Actualiza los datos de una simulación existente
    """
    # Primero obtenemos la simulación existente
    repo = SqlAlchemySimulacionRepository(db)
    get_use_case = GetSimulacion(repo)
    simulacion_existente = get_use_case.execute(id_simulacion)
    
    if not simulacion_existente:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    # Creamos una nueva entidad con los valores actualizados
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
    
    update_use_case = UpdateSimulacion(repo)
    return update_use_case.execute(id_simulacion, simulacion_entity)

@router.put("/{id_simulacion}/estado", response_model=SimulacionResponse)
def actualizar_estado_simulacion(id_simulacion: int, estado_data: dict, db: Session = Depends(get_db)):
    """
    Actualiza el estado de una simulación existente
    """
    if "estado" not in estado_data:
        raise HTTPException(status_code=400, detail="El campo 'estado' es requerido")
    
    # Validar que el estado sea válido
    try:
        estado = EstadoSimulacion(estado_data["estado"])
    except ValueError:
        raise HTTPException(status_code=400, detail="Estado de simulación no válido")
    
    repo = SqlAlchemySimulacionRepository(db)
    use_case = UpdateEstadoSimulacion(repo)
    
    simulacion = use_case.execute(id_simulacion, estado.value)
    if not simulacion:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    return simulacion

@router.delete("/{id_simulacion}")
def eliminar_simulacion(id_simulacion: int, db: Session = Depends(get_db)):
    """
    Elimina una simulación existente
    """
    repo = SqlAlchemySimulacionRepository(db)
    
    # Primero verificamos que exista
    get_use_case = GetSimulacion(repo)
    simulacion = get_use_case.execute(id_simulacion)
    if not simulacion:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    # Luego la eliminamos
    delete_use_case = DeleteSimulacion(repo)
    delete_use_case.execute(id_simulacion)
    
    return {"mensaje": "Simulación eliminada correctamente"}

@router.post("/{id_simulacion}/ejecutar", status_code=202)
def ejecutar_simulacion(id_simulacion: int, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """
    Ejecuta el motor de simulación avanzado para una simulación existente
    """
    # Verificar que la simulación existe
    repo = SqlAlchemySimulacionRepository(db)
    get_use_case = GetSimulacion(repo)
    simulacion = get_use_case.execute(id_simulacion)
    
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
            # Inicializar el motor de simulación
            motor = MotorSimulacion(db_session)
            
            # Ejecutar la simulación
            print(f"Iniciando motor de simulación avanzado para simulación ID: {sim_id}")
            motor.ejecutar_simulacion(sim_id)
            print(f"Simulación {sim_id} procesada correctamente con el motor avanzado")
        except Exception as e:
            print(f"Error al ejecutar la simulación {sim_id}: {str(e)}")
            # Actualizar el estado a error en caso de fallo
            try:
                repo = SqlAlchemySimulacionRepository(db_session)
                update_estado_use_case = UpdateEstadoSimulacion(repo)
                update_estado_use_case.execute(sim_id, EstadoSimulacion.FALLIDA.value)
            except Exception as update_error:
                print(f"Error adicional al actualizar el estado: {str(update_error)}")
    
    # Actualizar el estado a 'En ejecución'
    update_use_case = UpdateEstadoSimulacion(repo)
    update_use_case.execute(id_simulacion, EstadoSimulacion.EJECUTANDO.value)
    
    # Programar la ejecución en segundo plano
    background_tasks.add_task(ejecutar_motor_simulacion, id_simulacion, db)
    
    return {"mensaje": f"Simulación {id_simulacion} iniciada correctamente", "status": "procesando"}