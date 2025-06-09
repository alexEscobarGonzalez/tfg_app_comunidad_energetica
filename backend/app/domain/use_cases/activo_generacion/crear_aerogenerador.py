from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository
from app.domain.repositories.comunidad_energetica_repository import ComunidadEnergeticaRepository

def crear_aerogenerador_use_case(
    activo: ActivoGeneracionEntity,
    comunidad_repo: ComunidadEnergeticaRepository,
    activo_repo: ActivoGeneracionRepository
) -> ActivoGeneracionEntity:
    # Verificar que la comunidad energética existe
    comunidad = comunidad_repo.get_by_id(activo.idComunidadEnergetica)
    if not comunidad:
        raise HTTPException(status_code=404, detail="Comunidad energética no encontrada")
    
    # Verificar que sea del tipo correcto
    if activo.tipo_activo != TipoActivoGeneracion.AEROGENERADOR:
        raise HTTPException(status_code=400, detail="El tipo de activo debe ser un aerogenerador")
      # Verificar que se han proporcionado los datos específicos del aerogenerador
    if activo.curvaPotencia is None:
        raise HTTPException(status_code=400, detail="Falta la curva de potencia del aerogenerador")
    
    # Verificar que la curva de potencia tiene el formato correcto
    if not isinstance(activo.curvaPotencia, dict):
        raise HTTPException(status_code=400, detail="La curva de potencia debe ser un objeto JSON con formato válido")
    
    # Crear el activo
    return activo_repo.create(activo)