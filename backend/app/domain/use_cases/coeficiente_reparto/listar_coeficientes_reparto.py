from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import List
from app.domain.entities.coeficiente_reparto import CoeficienteRepartoEntity
from app.infrastructure.persistance.repository.sqlalchemy_coeficiente_reparto_repository import SqlAlchemyCoeficienteRepartoRepository
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def listar_coeficientes_reparto_by_participante_use_case(id_participante: int, db: Session) -> List[CoeficienteRepartoEntity]:
    """
    Obtiene todos los coeficientes de reparto asignados a un participante
    
    Args:
        id_participante: ID del participante
        db: Sesión de base de datos
        
    Returns:
        List[CoeficienteRepartoEntity]: Lista de coeficientes de reparto
        
    Raises:
        HTTPException: Si el participante no existe
    """
    # Verificar que el participante existe
    participante_repo = SqlAlchemyParticipanteRepository(db)
    participante = participante_repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
        
    # Buscar los coeficientes de reparto
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    coeficientes = coeficiente_repo.get_by_participante(id_participante)
    
    return coeficientes

def listar_todos_coeficientes_reparto_use_case(db: Session) -> List[CoeficienteRepartoEntity]:
    """
    Obtiene todos los coeficientes de reparto del sistema
    
    Args:
        db: Sesión de base de datos
        
    Returns:
        List[CoeficienteRepartoEntity]: Lista de todos los coeficientes de reparto
    """
    coeficiente_repo = SqlAlchemyCoeficienteRepartoRepository(db)
    return coeficiente_repo.list()