from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository

def crear_resultado_activo_generacion_use_case(resultado: ResultadoSimulacionActivoGeneracionEntity, repo: ResultadoSimulacionActivoGeneracionRepository) -> ResultadoSimulacionActivoGeneracionEntity:
    """
    Crea un nuevo resultado de simulación para activo de generación
    Args:
        resultado: Entidad con los datos del nuevo resultado
        repo: Repositorio de resultados de simulación de activo de generación
    Returns:
        ResultadoSimulacionActivoGeneracionEntity: La entidad creada con su ID asignado
    """
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(resultado)