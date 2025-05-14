from enum import Enum

class TipoEstrategiaExcedentes(Enum):
    INDIVIDUAL_SIN_EXCEDENTES = "Individual sin excedentes"
    COLECTIVO_SIN_EXCEDENTES = "Colectivo sin excedentes"
    INDIVIDUAL_EXCEDENTES_COMPENSACION = "Individual con excedentes y compensación"
    COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA = "Colectivo con excedentes y compensación en red externa"
