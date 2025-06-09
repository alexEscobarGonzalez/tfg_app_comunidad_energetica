from app.domain.repositories.resultado_simulacion_activo_generacion_repository import ResultadoSimulacionActivoGeneracionRepository
from app.domain.entities.resultado_simulacion_activo_generacion import ResultadoSimulacionActivoGeneracionEntity
from typing import List

def listar_resultados_activo_generacion_use_case(repo: ResultadoSimulacionActivoGeneracionRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionActivoGeneracionEntity]:
    
    return repo.list(skip=skip, limit=limit)