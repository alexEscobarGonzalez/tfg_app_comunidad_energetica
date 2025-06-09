from fastapi import HTTPException
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def mostrar_comunidad_energetica_use_case(id_comunidad: int, repo: ComunidadEnergeticaRepository) -> ComunidadEnergeticaEntity:
    
    comunidad = repo.get_by_id(id_comunidad)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    return comunidad