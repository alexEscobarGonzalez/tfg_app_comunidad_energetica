from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository

def crear_resultado_activo_generacion_use_case(resultado: ResultadoSimulacionActivoGeneracionEntity, repo: ResultadoSimulacionActivoGeneracionRepository) -> ResultadoSimulacionActivoGeneracionEntity:
    
    return repo.create(resultado)