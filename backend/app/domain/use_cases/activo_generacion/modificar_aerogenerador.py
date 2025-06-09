from fastapi import HTTPException
from app.domain.entities.activo_generacion import ActivoGeneracionEntity
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion
from app.domain.repositories.activo_generacion_repository import ActivoGeneracionRepository
from typing import Dict, Any

def modificar_aerogenerador_use_case(
    id_activo: int,
    activo_datos: ActivoGeneracionEntity,
    repo: ActivoGeneracionRepository
) -> ActivoGeneracionEntity:

    # Verificar que el activo existe
    activo_existente = repo.get_by_id(id_activo)
    if not activo_existente:
        raise HTTPException(status_code=404, detail="Aerogenerador no encontrado")
    
    # Verificar que es un aerogenerador
    if activo_existente.tipo_activo != TipoActivoGeneracion.AEROGENERADOR:
        raise HTTPException(status_code=400, detail="El activo no es un aerogenerador")
    
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
    if activo_datos.curvaPotencia is None:
        activo_datos.curvaPotencia = activo_existente.curvaPotencia
    else:
        # Verificar que la nueva curva de potencia tiene formato JSON válido
        if not isinstance(activo_datos.curvaPotencia, dict):
            raise HTTPException(status_code=400, detail="La curva de potencia debe ser un objeto JSON con formato válido")
    
    # No copiar campos específicos de instalaciones fotovoltaicas
    activo_datos.inclinacionGrados = None
    activo_datos.azimutGrados = None
    activo_datos.tecnologiaPanel = None
    activo_datos.perdidaSistema = None
    activo_datos.posicionMontaje = None
      # Actualizar en la base de datos
    activo_actualizado = repo.update(activo_datos)
    return activo_actualizado