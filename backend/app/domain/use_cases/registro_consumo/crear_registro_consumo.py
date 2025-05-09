from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository
from app.domain.repositories.participante_repository import ParticipanteRepository

def crear_registro_consumo_use_case(registro: RegistroConsumoEntity, participante_repo: ParticipanteRepository, registro_repo: RegistroConsumoRepository) -> RegistroConsumoEntity:
    """
    Crea un nuevo registro de consumo energético para un participante
    
    Args:
        registro: Entidad con los datos del nuevo registro de consumo
        participante_repo: Repositorio de participantes
        registro_repo: Repositorio de registros de consumo
        
    Returns:
        RegistroConsumoEntity: La entidad del registro de consumo creada con su ID asignado
        
    Raises:
        HTTPException: Si el participante no existe o si los datos no son válidos
    """
    # Verificar que el participante existe
    participante = participante_repo.get_by_id(registro.idParticipante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Verificar que los datos son válidos
    if registro.consumoEnergia <= 0:
        raise HTTPException(status_code=400, detail="El consumo de energía debe ser un valor positivo")
    
    # Crear el registro de consumo
    return registro_repo.create(registro)