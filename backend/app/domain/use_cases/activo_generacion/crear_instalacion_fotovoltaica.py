from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

def crear_instalacion_fotovoltaica_use_case(activo: ActivoGeneracionEntity, db: Session) -> ActivoGeneracionEntity:
    """
    Crea una nueva instalación fotovoltaica asociada a una comunidad energética
    
    Args:
        activo: Entidad con los datos de la nueva instalación fotovoltaica
        db: Sesión de base de datos
        
    Returns:
        ActivoGeneracionEntity: La entidad de la instalación fotovoltaica creada con su ID asignado
        
    Raises:
        HTTPException: Si la comunidad energética no existe o si faltan datos específicos de la instalación fotovoltaica
    """
    # Verificar que la comunidad energética existe
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = comunidad_repo.get_by_id(activo.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Verificar que sea del tipo correcto
    if activo.tipo_activo != TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        raise HTTPException(status_code=400, detail="El tipo de activo debe ser una instalación fotovoltaica")
    
    # Verificar que se han proporcionado los datos específicos de la instalación fotovoltaica
    if (activo.inclinacionGrados is None or
        activo.azimutGrados is None or
        activo.tecnologiaPanel is None or
        activo.perdidaSistema is None or
        activo.posicionMontaje is None):
        raise HTTPException(status_code=400, detail="Faltan datos específicos de la instalación fotovoltaica")
    
    # Crear el activo
    activo_repo = SqlAlchemyActivoGeneracionRepository(db)
    return activo_repo.create(activo)