from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

def crear_resultado_activo_almacenamiento_use_case(resultado: ResultadoSimulacionActivoAlmacenamientoEntity, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> ResultadoSimulacionActivoAlmacenamientoEntity:
    """
    Crea un nuevo resultado de simulación para activo de almacenamiento
    Args:
        resultado: Entidad con los datos del nuevo resultado
        repo: Repositorio de resultados de simulación de activo de almacenamiento
    Returns:
        ResultadoSimulacionActivoAlmacenamientoEntity: La entidad creada con su ID asignado
    """
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(resultado)