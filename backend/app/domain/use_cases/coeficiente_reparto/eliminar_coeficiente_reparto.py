from fastapi import HTTPException
from app.domain.repositories.coeficiente_reparto_repository import CoeficienteRepartoRepository

def eliminar_coeficiente_reparto_use_case(id_coeficiente: int, repo: CoeficienteRepartoRepository) -> dict:
    """
    Elimina un coeficiente de reparto existente
    
    Args:
        id_coeficiente: ID del coeficiente de reparto a eliminar
        repo: Repositorio de coeficiente de reparto
        
    Returns:
        dict: Mensaje de confirmación de la eliminación
        
    Raises:
        HTTPException: Si el coeficiente de reparto no existe
    """
    # Verificar que el coeficiente existe
    coeficiente_existente = repo.get_by_id(id_coeficiente)
    if not coeficiente_existente:
        raise HTTPException(status_code=404, detail="Coeficiente de reparto no encontrado")
    
    # Eliminar el coeficiente
    repo.delete(id_coeficiente)
    
    # Retornar mensaje de confirmación
    return {"mensaje": f"Coeficiente de reparto con ID {id_coeficiente} eliminado correctamente"}