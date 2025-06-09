from enum import Enum

class EstadoSimulacion(str, Enum):
    PENDIENTE = "PENDIENTE"
    EJECUTANDO = "EJECUTANDO"
    COMPLETADA = "COMPLETADA"
    FALLIDA = "FALLIDA"