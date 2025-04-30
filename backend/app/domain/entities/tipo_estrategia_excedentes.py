from enum import Enum

class TipoEstrategiaExcedentes(Enum):
    INDIVIDUAL_SIN_EXCEDENTES = "Individual sin excedentes"
    COLECTIVO_SIN_EXCEDENTES = "Colectivo sin excedentes"
    COLECTIVO_SIN_EXCEDENTES_COMPENSACION_INTERNA = "Colectivo sin excedentes con compensación interna"
    INDIVIDUAL_EXCEDENTES_COMPENSACION = "Individual con excedentes y compensación"
    COLECTIVO_EXCEDENTES_COMPENSACION_RED_INTERNA = "Colectivo con excedentes y compensación en red interna"
    COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA = "Colectivo con excedentes y compensación en red externa"
