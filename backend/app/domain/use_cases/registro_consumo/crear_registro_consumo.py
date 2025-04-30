from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def crear_registro_consumo_use_case(registro: RegistroConsumoEntity, db: Session) -> RegistroConsumoEntity:
    """
    Crea un nuevo registro de consumo energético para un participante
    
    Args:
        registro: Entidad con los datos del nuevo registro de consumo
        db: Sesión de base de datos
        
    Returns:
        RegistroConsumoEntity: La entidad del registro de consumo creada con su ID asignado
        
    Raises:
        HTTPException: Si el participante no existe o si los datos no son válidos
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(registro.idParticipante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Verificar que los datos son válidos
    if registro.consumoEnergia <= 0:
        raise HTTPException(status_code=400, detail="El consumo de energía debe ser un valor positivo")
    
    # Crear el registro de consumo
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return registro_repo.create(registro)