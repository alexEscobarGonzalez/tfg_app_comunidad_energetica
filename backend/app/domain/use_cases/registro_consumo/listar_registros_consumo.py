from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository
from fastapi import HTTPException
from typing import List
from datetime import datetime
from app.domain.entities.registro_consumo import RegistroConsumoEntity

def listar_registros_consumo_by_participante_use_case(id_participante: int, participante_repo: ParticipanteRepository, registro_repo: RegistroConsumoRepository) -> List[RegistroConsumoEntity]:
    
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Obtener los registros de consumo del participante
    return registro_repo.get_by_participante(id_participante)

def listar_registros_consumo_by_periodo_use_case(fecha_inicio: datetime, fecha_fin: datetime, registro_repo: RegistroConsumoRepository) -> List[RegistroConsumoEntity]:
    
    # Validar las fechas
    if fecha_inicio > fecha_fin:
        raise HTTPException(status_code=400, detail="La fecha de inicio debe ser anterior a la fecha de fin")
    
    # Obtener los registros en el período
    return registro_repo.get_by_periodo(fecha_inicio, fecha_fin)

def listar_registros_consumo_by_participante_y_periodo_use_case(
    id_participante: int, 
    fecha_inicio: datetime, 
    fecha_fin: datetime, 
    participante_repo: ParticipanteRepository, 
    registro_repo: RegistroConsumoRepository
) -> List[RegistroConsumoEntity]:
    
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Validar las fechas
    if fecha_inicio > fecha_fin:
        raise HTTPException(status_code=400, detail="La fecha de inicio debe ser anterior a la fecha de fin")
    
    # Obtener los registros del participante en el período
    return registro_repo.get_by_participante_y_periodo(id_participante, fecha_inicio, fecha_fin)

def listar_todos_registros_consumo_use_case(registro_repo: RegistroConsumoRepository) -> List[RegistroConsumoEntity]:
    
    return registro_repo.list()