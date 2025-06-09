from fastapi import HTTPException
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository

def eliminar_registro_consumo_use_case(id_registro: int, repo: RegistroConsumoRepository) -> dict:
    
    # Verificar que el registro existe
    registro_existente = repo.get_by_id(id_registro)
    if not registro_existente:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    # Eliminar el registro
    repo.delete(id_registro)
    
    # Retornar mensaje de confirmación
    return {"mensaje": f"Registro de consumo con ID {id_registro} eliminado correctamente"}