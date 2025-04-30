from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.infrastructure.persistance.repository.sqlalchemy_registro_consumo_repository import SqlAlchemyRegistroConsumoRepository

def mostrar_registro_consumo_use_case(id_registro: int, db: Session) -> RegistroConsumoEntity:
    """
    Obtiene los detalles de un registro de consumo específico
    
    Args:
        id_registro: ID del registro de consumo a obtener
        db: Sesión de base de datos
        
    Returns:
        RegistroConsumoEntity: La entidad del registro de consumo solicitada
        
    Raises:
        HTTPException: Si el registro no existe
    """
    # Obtener el registro de consumo
    registro_repo = SqlAlchemyRegistroConsumoRepository(db)
    registro = registro_repo.get_by_id(id_registro)
    
    if not registro:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    return registro