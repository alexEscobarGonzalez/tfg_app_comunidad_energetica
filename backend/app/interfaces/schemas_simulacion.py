from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from app.domain.entities.estado_simulacion import EstadoSimulacion
from app.domain.entities.tipo_estrategia_excedentes import TipoEstrategiaExcedentes

class SimulacionCreate(BaseModel):
    nombreSimulacion: str = Field(..., description="Nombre descriptivo de la simulación")
    fechaInicio: datetime = Field(..., description="Fecha de inicio del periodo a simular")
    fechaFin: datetime = Field(..., description="Fecha de fin del periodo a simular")
    tiempo_medicion: int = Field(..., description="Intervalo de tiempo para la simulación en minutos")
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes = Field(..., description="Estrategia para gestionar excedentes")
    idUsuario_creador: int = Field(..., description="ID del usuario que crea la simulación")
    idComunidadEnergetica: int = Field(..., description="ID de la comunidad energética a simular")

class SimulacionUpdate(BaseModel):
    nombreSimulacion: Optional[str] = Field(None, description="Nombre descriptivo de la simulación")
    fechaInicio: Optional[datetime] = Field(None, description="Fecha de inicio del periodo a simular")
    fechaFin: Optional[datetime] = Field(None, description="Fecha de fin del periodo a simular")
    tiempo_medicion: Optional[int] = Field(None, description="Intervalo de tiempo para la simulación en minutos")
    tipoEstrategiaExcedentes: Optional[TipoEstrategiaExcedentes] = Field(None, description="Estrategia para gestionar excedentes")
    estado: Optional[EstadoSimulacion] = Field(None, description="Estado actual de la simulación")

class SimulacionResponse(BaseModel):
    idSimulacion: int
    nombreSimulacion: str
    fechaInicio: datetime
    fechaFin: datetime
    tiempo_medicion: int
    estado: EstadoSimulacion
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes
    idUsuario_creador: int
    idComunidadEnergetica: int

    class Config:
        from_attributes = True