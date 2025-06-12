enum EstadoSimulacion{
  PENDIENTE,
  EJECUTANDO,
  COMPLETADA,
  FALLIDA,
}

extension EstadoSimulacionExtension on EstadoSimulacion {
  String toShortString() {
    switch (this) {
      case EstadoSimulacion.PENDIENTE:
        return 'Pendiente';
      case EstadoSimulacion.EJECUTANDO:
        return 'Ejecutando';
      case EstadoSimulacion.COMPLETADA:
        return 'Completada';
      case EstadoSimulacion.FALLIDA:
        return 'Fallida';
      }
  }

  String toBackendString() {
    return toString().split('.').last;
  }
}

// Función para convertir desde la cadena al enum
EstadoSimulacion estadoSimulacionFromString(String valor) {
  switch (valor.toUpperCase()) {
    case 'PENDIENTE':
      return EstadoSimulacion.PENDIENTE;
    case 'EJECUTANDO':
      return EstadoSimulacion.EJECUTANDO;
    case 'COMPLETADA':
      return EstadoSimulacion.COMPLETADA;
    case 'FALLIDA':
      return EstadoSimulacion.FALLIDA;
    default:
      return EstadoSimulacion.PENDIENTE; // Default fallback
  }
}