from enum import Enum, auto

class TipoContrato(str, Enum):
    PVPC = "PVPC"
    MERCADO_LIBRE = "Precio Fijo"