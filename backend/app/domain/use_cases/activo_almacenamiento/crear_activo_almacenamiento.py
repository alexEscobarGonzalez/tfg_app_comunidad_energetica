from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.domain.entities.activo_almacenamiento import ActivoAlmacenamientoEntity
from app.infrastructure.persistance.repository.sqlalchemy_activo_almacenamiento_repository import SqlAlchemyActivoAlmacenamientoRepository
from app.infrastructure.persistance.repository.sqlalchemy_comunidad_energetica_repository import SqlAlchemyComunidadEnergeticaRepository

def crear_activo_almacenamiento_use_case(activo: ActivoAlmacenamientoEntity, db: Session) -> ActivoAlmacenamientoEntity:
    """
    Crea un nuevo activo de almacenamiento asociado a una comunidad energética
    
    Args:
        activo: Entidad con los datos del nuevo activo de almacenamiento
        db: Sesión de base de datos
        
    Returns:
        ActivoAlmacenamientoEntity: La entidad del activo de almacenamiento creado con su ID asignado
        
    Raises:
        HTTPException: Si la comunidad energética no existe o si los datos no son válidos
    """
    # Verificar que la comunidad energética existe
    comunidad_repo = SqlAlchemyComunidadEnergeticaRepository(db)
    comunidad = comunidad_repo.get_by_id(activo.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Verificar valores positivos para los campos numéricos
    if (activo.capacidadNominal_kWh <= 0 or
        activo.potenciaMaximaCarga_kW <= 0 or
        activo.potenciaMaximaDescarga_kW <= 0):
        raise HTTPException(status_code=400, detail="Los valores de capacidad y potencia deben ser positivos")
    
    # Verificar que eficiencia y profundidad de descarga estén entre 0 y 1
    if (activo.eficienciaCicloCompleto_pct <= 0 or activo.eficienciaCicloCompleto_pct > 1 or
        activo.profundidadDescargaMax_pct <= 0 or activo.profundidadDescargaMax_pct > 1):
        raise HTTPException(status_code=400, detail="Los valores de eficiencia y profundidad de descarga deben estar entre 0 y 1")
    
    # Crear el activo
    activo_repo = SqlAlchemyActivoAlmacenamientoRepository(db)
    return activo_repo.create(activo)