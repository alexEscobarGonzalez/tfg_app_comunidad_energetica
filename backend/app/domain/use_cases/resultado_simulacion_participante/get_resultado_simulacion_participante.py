from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from typing import Optional

def mostrar_resultado_simulacion_participante_use_case(id_resultado_participante: int, repo: ResultadoSimulacionParticipanteRepository) -> ResultadoSimulacionParticipanteEntity:
    
    resultado = repo.get_by_id(id_resultado_participante)
    if not resultado:
        raise HTTPException(status_code=404, detail="Resultado de simulación de participante no encontrado")
    return resultado
