from enum import Enum

class TipoReparto(Enum):
    """
    Enumeración de los tipos de reparto posibles para los coeficientes de reparto
    """
    REPARTO_FIJO = "Reparto Fijo"
    REPARTO_PROGRAMADO = "Reparto Programado"