from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository

def crear_resultado_activo_almacenamiento_use_case(resultado: ResultadoSimulacionActivoAlmacenamientoEntity, repo: ResultadoSimulacionActivoAlmacenamientoRepository) -> ResultadoSimulacionActivoAlmacenamientoEntity:
    
    # Aquí puedes agregar validaciones si es necesario
    return repo.create(resultado)