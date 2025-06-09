from fastapi import HTTPException
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository

def crear_resultado_simulacion_use_case(resultado: ResultadoSimulacionEntity, repo: ResultadoSimulacionRepository) -> ResultadoSimulacionEntity:
    
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(resultado)