from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository

def modificar_activo_almacenamiento_use_case(id_activo: int, activo_datos: ActivoAlmacenamientoEntity, repo: ActivoAlmacenamientoRepository) -> ActivoAlmacenamientoEntity:
    # Verificar que el activo existe
    activo_existente = repo.get_by_id(id_activo)
    if not activo_existente:
        raise HTTPException(status_code=404, detail="Activo de almacenamiento no encontrado")
    
    # Verificar que la capacidad nominal es positiva (campo requerido)
    if activo_datos.capacidadNominal_kWh <= 0:
        raise HTTPException(status_code=400, detail="La capacidad nominal debe ser positiva")
    
    # Verificar campos opcionales si están presentes
    if activo_datos.potenciaMaximaCarga_kW is not None and activo_datos.potenciaMaximaCarga_kW <= 0:
        raise HTTPException(status_code=400, detail="La potencia máxima de carga debe ser positiva")
    
    if activo_datos.potenciaMaximaDescarga_kW is not None and activo_datos.potenciaMaximaDescarga_kW <= 0:
        raise HTTPException(status_code=400, detail="La potencia máxima de descarga debe ser positiva")
    
    # Verificar eficiencia si está presente (valores ya normalizados por el esquema)
    if activo_datos.eficienciaCicloCompleto_pct is not None and (activo_datos.eficienciaCicloCompleto_pct <= 0 or activo_datos.eficienciaCicloCompleto_pct > 1):
        raise HTTPException(status_code=400, detail="La eficiencia debe estar entre 0 y 100%")
    
    # Verificar profundidad de descarga si está presente (valores ya normalizados por el esquema)
    if activo_datos.profundidadDescargaMax_pct is not None and (activo_datos.profundidadDescargaMax_pct <= 0 or activo_datos.profundidadDescargaMax_pct > 1):
        raise HTTPException(status_code=400, detail="La profundidad de descarga debe estar entre 0 y 100%")
    
    # Mantener el ID y la comunidad energética
    activo_datos.idActivoAlmacenamiento = id_activo
    activo_datos.idComunidadEnergetica = activo_existente.idComunidadEnergetica
    
    # Actualizar en la base de datos
    activo_actualizado = repo.update(activo_datos)
    return activo_actualizado