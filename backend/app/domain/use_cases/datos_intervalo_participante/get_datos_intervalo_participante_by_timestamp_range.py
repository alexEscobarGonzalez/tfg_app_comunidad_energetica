from typing import List
from datetime import datetime
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository

def get_datos_intervalo_participante_by_timestamp_range_use_case(
    resultado_participante_id: int,
    start_time: datetime,
    end_time: datetime,
    repo: DatosIntervaloParticipanteRepository
) -> List[DatosIntervaloParticipanteEntity]:
    return repo.get_by_timestamp_range(resultado_participante_id, start_time, end_time)
