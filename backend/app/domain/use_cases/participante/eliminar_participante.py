from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.infrastructure.persistance.repository.sqlalchemy_participante_repository import SqlAlchemyParticipanteRepository

def eliminar_participante_use_case(id_participante: int, db: Session) -> None:
    """
    Elimina un participante existente
    
    Args:
        id_participante: ID del participante a eliminar
        db: Sesión de base de datos
        
    Raises:
        HTTPException: Si el participante no existe
    """
    repo = SqlAlchemyParticipanteRepository(db)
    
    # Verificar que el participante existe
    participante = repo.get_by_id(id_participante)
    if not participante:
        raise HTTPException(status_code=404, detail="Participante no encontrado")
        
    # Eliminar el participante
    repo.delete(id_participante)