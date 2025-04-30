from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.infrastructure.persistance.repository.sqlalchemy_activo_generacion_repository import SqlAlchemyActivoGeneracionRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

def crear_aerogenerador_use_case(activo: ActivoGeneracionEntity, db: Session) -> ActivoGeneracionEntity:
    """
    Crea un nuevo aerogenerador asociado a una comunidad energética
    
    Args:
        activo: Entidad con los datos del nuevo aerogenerador
        db: Sesión de base de datos
        
    Returns:
        ActivoGeneracionEntity: La entidad del aerogenerador creado con su ID asignado
        
    Raises:
        HTTPException: Si la comunidad energética no existe o si faltan datos específicos del aerogenerador
    """
    # Verificar que la comunidad energética existe
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = comunidad_repo.get_by_id(activo.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Verificar que sea del tipo correcto
    if activo.tipo_activo != TipoActivoGeneracion.AEROGENERADOR:
        raise HTTPException(status_code=400, detail="El tipo de activo debe ser un aerogenerador")
    
    # Verificar que se han proporcionado los datos específicos del aerogenerador
    if activo.curvaPotencia is None:
        raise HTTPException(status_code=400, detail="Falta la curva de potencia del aerogenerador")
    
    # Crear el activo
    activo_repo = SqlAlchemyActivoGeneracionRepository(db)
    return activo_repo.create(activo)