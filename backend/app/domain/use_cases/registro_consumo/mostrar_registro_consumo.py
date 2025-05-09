from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository

def mostrar_registro_consumo_use_case(id_registro: int, repo: RegistroConsumoRepository) -> RegistroConsumoEntity:
    """
    Obtiene los detalles de un registro de consumo específico
    
    Args:
        id_registro: ID del registro de consumo a obtener
        repo: Repositorio de registro de consumo
        
    Returns:
        RegistroConsumoEntity: La entidad del registro de consumo solicitada
        
    Raises:
        HTTPException: Si el registro no existe
    """
    # Obtener el registro de consumo
    registro = repo.get_by_id(id_registro)
    
    if not registro:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    return registro