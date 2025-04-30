from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional
from datetime import date
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion

# Esquema base con los campos comunes
class ActivoGeneracionBase(BaseModel):
    nombreDescriptivo: str
    fechaInstalacion: date
    costeInstalacion_eur: float = Field(gt=0)
    vidaUtil_anios: int = Field(gt=0)
    latitud: float
    longitud: float
    potenciaNominal_kWp: float = Field(gt=0)
    idComunidadEnergetica: int
    tipo_activo: TipoActivoGeneracion

# Esquema para instalación fotovoltaica
class InstalacionFotovoltaicaCreate(ActivoGeneracionBase):
    inclinacionGrados: float
    azimutGrados: float
    tecnologiaPanel: str
    perdidaSistema: float
    posicionMontaje: str
    
    @field_validator('tipo_activo')
    def validar_tipo_activo(cls, v):
        if v != TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA:
            raise ValueError('El tipo de activo debe ser Instalación Fotovoltaica')
        return v

# Esquema para aerogenerador
class AerogeneradorCreate(ActivoGeneracionBase):
    curvaPotencia: str
    
    @field_validator('tipo_activo')
    def validar_tipo_activo(cls, v):
        if v != TipoActivoGeneracion.AEROGENERADOR:
            raise ValueError('El tipo de activo debe ser Aerogenerador')
        return v

# Esquema genérico para leer cualquier tipo de activo
class ActivoGeneracionRead(BaseModel):
    idActivoGeneracion: int
    nombreDescriptivo: str
    fechaInstalacion: date
    costeInstalacion_eur: float
    vidaUtil_anios: int
    latitud: float
    longitud: float
    potenciaNominal_kWp: float
    idComunidadEnergetica: int
    tipo_activo: TipoActivoGeneracion
    
    # Campos específicos opcionales
    inclinacionGrados: Optional[float] = None
    azimutGrados: Optional[float] = None
    tecnologiaPanel: Optional[str] = None
    perdidaSistema: Optional[float] = None
    posicionMontaje: Optional[str] = None
    curvaPotencia: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)

# Esquema para actualizar una instalación fotovoltaica
class InstalacionFotovoltaicaUpdate(BaseModel):
    nombreDescriptivo: Optional[str] = None
    costeInstalacion_eur: Optional[float] = Field(None, gt=0)
    vidaUtil_anios: Optional[int] = Field(None, gt=0)
    potenciaNominal_kWp: Optional[float] = Field(None, gt=0)
    inclinacionGrados: Optional[float] = None
    azimutGrados: Optional[float] = None
    tecnologiaPanel: Optional[str] = None
    perdidaSistema: Optional[float] = None
    posicionMontaje: Optional[str] = None

# Esquema para actualizar un aerogenerador
class AerogeneradorUpdate(BaseModel):
    nombreDescriptivo: Optional[str] = None
    costeInstalacion_eur: Optional[float] = Field(None, gt=0)
    vidaUtil_anios: Optional[int] = Field(None, gt=0)
    potenciaNominal_kWp: Optional[float] = Field(None, gt=0)
    curvaPotencia: Optional[str] = None