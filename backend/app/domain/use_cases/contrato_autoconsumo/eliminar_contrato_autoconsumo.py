from fastapi import HTTPException
from app.domain.repositories.contrato_autoconsumo_repository import ContratoAutoconsumoRepository

def eliminar_contrato_autoconsumo_use_case(id_contrato: int, repo: ContratoAutoconsumoRepository) -> None:
    """
    Elimina un contrato de autoconsumo existente
    
    Args:
        id_contrato: ID del contrato a eliminar
        repo: Repositorio de contratos de autoconsumo
        
    Raises:
        HTTPException: Si el contrato no existe
    """
    # Verificar que el contrato existe
    contrato = repo.get_by_id(id_contrato)
    if not contrato:
        raise HTTPException(status_code=404, detail="Contrato de autoconsumo no encontrado")
        
    # Eliminar el contrato
    repo.delete(id_contrato)