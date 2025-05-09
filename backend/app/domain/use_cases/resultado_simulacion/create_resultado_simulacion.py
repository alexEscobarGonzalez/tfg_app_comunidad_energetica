from fastapi import HTTPException
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository

def crear_resultado_simulacion_use_case(resultado: ResultadoSimulacionEntity, repo: ResultadoSimulacionRepository) -> ResultadoSimulacionEntity:
    """
    Crea un nuevo resultado de simulación
    Args:
        resultado: Entidad con los datos del nuevo resultado
        repo: Repositorio de resultados de simulación
    Returns:
        ResultadoSimulacionEntity: La entidad creada con su ID asignado
    """
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(resultado)