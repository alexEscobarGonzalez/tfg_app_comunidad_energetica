from fastapi import HTTPException
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository


def crear_comunidad_energetica_use_case(comunidad: ComunidadEnergeticaEntity, repo: ComunidadEnergeticaRepository) -> ComunidadEnergeticaEntity:
    return repo.create(comunidad)
