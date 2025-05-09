from typing import List
from app.domain.entities.datos_intervalo_participante import DatosIntervaloParticipanteEntity
from app.domain.repositories.datos_intervalo_participante_repository import DatosIntervaloParticipanteRepository

def create_bulk_datos_intervalo_participante_use_case(datos_list: List[DatosIntervaloParticipanteEntity], repo: DatosIntervaloParticipanteRepository) -> List[DatosIntervaloParticipanteEntity]:
    return repo.create_bulk(datos_list)
