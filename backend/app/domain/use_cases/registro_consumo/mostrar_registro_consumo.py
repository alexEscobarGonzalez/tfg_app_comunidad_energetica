from fastapi import HTTPException
from app.domain.entities.registro_consumo import RegistroConsumoEntity
from app.domain.repositories.registro_consumo_repository import RegistroConsumoRepository

def mostrar_registro_consumo_use_case(id_registro: int, repo: RegistroConsumoRepository) -> RegistroConsumoEntity:
    
    # Obtener el registro de consumo
    registro = repo.get_by_id(id_registro)
    
    if not registro:
        raise HTTPException(status_code=404, detail="Registro de consumo no encontrado")
    
    return registro