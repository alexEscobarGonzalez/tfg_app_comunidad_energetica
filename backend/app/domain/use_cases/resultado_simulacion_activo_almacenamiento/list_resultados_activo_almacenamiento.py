from app.domain.repositories.resultado_simulacion_activo_almacenamiento_repository import ResultadoSimulacionActivoAlmacenamientoRepository
from app.domain.entities.resultado_simulacion_activo_almacenamiento import ResultadoSimulacionActivoAlmacenamientoEntity
from typing import List

def listar_resultados_activo_almacenamiento_use_case(repo: ResultadoSimulacionActivoAlmacenamientoRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoAlmacenamientoEntity]:
    
    return repo.list(skip=skip, limit=limit)