from dataclasses import dataclass
from datetime import datetime
from .estado_simulacion import EstadoSimulacion
from .tipo_estrategia_excedentes import TipoEstrategiaExcedentes

@dataclass
class SimulacionEntity:
    idSimulacion: int = None
    nombreSimulacion: str = None
    fechaInicio: datetime = None
    fechaFin: datetime = None
    tiempo_medicion: int = None  
    estado: EstadoSimulacion = EstadoSimulacion.PENDIENTE
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes = None
    idUsuario_creador: int = None
    idComunidadEnergetica: int = None