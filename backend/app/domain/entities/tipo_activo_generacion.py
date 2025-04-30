from enum import Enum

class TipoActivoGeneracion(str, Enum):
    """
    Tipos de activos de generación energética
    """
    INSTALACION_FOTOVOLTAICA = "Instalación Fotovoltaica"
    AEROGENERADOR = "Aerogenerador"