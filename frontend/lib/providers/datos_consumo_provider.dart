import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/registro_consumo.dart';
import '../models/estadisticas_consumo.dart';
import '../services/datos_consumo_api_service.dart';

// Provider del servicio API
final datosConsumoApiServiceProvider = Provider<DatosConsumoApiService>((ref) {
  return DatosConsumoApiService();
});

// Estado para los datos de consumo
class DatosConsumoState {
  final List<RegistroConsumo> datos;
  final bool isLoading;
  final String? error;
  final EstadisticasConsumo? estadisticas;
  final List<RegistroConsumo> anomalias;

  DatosConsumoState({
    this.datos = const [],
    this.isLoading = false,
    this.error,
    this.estadisticas,
    this.anomalias = const [],
  });

  DatosConsumoState copyWith({
    List<RegistroConsumo>? datos,
    bool? isLoading,
    String? error,
    EstadisticasConsumo? estadisticas,
    List<RegistroConsumo>? anomalias,
  }) {
    return DatosConsumoState(
      datos: datos ?? this.datos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      estadisticas: estadisticas ?? this.estadisticas,
      anomalias: anomalias ?? this.anomalias,
    );
  }
}

// Notifier para gestionar los datos de consumo
class DatosConsumoNotifier extends StateNotifier<DatosConsumoState> {
  final DatosConsumoApiService _apiService;

  DatosConsumoNotifier(this._apiService) : super(DatosConsumoState());

  // Cargar datos de consumo
  Future<void> cargarDatos(
    int idParticipante, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final datos = await _apiService.obtenerDatosConsumo(
        idParticipante,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      
      state = state.copyWith(
        datos: datos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear registro manual
  Future<bool> crearRegistroManual(RegistroConsumo datos) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final nuevoRegistro = await _apiService.crearRegistroConsumo(datos);
      
      final datosActualizados = [...state.datos, nuevoRegistro];
      datosActualizados.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      state = state.copyWith(
        datos: datosActualizados,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Cargar datos desde CSV
  Future<ResultadoCargaDatos?> cargarDatosCSV(
    File archivo,
    int idParticipante,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final resultado = await _apiService.cargarDatosCSV(archivo, idParticipante);
      
      // Recargar datos después de la carga
      await cargarDatos(idParticipante);
      
      return resultado;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Cargar datos desde CSV usando bytes (para web)
  Future<ResultadoCargaDatos?> cargarDatosCSVBytes(
    List<int> bytes,
    int idParticipante,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final resultado = await _apiService.cargarDatosCSVBytes(bytes, idParticipante);
      
      // Recargar datos después de la carga
      await cargarDatos(idParticipante);
      
      return resultado;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }



  // Calcular estadísticas localmente
  void calcularEstadisticas(
    int idParticipante,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    try {
      final estadisticas = _apiService.calcularEstadisticas(
        state.datos,
        idParticipante,
        fechaInicio,
        fechaFin,
      );
      
      state = state.copyWith(estadisticas: estadisticas);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Detectar anomalías localmente
  void detectarAnomalias() {
    try {
      final anomalias = _apiService.detectarAnomalias(state.datos);
      
      state = state.copyWith(anomalias: anomalias);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Actualizar registro
  Future<bool> actualizarRegistro(int id, RegistroConsumo registro) async {
    try {
      final registroActualizado = await _apiService.actualizarRegistro(id, registro);
      
      final datosActualizados = state.datos.map((dato) {
        return dato.idRegistroConsumo == id ? registroActualizado : dato;
      }).toList();
      
      state = state.copyWith(datos: datosActualizados);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar registro
  Future<bool> eliminarRegistro(int id) async {
    try {
      await _apiService.eliminarRegistro(id);
      
      final datosActualizados = state.datos.where((dato) => dato.idRegistroConsumo != id).toList();
      
      state = state.copyWith(datos: datosActualizados);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar todos los registros de un participante
  Future<bool> eliminarTodosRegistrosParticipante(int idParticipante) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.eliminarTodosRegistrosParticipante(idParticipante);
      
      // Limpiar todos los datos del estado
      state = state.copyWith(
        datos: [],
        isLoading: false,
        estadisticas: null,
        anomalias: [],
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Limpiar error
  void limpiarError() {
    state = state.copyWith(error: null);
  }

  // Limpiar datos
  void limpiarDatos() {
    state = DatosConsumoState();
  }
}

// Provider del notifier
final datosConsumoProvider = StateNotifierProvider<DatosConsumoNotifier, DatosConsumoState>((ref) {
  final apiService = ref.watch(datosConsumoApiServiceProvider);
  return DatosConsumoNotifier(apiService);
});

// Provider para filtrar datos por rango de fechas
final datosFiltradosProvider = Provider.family<List<RegistroConsumo>, DateTimeRange?>((ref, rango) {
  final datos = ref.watch(datosConsumoProvider).datos;
  
  if (rango == null) return datos;
  
  return datos.where((dato) {
    return dato.timestamp.isAfter(rango.start.subtract(const Duration(days: 1))) &&
           dato.timestamp.isBefore(rango.end.add(const Duration(days: 1)));
  }).toList();
});

// Clase auxiliar para rango de fechas
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}

// Provider para datos agrupados por día
final datosAgrupadosPorDiaProvider = Provider<Map<DateTime, List<RegistroConsumo>>>((ref) {
  final datos = ref.watch(datosConsumoProvider).datos;
  final Map<DateTime, List<RegistroConsumo>> agrupados = {};
  
  for (final dato in datos) {
    final fecha = DateTime(dato.timestamp.year, dato.timestamp.month, dato.timestamp.day);
    agrupados.putIfAbsent(fecha, () => []).add(dato);
  }
  
  return agrupados;
});

// Provider para estadísticas rápidas
final estadisticasRapidasProvider = Provider<Map<String, dynamic>>((ref) {
  final datos = ref.watch(datosConsumoProvider).datos;
  
  if (datos.isEmpty) {
    return {
      'total': 0.0,
      'promedio': 0.0,
      'maximo': 0.0,
      'minimo': 0.0,
    };
  }
  
  final consumos = datos.map((d) => d.consumoEnergia).toList();
  final total = datos.length.toDouble(); // Cambio: total de registros en lugar de suma de consumos
  final promedio = consumos.fold(0.0, (sum, consumo) => sum + consumo) / consumos.length;
  final maximo = consumos.reduce((a, b) => a > b ? a : b);
  final minimo = consumos.reduce((a, b) => a < b ? a : b);
  
  return {
    'total': total,
    'promedio': promedio,
    'maximo': maximo,
    'minimo': minimo,
  };
});

// Función auxiliar para detectar anomalías (mantenida para compatibilidad)
bool _esAnomalo(RegistroConsumo registro) {
  return registro.consumoEnergia < 0 || registro.consumoEnergia > 50;
} 