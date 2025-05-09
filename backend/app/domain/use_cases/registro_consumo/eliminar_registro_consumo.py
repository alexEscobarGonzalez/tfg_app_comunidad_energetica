from fastapi import HTTPException
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository

def eliminar_registro_consumo_use_case(id_registro: int, repo: RegistroConsumoRepository) -> dict:
    """
    Elimina un registro de consumo existente
    
    Args:
        id_registro: ID del registro de consumo a eliminar
        repo: Repositorio de registros de consumo
        
    Returns:
        dict: Mensaje de confirmación de la eliminación
        
    Raises:
        HTTPException: Si el registro no existe
    """
    # Verificar que el registro existe
    registro_existente = repo.get_by_id(id_registro)
    if not registro_existente:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    # Eliminar el registro
    repo.delete(id_registro)
    
    # Retornar mensaje de confirmación
    return {"mensaje": f"Registro de consumo con ID {id_registro} eliminado correctamente"}