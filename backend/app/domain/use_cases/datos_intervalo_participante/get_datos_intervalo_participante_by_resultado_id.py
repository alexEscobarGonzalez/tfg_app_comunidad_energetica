from typing import List
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository

def get_datos_intervalo_participante_by_resultado_id_use_case(resultado_participante_id: int, repo: DatosIntervaloParticipanteRepository) -> List[DatosIntervaloParticipanteEntity]:
    return repo.get_by_resultado_participante_id(resultado_participante_id)
