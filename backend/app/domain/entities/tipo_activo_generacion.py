from enum import Enum

class TipoActivoGeneracion(str, Enum):
    INSTALACION_FOTOVOLTAICA = "Instalación Fotovoltaica"
    AEROGENERADOR = "Aerogenerador"