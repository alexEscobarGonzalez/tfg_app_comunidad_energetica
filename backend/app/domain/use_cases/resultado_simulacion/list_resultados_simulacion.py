from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository
from app.domain.entities.resultado_simulacion import ResultadoSimulacionEntity
from typing import List

def listar_resultados_simulacion_use_case(repo: ResultadoSimulacionRepository, skip: int = 0, limit: int = 100) -> List[ResultadoSimulacionEntity]:
    
    return repo.list(skip=skip, limit=limit)