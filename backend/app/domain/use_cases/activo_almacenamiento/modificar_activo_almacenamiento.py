from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

def modificar_activo_almacenamiento_use_case(id_activo: int, activo_datos: ActivoAlmacenamientoEntity, repo: ActivoAlmacenamientoRepository) -> ActivoAlmacenamientoEntity:
    """
    Modifica los datos de un activo de almacenamiento existente
    
    Args:
        id_activo: ID del activo de almacenamiento a modificar
        activo_datos: Nuevos datos para el activo de almacenamiento
        repo: Repositorio de activos de almacenamiento
        
    Returns:
        ActivoAlmacenamientoEntity: Datos actualizados del activo de almacenamiento
        
    Raises:
        HTTPException: Si el activo de almacenamiento no existe o si los datos no son válidos
    """
    # Verificar que el activo existe
    activo_existente = repo.get_by_id(id_activo)
    if not activo_existente:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
    
    # Verificar valores positivos para los campos numéricos
    if (activo_datos.capacidadNominal_kWh <= 0 or
        activo_datos.potenciaMaximaCarga_kW <= 0 or
        activo_datos.potenciaMaximaDescarga_kW <= 0):
        raise HTTPException(status_code=400, detail="Los valores de capacidad y potencia deben ser positivos")
    
    # Verificar que eficiencia y profundidad de descarga estén entre 0 y 1
    if (activo_datos.eficienciaCicloCompleto_pct <= 0 or activo_datos.eficienciaCicloCompleto_pct > 1 or
        activo_datos.profundidadDescargaMax_pct <= 0 or activo_datos.profundidadDescargaMax_pct > 1):
        raise HTTPException(status_code=400, detail="Los valores de eficiencia y profundidad de descarga deben estar entre 0 y 1")
    
    # Mantener el ID y la comunidad energética
    activo_datos.idActivoAlmacenamiento = id_activo
    activo_datos.idComunidadEnergetica = activo_existente.idComunidadEnergetica
    
    # Actualizar en la base de datos
    activo_actualizado = repo.update(activo_datos)
    return activo_actualizado