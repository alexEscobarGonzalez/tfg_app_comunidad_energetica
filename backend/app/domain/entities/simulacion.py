from dataclasses import dataclass
from datetime import date
from .estado_simulacion import EstadoSimulacion
from .tipo_estrategia_excedentes import TipoEstrategiaExcedentes

@dataclass
class SimulacionEntity:
    idSimulacion: int = None
    nombreSimulacion: str = None
    fechaInicio: date = None
    fechaFin: date = None
    tiempo_medicion: int = None  # En minutos
    estado: EstadoSimulacion = EstadoSimulacion.PENDIENTE
    tipoEstrategiaExcedentes: TipoEstrategiaExcedentes = None
    idUsuario_creador: int = None
    idComunidadEnergetica: int = None