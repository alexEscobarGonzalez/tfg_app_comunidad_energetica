from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, Dict, Any
from datetime import date
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion

# Valores permitidos por PVGIS para tecnología de paneles
PVGIS_TECH_CHOICES = ['Unknown', 'crystSi', 'CIS', 'CdTe']


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
    
    @field_validator('tecnologiaPanel')
    def validar_tecnologia_panel(cls, v):
        if v not in PVGIS_TECH_CHOICES:
            raise ValueError(f'La tecnología del panel debe ser uno de: {PVGIS_TECH_CHOICES}')
        return v


class AerogeneradorCreate(ActivoGeneracionBase):
    curvaPotencia: Dict[str, Any]
    
    @field_validator('tipo_activo')
    def validar_tipo_activo(cls, v):
        if v != TipoActivoGeneracion.AEROGENERADOR:
            raise ValueError('El tipo de activo debe ser Aerogenerador')
        return v
        
    @field_validator('curvaPotencia')
    def validar_curva_potencia(cls, v):
        if not isinstance(v, dict):
            raise ValueError('La curva de potencia debe ser un objeto JSON')
        return v


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
    inclinacionGrados: Optional[float] = None
    azimutGrados: Optional[float] = None
    tecnologiaPanel: Optional[str] = None
    perdidaSistema: Optional[float] = None
    posicionMontaje: Optional[str] = None
    curvaPotencia: Optional[Dict[str, Any]] = None
    
    model_config = ConfigDict(from_attributes=True)


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
    
    @field_validator('tecnologiaPanel')
    def validar_tecnologia_panel(cls, v):
        if v is not None and v not in PVGIS_TECH_CHOICES:
            raise ValueError(f'La tecnología del panel debe ser uno de: {PVGIS_TECH_CHOICES}')
        return v


class AerogeneradorUpdate(BaseModel):
    nombreDescriptivo: Optional[str] = None
    costeInstalacion_eur: Optional[float] = Field(None, gt=0)
    vidaUtil_anios: Optional[int] = Field(None, gt=0)
    potenciaNominal_kWp: Optional[float] = Field(None, gt=0)
    curvaPotencia: Optional[Dict[str, Any]] = None