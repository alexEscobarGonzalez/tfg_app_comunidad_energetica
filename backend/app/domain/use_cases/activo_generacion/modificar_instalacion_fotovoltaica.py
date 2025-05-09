from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository

def modificar_instalacion_fotovoltaica_use_case(
    id_activo: int,
    activo_datos: ActivoGeneracionEntity,
    repo: ActivoGeneracionRepository
) -> ActivoGeneracionEntity:
    """
    Modifica los datos de una instalación fotovoltaica existente
    
    Args:
        id_activo: ID de la instalación fotovoltaica a modificar
        activo_datos: Nuevos datos para la instalación fotovoltaica
        repo: Repositorio de instalaciones fotovoltaicas
        
    Returns:
        ActivoGeneracionEntity: Datos actualizados de la instalación fotovoltaica
        
    Raises:
        HTTPException: Si la instalación fotovoltaica no existe o si no es del tipo correcto
    """
    # Verificar que el activo existe
    activo_existente = repo.get_by_id(id_activo)
    if not activo_existente:
        raise HTTPException(status_code=404, detail="Instalación fotovoltaica no encontrada")
    
    # Verificar que es una instalación fotovoltaica
    if activo_existente.tipo_activo != TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
        raise HTTPException(status_code=400, detail="El activo no es una instalación fotovoltaica")
    
    # Mantener los campos inmutables y el tipo
    activo_datos.idActivoGeneracion = id_activo
    activo_datos.idComunidadEnergetica = activo_existente.idComunidadEnergetica
    activo_datos.fechaInstalacion = activo_existente.fechaInstalacion
    activo_datos.latitud = activo_existente.latitud
    activo_datos.longitud = activo_existente.longitud
    activo_datos.tipo_activo = activo_existente.tipo_activo
    
    # Asignar campos específicos solo si no están vacíos
    if activo_datos.nombreDescriptivo is None:
        activo_datos.nombreDescriptivo = activo_existente.nombreDescriptivo
    if activo_datos.costeInstalacion_eur is None:
        activo_datos.costeInstalacion_eur = activo_existente.costeInstalacion_eur
    if activo_datos.vidaUtil_anios is None:
        activo_datos.vidaUtil_anios = activo_existente.vidaUtil_anios
    if activo_datos.potenciaNominal_kWp is None:
        activo_datos.potenciaNominal_kWp = activo_existente.potenciaNominal_kWp
    if activo_datos.inclinacionGrados is None:
        activo_datos.inclinacionGrados = activo_existente.inclinacionGrados
    if activo_datos.azimutGrados is None:
        activo_datos.azimutGrados = activo_existente.azimutGrados
    if activo_datos.tecnologiaPanel is None:
        activo_datos.tecnologiaPanel = activo_existente.tecnologiaPanel
    if activo_datos.perdidaSistema is None:
        activo_datos.perdidaSistema = activo_existente.perdidaSistema
    if activo_datos.posicionMontaje is None:
        activo_datos.posicionMontaje = activo_existente.posicionMontaje
    
    # No copiar campos específicos de aerogeneradores
    activo_datos.curvaPotencia = None
      # Actualizar en la base de datos
    activo_actualizado = repo.update(activo_datos)
    return activo_actualizado