from fastapi import HTTPException
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository

def eliminar_resultado_simulacion_participante_use_case(id_resultado_participante: int, repo: ResultadoSimulacionParticipanteRepository) -> dict:
    
    resultado_existente = repo.get_by_id(id_resultado_participante)
    if not resultado_existente:
        raise HTTPException(status_code=404, detail="Resultado de simulación de participante no encontrado")
    repo.delete(id_resultado_participante)
    return {"mensaje": f"Resultado de simulación de participante con ID {id_resultado_participante} eliminado correctamente"}
