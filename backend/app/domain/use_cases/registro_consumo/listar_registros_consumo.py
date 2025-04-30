from datetime import datetime
from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def listar_registros_consumo_by_participante_use_case(id_participante: int, db: Session) -> List[RegistroConsumoEntity]:
    """
    Obtiene todos los registros de consumo asociados a un participante específico
    
    Args:
        id_participante: ID del participante
        db: Sesión de base de datos
        
    Returns:
        List[RegistroConsumoEntity]: Lista de entidades de registros de consumo
        
    Raises:
        HTTPException: Si el participante no existe
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Obtener los registros de consumo del participante
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return registro_repo.get_by_participante(id_participante)

def listar_registros_consumo_by_periodo_use_case(fecha_inicio: datetime, fecha_fin: datetime, db: Session) -> List[RegistroConsumoEntity]:
    """
    Obtiene todos los registros de consumo dentro de un período específico
    
    Args:
        fecha_inicio: Fecha inicial del período
        fecha_fin: Fecha final del período
        db: Sesión de base de datos
        
    Returns:
        List[RegistroConsumoEntity]: Lista de entidades de registros de consumo
    """
    # Validar las fechas
    if fecha_inicio > fecha_fin:
        raise HTTPException(status_code=400, detail="La fecha de inicio debe ser anterior a la fecha de fin")
    
    # Obtener los registros en el período
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return registro_repo.get_by_periodo(fecha_inicio, fecha_fin)

def listar_registros_consumo_by_participante_y_periodo_use_case(
    id_participante: int, 
    fecha_inicio: datetime, 
    fecha_fin: datetime, 
    db: Session
) -> List[RegistroConsumoEntity]:
    """
    Obtiene todos los registros de consumo de un participante en un período específico
    
    Args:
        id_participante: ID del participante
        fecha_inicio: Fecha inicial del período
        fecha_fin: Fecha final del período
        db: Sesión de base de datos
        
    Returns:
        List[RegistroConsumoEntity]: Lista de entidades de registros de consumo
        
    Raises:
        HTTPException: Si el participante no existe
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
    
    # Validar las fechas
    if fecha_inicio > fecha_fin:
        raise HTTPException(status_code=400, detail="La fecha de inicio debe ser anterior a la fecha de fin")
    
    # Obtener los registros del participante en el período
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return registro_repo.get_by_participante_y_periodo(id_participante, fecha_inicio, fecha_fin)

def listar_todos_registros_consumo_use_case(db: Session) -> List[RegistroConsumoEntity]:
    """
    Obtiene todos los registros de consumo en el sistema
    
    Args:
        db: Sesión de base de datos
        
    Returns:
        List[RegistroConsumoEntity]: Lista de todas las entidades de registro de consumo
    """
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    return registro_repo.list()