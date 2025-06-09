from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.resultado_simulacion_participante import ResultadoSimulacionParticipanteEntity
from app.domain.repositories.resultado_simulacion_participante_repository import ResultadoSimulacionParticipanteRepository
from app.domain.repositories.resultado_simulacion_repository import ResultadoSimulacionRepository as ResultadoGlobalRepository # Alias para evitar colisión
from app.domain.repositories.participante_repository import ParticipanteRepository

class CreateResultadoSimulacionParticipante:
    def __init__(self,
                 resultado_participante_repo: ResultadoSimulacionParticipanteRepository,
                 resultado_global_repo: ResultadoGlobalRepository,
                 participante_repo: ParticipanteRepository):
        self.resultado_participante_repo = resultado_participante_repo
        self.resultado_global_repo = resultado_global_repo
        self.participante_repo = participante_repo

    def execute(self, resultado: ResultadoSimulacionParticipanteEntity, db: Session) -> ResultadoSimulacionParticipanteEntity:
        # Validar que existen las entidades relacionadas
        if not self.resultado_global_repo.get_by_id(resultado.idResultadoSimulacion):
             raise HTTPException(status_code=404, detail=f"Resultado global de simulación con ID {resultado.idResultadoSimulacion} no encontrado")
        if not self.participante_repo.get_by_id(resultado.idParticipante):
             raise HTTPException(status_code=404, detail=f"Participante con ID {resultado.idParticipante} no encontrado")

        # Validar que no exista ya un resultado para esta combinación
        existente = self.resultado_participante_repo.get_by_resultado_and_participante(
            resultado.idResultadoSimulacion, resultado.idParticipante
        )
        if existente:
            raise HTTPException(status_code=400, detail="Ya existe un resultado para este participante en esta simulación")

        return self.resultado_participante_repo.create(resultado)

