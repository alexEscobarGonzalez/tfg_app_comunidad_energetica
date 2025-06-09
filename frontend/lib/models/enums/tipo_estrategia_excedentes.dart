enum TipoEstrategiaExcedentes {
  INDIVIDUAL_SIN_EXCEDENTES,
  COLECTIVO_SIN_EXCEDENTES,
  INDIVIDUAL_EXCEDENTES_COMPENSACION,
  COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA
}

// Extensión para convertir el enum a las cadenas esperadas por el backend
extension TipoEstrategiaExcedentesExtension on TipoEstrategiaExcedentes {
  String toBackendString() {
    switch (this) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual sin excedentes';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo sin excedentes';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual con excedentes y compensación';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo con excedentes y compensación en red externa';
    }
  }

  // Nuevo método para obtener una representación corta
  String toShortString() {
    switch (this) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual s/Exc';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo s/Exc';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual c/Comp';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo c/Comp Ext';
    }
  }
}

// Función para convertir desde la cadena del backend al enum
TipoEstrategiaExcedentes tipoEstrategiaExcedentesFromString(String valor) {
  switch (valor) {
    case 'Individual sin excedentes':
      return TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES;
    case 'Colectivo sin excedentes':
      return TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES;
    case 'Individual con excedentes y compensación':
      return TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION;
    case 'Colectivo con excedentes y compensación en red externa':
      return TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA;
    default:
      throw Exception('Tipo de estrategia de excedentes no reconocido: $valor');
  }
}


