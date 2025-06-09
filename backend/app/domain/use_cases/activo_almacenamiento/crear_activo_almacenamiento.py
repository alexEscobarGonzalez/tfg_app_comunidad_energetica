from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.domain.repositories.activo_almacenamiento_repository import ActivoAlmacenamientoRepository
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def crear_activo_almacenamiento_use_case(
    activo: ActivoAlmacenamientoEntity,
    comunidad_repo: ComunidadEnergeticaRepository,
    activo_repo: ActivoAlmacenamientoRepository
) -> ActivoAlmacenamientoEntity:
    # Verificar que la comunidad energética existe
    comunidad = comunidad_repo.get_by_id(activo.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Verificar que la capacidad nominal es positiva (campo requerido)
    if activo.capacidadNominal_kWh <= 0:
        raise HTTPException(status_code=400, detail="La capacidad nominal debe ser positiva")
    
    # Verificar campos opcionales si están presentes
    if activo.potenciaMaximaCarga_kW is not None and activo.potenciaMaximaCarga_kW <= 0:
        raise HTTPException(status_code=400, detail="La potencia máxima de carga debe ser positiva")
    
    if activo.potenciaMaximaDescarga_kW is not None and activo.potenciaMaximaDescarga_kW <= 0:
        raise HTTPException(status_code=400, detail="La potencia máxima de descarga debe ser positiva")
    
    # Verificar eficiencia si está presente (valores ya normalizados por el esquema)
    if activo.eficienciaCicloCompleto_pct is not None and (activo.eficienciaCicloCompleto_pct <= 0 or activo.eficienciaCicloCompleto_pct > 1):
        raise HTTPException(status_code=400, detail="La eficiencia debe estar entre 0 y 100%")
    
    # Verificar profundidad de descarga si está presente (valores ya normalizados por el esquema)
    if activo.profundidadDescargaMax_pct is not None and (activo.profundidadDescargaMax_pct <= 0 or activo.profundidadDescargaMax_pct > 1):
        raise HTTPException(status_code=400, detail="La profundidad de descarga debe estar entre 0 y 100%")
    
    # Crear el activo
    return activo_repo.create(activo)