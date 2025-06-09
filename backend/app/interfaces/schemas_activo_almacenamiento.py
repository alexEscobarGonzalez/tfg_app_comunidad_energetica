from pydantic import BaseModel, Field, ConfigDict, field_validator
from typing import Optional

class ActivoAlmacenamientoBase(BaseModel):
    nombreDescriptivo: Optional[str] = Field(None, max_length=255, description="Nombre descriptivo del activo de almacenamiento")
    capacidadNominal_kWh: float = Field(gt=0.0, description="Capacidad nominal de la batería en kWh")
    potenciaMaximaCarga_kW: float = Field(gt=0.0, description="Potencia máxima de carga en kW")
    potenciaMaximaDescarga_kW: float = Field(gt=0.0, description="Potencia máxima de descarga en kW")
    eficienciaCicloCompleto_pct: float = Field(gt=0.0, le=100.0, description="Eficiencia del ciclo completo (0-100 %)")
    profundidadDescargaMax_pct: float = Field(gt=0.0, le=100.0, description="Profundidad máxima de descarga (0-100 %)")
    idComunidadEnergetica: int = Field(description="ID de la comunidad energética a la que pertenece")

    @field_validator('eficienciaCicloCompleto_pct', 'profundidadDescargaMax_pct', mode='before')
    def normalize_percentages(cls, v):
        if v > 1:
            return v / 100.0
        return v

class ActivoAlmacenamientoCreate(ActivoAlmacenamientoBase):
    pass

class ActivoAlmacenamientoUpdate(BaseModel):
    nombreDescriptivo: Optional[str] = Field(None, max_length=255, description="Nombre descriptivo del activo de almacenamiento")
    capacidadNominal_kWh: Optional[float] = Field(None, gt=0.0)
    potenciaMaximaCarga_kW: Optional[float] = Field(None, gt=0.0)
    potenciaMaximaDescarga_kW: Optional[float] = Field(None, gt=0.0)
    eficienciaCicloCompleto_pct: Optional[float] = Field(None, gt=0.0, le=100.0)
    profundidadDescargaMax_pct: Optional[float] = Field(None, gt=0.0, le=100.0)

    @field_validator('eficienciaCicloCompleto_pct', 'profundidadDescargaMax_pct', mode='before')
    def normalize_percentages(cls, v):
        if v is None:
            return v
        if v > 1:
            return v / 100.0
        return v

class ActivoAlmacenamientoRead(ActivoAlmacenamientoBase):
    idActivoAlmacenamiento: int
    
    model_config = ConfigDict(from_attributes=True)