from fastapi import HTTPException
from app.domain.repositories.simulacion_repository import SimulacionRepository
from app.domain.entities.simulacion import SimulacionEntity
from app.domain.entities.estado_simulacion import EstadoSimulacion

def modificar_simulacion_use_case(simulacion_id: int, simulacion_datos: SimulacionEntity, repo: SimulacionRepository) -> SimulacionEntity:
    """
    Modifica los datos de una simulación existente
    Args:
        simulacion_id: ID de la simulación a modificar
        simulacion_datos: Nuevos datos para la simulación
        repo: Repositorio de simulaciones
    Returns:
        SimulacionEntity: Datos actualizados
    Raises:
        HTTPException: Si la simulación no existe
    """
    simulacion_existente = repo.get_by_id(simulacion_id)
    if not simulacion_existente:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    return repo.update(simulacion_id, simulacion_datos)

def actualizar_estado_simulacion_use_case(simulacion_id: int, nuevo_estado: str, repo: SimulacionRepository) -> SimulacionEntity:
    """
    Actualiza únicamente el estado de una simulación
    Args:
        simulacion_id: ID de la simulación a modificar
        nuevo_estado: Nuevo estado para la simulación (uno de los valores de EstadoSimulacion)
        repo: Repositorio de simulaciones
    Returns:
        SimulacionEntity: Datos actualizados
    Raises:
        HTTPException: Si la simulación no existe
    """
    simulacion_existente = repo.get_by_id(simulacion_id)
    if not simulacion_existente:
        raise HTTPException(status_code=404, detail="Simulación no encontrada")
    
    # Actualizamos solo el estado, manteniendo el resto de datos
    # Convertir el string a enum EstadoSimulacion
    simulacion_existente.estado = EstadoSimulacion(nuevo_estado)
    return repo.update(simulacion_id, simulacion_existente)