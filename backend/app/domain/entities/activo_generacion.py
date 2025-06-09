from dataclasses import dataclass
from typing import Optional, Dict, Any
from datetime import date, datetime
from app.domain.entities.tipo_activo_generacion import TipoActivoGeneracion

@dataclass
class ActivoGeneracionEntity:
    idActivoGeneracion: int = None
    nombreDescriptivo: Optional[str] = None
    fechaInstalacion: date = None
    costeInstalacion_eur: float = None
    vidaUtil_anios: int = None
    latitud: float = None
    longitud: float = None
    potenciaNominal_kWp: float = None
    idComunidadEnergetica: int = None
    tipo_activo: TipoActivoGeneracion = None
    
    inclinacionGrados: Optional[float] = None
    azimutGrados: Optional[float] = None
    tecnologiaPanel: Optional[str] = None
    perdidaSistema: Optional[float] = None
    posicionMontaje: Optional[str] = None

    curvaPotencia: Optional[Dict[str, Any]] = None
    

    esta_activo: Optional[bool] = True
    fecha_eliminacion: Optional[datetime] = None