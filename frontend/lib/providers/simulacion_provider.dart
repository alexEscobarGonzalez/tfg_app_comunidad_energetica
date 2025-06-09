import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/simulacion.dart';
import 'package:frontend/models/resultado_simulacion.dart';
import 'package:frontend/models/resultado_simulacion_participante.dart';
import 'package:frontend/models/resultado_simulacion_activo_generacion.dart';
import 'package:frontend/models/resultado_simulacion_activo_almacenamiento.dart';
import 'package:frontend/models/enums/estado_simulacion.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import 'package:frontend/services/simulacion_api_service.dart';

// ============================================================================
// PROVIDERS BÁSICOS PARA SIMULACIONES
// ============================================================================

// Provider para las simulaciones de una comunidad
final simulacionesComunidadProvider = FutureProvider.family<List<Simulacion>, int>((ref, idComunidad) async {
  return await SimulacionApiService.obtenerSimulacionesComunidad(idComunidad);
});

// Provider para una simulación específica
final simulacionProvider = FutureProvider.family<Simulacion?, int>((ref, idSimulacion) async {
  return await SimulacionApiService.obtenerSimulacion(idSimulacion);
});

// Provider para el resultado general de una simulación
final resultadoSimulacionProvider = FutureProvider.family<ResultadoSimulacion?, int>((ref, idSimulacion) async {
  return await SimulacionApiService.obtenerResultadoSimulacion(idSimulacion);
});

// Provider para los resultados de participantes
final resultadosParticipantesProvider = FutureProvider.family<List<ResultadoSimulacionParticipante>, int>((ref, idSimulacion) async {
  return await SimulacionApiService.obtenerResultadosParticipantes(idSimulacion);
});

// Provider para los resultados de activos de generación
final resultadosActivosGeneracionProvider = FutureProvider.family<List<ResultadoSimulacionActivoGeneracion>, int>((ref, idSimulacion) async {
  return await SimulacionApiService.obtenerResultadosActivosGeneracion(idSimulacion);
});

// Provider para los resultados de activos de almacenamiento
final resultadosActivosAlmacenamientoProvider = FutureProvider.family<List<ResultadoSimulacionActivoAlmacenamiento>, int>((ref, idSimulacion) async {
  return await SimulacionApiService.obtenerResultadosActivosAlmacenamiento(idSimulacion);
});

// Provider combinado para el dashboard de resultados de simulación
final dashboardSimulacionProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, idSimulacion) async {
  final resultado = await SimulacionApiService.obtenerResultadoSimulacion(idSimulacion);
  final participantes = await SimulacionApiService.obtenerResultadosParticipantes(idSimulacion);
  final activosGeneracion = await SimulacionApiService.obtenerResultadosActivosGeneracion(idSimulacion);
  final activosAlmacenamiento = await SimulacionApiService.obtenerResultadosActivosAlmacenamiento(idSimulacion);

  return {
    'resultado': resultado,
    'participantes': participantes,
    'activosGeneracion': activosGeneracion,
    'activosAlmacenamiento': activosAlmacenamiento,
  };
});

// ============================================================================
// GESTIÓN DE ESTADOS UI PARA SIMULACIONES
// ============================================================================

// Estados de la interfaz de simulación
enum EstadoUISimulacion {
  listado,
  creando,
  configurando,
  simulacionCreada,
  ejecutando,
  completada,
  fallida,
  resultados,
}

// Configuración de estrategias disponibles
class EstrategiaSimulacion {
  final TipoEstrategiaExcedentes tipo;
  final String nombre;
  final String descripcion;
  final String icono;
  final bool recomendada;

  const EstrategiaSimulacion({
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    this.recomendada = false,
  });
}

// Estrategias disponibles según la guía
final estrategiasDisponibles = [
  EstrategiaSimulacion(
    tipo: TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES,
    nombre: "Individual sin excedentes",
    descripcion: "Cada participante gestiona su energía de forma independiente",
    icono: "👤",
  ),
  EstrategiaSimulacion(
    tipo: TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES,
    nombre: "Colectivo sin excedentes",
    descripcion: "Gestión colectiva de la energía sin venta de excedentes",
    icono: "👥",
    recomendada: true,
  ),
  EstrategiaSimulacion(
    tipo: TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION,
    nombre: "Individual con excedentes y compensación",
    descripcion: "Gestión individual con venta de excedentes a la red",
    icono: "💰",
  ),
  EstrategiaSimulacion(
    tipo: TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA,
    nombre: "Colectivo con excedentes y compensación en red externa",
    descripcion: "Gestión colectiva con venta de excedentes a red externa",
    icono: "🌐",
  ),
];

// ============================================================================
// ESTADO DEL FORMULARIO DE SIMULACIÓN
// ============================================================================

class FormularioSimulacionState {
  final String nombre;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int tiempoMedicion;
  final TipoEstrategiaExcedentes? estrategiaSeleccionada;
  final Map<String, dynamic> parametrosAvanzados;
  final List<String> erroresValidacion;
  final bool esValido;
  final bool mostrarParametrosAvanzados;

  FormularioSimulacionState({
    this.nombre = '',
    this.fechaInicio,
    this.fechaFin,
    this.tiempoMedicion = 60,
    this.estrategiaSeleccionada,
    this.parametrosAvanzados = const {},
    this.erroresValidacion = const [],
    this.esValido = false,
    this.mostrarParametrosAvanzados = false,
  });

  FormularioSimulacionState copyWith({
    String? nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? tiempoMedicion,
    TipoEstrategiaExcedentes? estrategiaSeleccionada,
    Map<String, dynamic>? parametrosAvanzados,
    List<String>? erroresValidacion,
    bool? esValido,
    bool? mostrarParametrosAvanzados,
  }) {
    return FormularioSimulacionState(
      nombre: nombre ?? this.nombre,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      tiempoMedicion: tiempoMedicion ?? this.tiempoMedicion,
      estrategiaSeleccionada: estrategiaSeleccionada ?? this.estrategiaSeleccionada,
      parametrosAvanzados: parametrosAvanzados ?? this.parametrosAvanzados,
      erroresValidacion: erroresValidacion ?? this.erroresValidacion,
      esValido: esValido ?? this.esValido,
      mostrarParametrosAvanzados: mostrarParametrosAvanzados ?? this.mostrarParametrosAvanzados,
    );
  }

  // Duración estimada de la simulación
  Duration? get duracionSimulacion {
    if (fechaInicio != null && fechaFin != null) {
      return fechaFin!.difference(fechaInicio!);
    }
    return null;
  }

  // Estimación del tiempo de ejecución
  Duration get tiempoEjecucionEstimado {
    final dias = duracionSimulacion?.inDays ?? 30;
    if (dias <= 30) return Duration(minutes: 1);
    if (dias <= 90) return Duration(minutes: 3);
    if (dias <= 180) return Duration(minutes: 8);
    return Duration(minutes: 20);
  }
}

// Notifier para el formulario de simulación con validaciones mejoradas
class FormularioSimulacionNotifier extends StateNotifier<FormularioSimulacionState> {
  FormularioSimulacionNotifier() : super(FormularioSimulacionState());

  void actualizarNombre(String nombre) {
    state = state.copyWith(nombre: nombre.trim());
    _validarFormulario();
  }

  void actualizarFechaInicio(DateTime fechaInicio) {
    state = state.copyWith(fechaInicio: fechaInicio);
    _validarFormulario();
  }

  void actualizarFechaFin(DateTime fechaFin) {
    state = state.copyWith(fechaFin: fechaFin);
    _validarFormulario();
  }

  void actualizarTiempoMedicion(int tiempoMedicion) {
    state = state.copyWith(tiempoMedicion: tiempoMedicion);
    _validarFormulario();
  }

  void actualizarEstrategia(TipoEstrategiaExcedentes estrategia) {
    state = state.copyWith(estrategiaSeleccionada: estrategia);
    _validarFormulario();
  }

  void actualizarParametroAvanzado(String clave, dynamic valor) {
    final nuevosParametros = Map<String, dynamic>.from(state.parametrosAvanzados);
    nuevosParametros[clave] = valor;
    state = state.copyWith(parametrosAvanzados: nuevosParametros);
  }

  void toggleParametrosAvanzados() {
    state = state.copyWith(
      mostrarParametrosAvanzados: !state.mostrarParametrosAvanzados,
    );
  }

  void configurarPeriodoRapido(String tipo) {
    final ahora = DateTime.now();
    DateTime inicio, fin;

    switch (tipo) {
      case 'semana':
        inicio = ahora.subtract(Duration(days: 7));
        fin = ahora;
        break;
      case 'mes':
        inicio = ahora.subtract(Duration(days: 30));
        fin = ahora;
        break;
      case 'trimestre':
        inicio = ahora.subtract(Duration(days: 90));
        fin = ahora;
        break;
      case 'año':
        inicio = ahora.subtract(Duration(days: 365));
        fin = ahora;
        break;
      default:
        return;
    }

    state = state.copyWith(fechaInicio: inicio, fechaFin: fin);
    _validarFormulario();
  }

  List<String> _validarSimulacion() {
    final errores = <String>[];

    // Validar nombre
    if (state.nombre.isEmpty) {
      errores.add("El nombre de la simulación es obligatorio");
    } else if (state.nombre.length < 3) {
      errores.add("El nombre debe tener al menos 3 caracteres");
    }

    // Validar fechas
    if (state.fechaInicio == null) {
      errores.add("La fecha de inicio es obligatoria");
    }
    if (state.fechaFin == null) {
      errores.add("La fecha de fin es obligatoria");
    }

    if (state.fechaInicio != null && state.fechaFin != null) {
      if (!state.fechaFin!.isAfter(state.fechaInicio!)) {
        errores.add("La fecha de fin debe ser posterior a la fecha de inicio");
      }

      final diferenciaDias = state.fechaFin!.difference(state.fechaInicio!).inDays;
      if (diferenciaDias > 365) {
        errores.add("El periodo de simulación no debe exceder 1 año");
      }
      if (diferenciaDias < 1) {
        errores.add("El periodo mínimo de simulación es 1 día");
      }
    }

    // Validar tiempo de medición
    if (![15, 30, 60].contains(state.tiempoMedicion)) {
      errores.add("El tiempo de medición debe ser 15, 30 o 60 minutos");
    }

    // Validar estrategia
    if (state.estrategiaSeleccionada == null) {
      errores.add("Debe seleccionar una estrategia de excedentes");
    }

    return errores;
  }

  void _validarFormulario() {
    final errores = _validarSimulacion();
    state = state.copyWith(
      erroresValidacion: errores,
      esValido: errores.isEmpty,
    );
  }

  void resetear() {
    state = FormularioSimulacionState();
  }

  // Crear simulación con el estado actual
  Simulacion crearSimulacion(int idUsuario, int idComunidad) {
    if (!state.esValido) {
      throw Exception('Formulario no válido');
    }

    return Simulacion(
      idSimulacion: 0, // Se asigna en el backend
      nombreSimulacion: state.nombre,
      fechaInicio: state.fechaInicio!,
      fechaFin: state.fechaFin!,
      tiempo_medicion: state.tiempoMedicion,
      estado: EstadoSimulacion.PENDIENTE,
      tipoEstrategiaExcedentes: state.estrategiaSeleccionada!,
      idUsuario_creador: idUsuario,
      idComunidadEnergetica: idComunidad,
    );
  }
}

// Provider para el formulario de simulación
final formularioSimulacionProvider = StateNotifierProvider<FormularioSimulacionNotifier, FormularioSimulacionState>((ref) {
  return FormularioSimulacionNotifier();
});

// ============================================================================
// GESTIÓN DEL FLUJO DE SIMULACIÓN
// ============================================================================

class GestorSimulacionState {
  final EstadoUISimulacion estadoActual;
  final Simulacion? simulacionActual;
  final String? mensajeEstado;
  final double progreso;
  final List<String> logs;
  final Duration? tiempoRestanteEstimado;
  final Map<String, dynamic>? datosResultados;

  GestorSimulacionState({
    this.estadoActual = EstadoUISimulacion.listado,
    this.simulacionActual,
    this.mensajeEstado,
    this.progreso = 0.0,
    this.logs = const [],
    this.tiempoRestanteEstimado,
    this.datosResultados,
  });

  GestorSimulacionState copyWith({
    EstadoUISimulacion? estadoActual,
    Simulacion? simulacionActual,
    String? mensajeEstado,
    double? progreso,
    List<String>? logs,
    Duration? tiempoRestanteEstimado,
    Map<String, dynamic>? datosResultados,
  }) {
    return GestorSimulacionState(
      estadoActual: estadoActual ?? this.estadoActual,
      simulacionActual: simulacionActual ?? this.simulacionActual,
      mensajeEstado: mensajeEstado ?? this.mensajeEstado,
      progreso: progreso ?? this.progreso,
      logs: logs ?? this.logs,
      tiempoRestanteEstimado: tiempoRestanteEstimado ?? this.tiempoRestanteEstimado,
      datosResultados: datosResultados ?? this.datosResultados,
    );
  }
}

class GestorSimulacionNotifier extends StateNotifier<GestorSimulacionState> {
  GestorSimulacionNotifier() : super(GestorSimulacionState());
  
  Timer? _timerMonitoreo;
  DateTime? _inicioEjecucion;

  // Iniciar el flujo de creación de simulación
  void iniciarCreacion() {
    state = state.copyWith(
      estadoActual: EstadoUISimulacion.creando,
      mensajeEstado: "Configurando nueva simulación",
    );
  }

  // Crear simulación (solo crear, sin ejecutar)
  Future<bool> crearSimulacion(Simulacion simulacion) async {
    try {
      // Crear simulación
      state = state.copyWith(
        estadoActual: EstadoUISimulacion.configurando,
        mensajeEstado: "Creando simulación en el servidor...",
        progreso: 0.1,
      );

      final simulacionCreada = await SimulacionApiService.crearSimulacion(simulacion);
      if (simulacionCreada == null) {
        _establecerError("Error al crear la simulación en el servidor");
        return false;
      }

      state = state.copyWith(
        estadoActual: EstadoUISimulacion.simulacionCreada,
        simulacionActual: simulacionCreada,
        mensajeEstado: "Simulación creada exitosamente. Lista para ejecutar.",
        progreso: 0.0,
      );

      return true;

    } catch (e) {
      _establecerError("Error inesperado: $e");
      return false;
    }
  }

  // Ejecutar una simulación ya creada
  Future<bool> ejecutarSimulacion() async {
    if (state.simulacionActual == null) {
      _establecerError("No hay simulación para ejecutar");
      return false;
    }

    try {
      state = state.copyWith(
        estadoActual: EstadoUISimulacion.configurando,
        mensajeEstado: "Iniciando ejecución de la simulación...",
        progreso: 0.3,
      );

      final exitoEjecucion = await SimulacionApiService.ejecutarSimulacion(state.simulacionActual!.idSimulacion);
      if (!exitoEjecucion) {
        _establecerError("Error al iniciar la ejecución de la simulación");
        return false;
      }

      // Iniciar monitoreo
      _iniciarMonitoreoCompleto(state.simulacionActual!.idSimulacion);
      return true;

    } catch (e) {
      _establecerError("Error inesperado: $e");
      return false;
    }
  }

  // Crear y ejecutar simulación automáticamente (mantener para compatibilidad)
  Future<bool> crearYEjecutarSimulacion(Simulacion simulacion) async {
    try {
      // Fase 1: Crear simulación
      state = state.copyWith(
        estadoActual: EstadoUISimulacion.configurando,
        mensajeEstado: "Creando simulación en el servidor...",
        progreso: 0.1,
      );

      final simulacionCreada = await SimulacionApiService.crearSimulacion(simulacion);
      if (simulacionCreada == null) {
        _establecerError("Error al crear la simulación en el servidor");
        return false;
      }

      state = state.copyWith(
        simulacionActual: simulacionCreada,
        mensajeEstado: "Simulación creada. Iniciando ejecución...",
        progreso: 0.3,
      );

      // Pequeña pausa para UX
      await Future.delayed(Duration(milliseconds: 500));

      // Fase 2: Ejecutar simulación
      final exitoEjecucion = await SimulacionApiService.ejecutarSimulacion(simulacionCreada.idSimulacion);
      if (!exitoEjecucion) {
        _establecerError("Error al iniciar la ejecución de la simulación");
        return false;
      }

      // Fase 3: Iniciar monitoreo
      _iniciarMonitoreoCompleto(simulacionCreada.idSimulacion);
      return true;

    } catch (e) {
      _establecerError("Error inesperado: $e");
      return false;
    }
  }

  // Monitoreo completo de la simulación
  void _iniciarMonitoreoCompleto(int idSimulacion) {
    _inicioEjecucion = DateTime.now();
    
    // NO cambiar simulacionActual aquí - mantener la simulación creada
    state = state.copyWith(
      estadoActual: EstadoUISimulacion.ejecutando,
      mensajeEstado: "El motor de simulación está procesando los datos...",
      progreso: 0.4,
      logs: ["Simulación iniciada correctamente"],
    );

    _timerMonitoreo = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _actualizarEstadoSimulacion(idSimulacion);
    });
  }

  Future<void> _actualizarEstadoSimulacion(int idSimulacion) async {
    try {
      // Obtener estado actual de la simulación
      final simulacionActual = await SimulacionApiService.obtenerSimulacion(idSimulacion);
      if (simulacionActual == null) return;

      // Obtener progreso si está disponible
      final datosProgreso = await SimulacionApiService.obtenerProgresoSimulacion(idSimulacion);
      
      final nuevoProgreso = datosProgreso?['progreso']?.toDouble() ?? state.progreso;
      final nuevosLogs = List<String>.from(state.logs);
      
      // Agregar logs del servidor si existen
      if (datosProgreso?['logs'] != null) {
        final logsServidor = List<String>.from(datosProgreso!['logs']);
        for (final log in logsServidor) {
          if (!nuevosLogs.contains(log)) {
            nuevosLogs.add(log);
          }
        }
      }

      // Calcular tiempo restante estimado
      Duration? tiempoRestante;
      if (_inicioEjecucion != null && nuevoProgreso > 0.4) {
        final tiempoTranscurrido = DateTime.now().difference(_inicioEjecucion!);
        final tiempoTotal = Duration(
          milliseconds: (tiempoTranscurrido.inMilliseconds / (nuevoProgreso - 0.4) * 0.6).round(),
        );
        tiempoRestante = tiempoTotal - tiempoTranscurrido;
      }

      state = state.copyWith(
        simulacionActual: simulacionActual,
        progreso: nuevoProgreso,
        logs: nuevosLogs,
        tiempoRestanteEstimado: tiempoRestante,
      );

      // Verificar estado final
      if (simulacionActual.estado == EstadoSimulacion.COMPLETADA) {
        _detenerMonitoreo();
        await _cargarResultados(idSimulacion);
        state = state.copyWith(
          estadoActual: EstadoUISimulacion.completada,
          mensajeEstado: "Simulación completada exitosamente",
          progreso: 1.0,
        );
      } else if (simulacionActual.estado == EstadoSimulacion.FALLIDA) {
        _detenerMonitoreo();
        _establecerError("La simulación falló durante la ejecución");
      }

    } catch (e) {
      _agregarLog("Error actualizando estado: $e");
    }
  }

  // Cargar todos los resultados de la simulación
  Future<void> _cargarResultados(int idSimulacion) async {
    try {
      final resultado = await SimulacionApiService.obtenerResultadoSimulacion(idSimulacion);
      final resultadosParticipantes = await SimulacionApiService.obtenerResultadosParticipantes(idSimulacion);
      final resultadosActivosGen = await SimulacionApiService.obtenerResultadosActivosGeneracion(idSimulacion);
      final resultadosActivosAlm = await SimulacionApiService.obtenerResultadosActivosAlmacenamiento(idSimulacion);

      state = state.copyWith(
        datosResultados: {
          'resultado': resultado,
          'participantes': resultadosParticipantes,
          'activosGeneracion': resultadosActivosGen,
          'activosAlmacenamiento': resultadosActivosAlm,
        },
      );
    } catch (e) {
      _agregarLog("Error cargando resultados: $e");
    }
  }

  // Cancelar simulación en ejecución
  Future<bool> cancelarSimulacion() async {
    if (state.simulacionActual == null) return false;

    try {
      final exito = await SimulacionApiService.cancelarSimulacion(state.simulacionActual!.idSimulacion);
      if (exito) {
        _detenerMonitoreo();
        state = state.copyWith(
          estadoActual: EstadoUISimulacion.listado,
          mensajeEstado: "Simulación cancelada por el usuario",
        );
        return true;
      }
      return false;
    } catch (e) {
      _agregarLog("Error cancelando simulación: $e");
      return false;
    }
  }

  // Navegar a los resultados
  void verResultados() {
    if (state.estadoActual == EstadoUISimulacion.completada) {
      state = state.copyWith(estadoActual: EstadoUISimulacion.resultados);
    }
  }

  // Volver al listado
  void volverAListado() {
    _detenerMonitoreo();
    state = state.copyWith(
      estadoActual: EstadoUISimulacion.listado,
      simulacionActual: null,
      mensajeEstado: null,
      progreso: 0.0,
      logs: [],
      tiempoRestanteEstimado: null,
      datosResultados: null,
    );
  }

  void _establecerError(String mensaje) {
    _detenerMonitoreo();
    state = state.copyWith(
      estadoActual: EstadoUISimulacion.fallida,
      mensajeEstado: mensaje,
    );
    _agregarLog("ERROR: $mensaje");
  }

  void _agregarLog(String mensaje) {
    final nuevosLogs = List<String>.from(state.logs);
    final timestamp = DateTime.now().toString().substring(11, 19);
    nuevosLogs.add("$timestamp: $mensaje");
    state = state.copyWith(logs: nuevosLogs);
  }

  void _detenerMonitoreo() {
    _timerMonitoreo?.cancel();
    _timerMonitoreo = null;
    _inicioEjecucion = null;
  }

  @override
  void dispose() {
    _detenerMonitoreo();
    super.dispose();
  }
}

// Provider para el gestor de simulación
final gestorSimulacionProvider = StateNotifierProvider<GestorSimulacionNotifier, GestorSimulacionState>((ref) {
  return GestorSimulacionNotifier();
});

// ============================================================================
// PROVIDERS DE CONVENIENCIA
// ============================================================================

// Provider para obtener estrategias disponibles
final estrategiasSimulacionProvider = Provider<List<EstrategiaSimulacion>>((ref) {
  return estrategiasDisponibles;
});

// Provider para estadísticas del dashboard de simulaciones
final estadisticasSimulacionProvider = FutureProvider.family<Map<String, int>, int>((ref, idComunidad) async {
  final simulaciones = await SimulacionApiService.obtenerSimulacionesComunidad(idComunidad);
  
  return {
    'total': simulaciones.length,
    'ejecutando': simulaciones.where((s) => s.estado == EstadoSimulacion.EJECUTANDO).length,
    'completadas': simulaciones.where((s) => s.estado == EstadoSimulacion.COMPLETADA).length,
    'pendientes': simulaciones.where((s) => s.estado == EstadoSimulacion.PENDIENTE).length,
    'fallidas': simulaciones.where((s) => s.estado == EstadoSimulacion.FALLIDA).length,
  };
});

// Provider para las simulaciones más recientes
final simulacionesRecientesProvider = FutureProvider.family<List<Simulacion>, int>((ref, idComunidad) async {
  final simulaciones = await SimulacionApiService.obtenerSimulacionesComunidad(idComunidad);
  simulaciones.sort((a, b) => b.fechaFin.compareTo(a.fechaFin));
  return simulaciones.take(3).toList();
}); 