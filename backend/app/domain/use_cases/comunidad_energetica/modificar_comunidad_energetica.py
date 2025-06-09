from fastapi import HTTPException
from app.domain.entities.comunidad_energetica import ComunidadEnergeticaEntity
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def modificar_comunidad_energetica_use_case(id_comunidad: int, comunidad_datos: ComunidadEnergeticaEntity, repo: ComunidadEnergeticaRepository) -> ComunidadEnergeticaEntity:
    
    # Verificar que la comunidad existe
    comunidad_existente = repo.get_by_id(id_comunidad)
    if not comunidad_existente:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Actualizar los datos manteniendo el ID original
    comunidad_datos.idComunidadEnergetica = id_comunidad
    
    # El ID de usuario no se debe modificar para mantener la propiedad original
    comunidad_datos.idUsuario = comunidad_existente.idUsuario
    
    # Actualizar en la base de datos
    comunidad_actualizada = repo.update(comunidad_datos)
    return comunidad_actualizada