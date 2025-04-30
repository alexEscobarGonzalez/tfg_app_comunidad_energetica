from enum import Enum, auto

class TipoContrato(str, Enum):
    """
    Tipos de contrato de autoconsumo disponibles
    """
    PVPC = "PVPC"
    MERCADO_LIBRE = "Precio Fijo"