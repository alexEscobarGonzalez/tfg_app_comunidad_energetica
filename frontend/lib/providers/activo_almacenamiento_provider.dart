import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activo_almacenamiento.dart';
import '../services/activo_almacenamiento_api_service.dart';

// Estado para la lista de activos de almacenamiento
class ActivosAlmacenamientoState {
  final List<ActivoAlmacenamiento> activos;
  final bool isLoading;
  final String? error;

  ActivosAlmacenamientoState({
    required this.activos,
    required this.isLoading,
    this.error,
  });

  ActivosAlmacenamientoState copyWith({
    List<ActivoAlmacenamiento>? activos,
    bool? isLoading,
    String? error,
  }) {
    return ActivosAlmacenamientoState(
      activos: activos ?? this.activos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider para gestionar activos de almacenamiento
class ActivosAlmacenamientoNotifier extends StateNotifier<ActivosAlmacenamientoState> {
  ActivosAlmacenamientoNotifier() : super(ActivosAlmacenamientoState(activos: [], isLoading: false));

  // Cargar activos de almacenamiento por comunidad
  Future<void> loadActivosAlmacenamientoByComunidad(int idComunidad) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final activos = await ActivoAlmacenamientoApiService.getActivosAlmacenamientoByComunidad(idComunidad);
      state = state.copyWith(
        activos: activos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear nuevo activo de almacenamiento
  Future<bool> createActivoAlmacenamiento({
    String? nombreDescriptivo,
    required double capacidadNominal_kWh,
    double? potenciaMaximaCarga_kW,
    double? potenciaMaximaDescarga_kW,
    double? eficienciaCicloCompleto_pct,
    double? profundidadDescargaMax_pct,
    required int idComunidadEnergetica,
  }) async {
    try {
      final nuevoActivo = await ActivoAlmacenamientoApiService.createActivoAlmacenamiento(
        nombreDescriptivo: nombreDescriptivo,
        capacidadNominal_kWh: capacidadNominal_kWh,
        potenciaMaximaCarga_kW: potenciaMaximaCarga_kW,
        potenciaMaximaDescarga_kW: potenciaMaximaDescarga_kW,
        eficienciaCicloCompleto_pct: eficienciaCicloCompleto_pct,
        profundidadDescargaMax_pct: profundidadDescargaMax_pct,
        idComunidadEnergetica: idComunidadEnergetica,
      );
      
      // Agregar el nuevo activo a la lista
      final activosActualizados = [...state.activos, nuevoActivo];
      state = state.copyWith(activos: activosActualizados);
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Actualizar activo de almacenamiento
  Future<bool> updateActivoAlmacenamiento({
    required int idActivoAlmacenamiento,
    String? nombreDescriptivo,
    required double capacidadNominal_kWh,
    double? potenciaMaximaCarga_kW,
    double? potenciaMaximaDescarga_kW,
    double? eficienciaCicloCompleto_pct,
    double? profundidadDescargaMax_pct,
  }) async {
    try {
      final activoActualizado = await ActivoAlmacenamientoApiService.updateActivoAlmacenamiento(
        idActivoAlmacenamiento: idActivoAlmacenamiento,
        nombreDescriptivo: nombreDescriptivo,
        capacidadNominal_kWh: capacidadNominal_kWh,
        potenciaMaximaCarga_kW: potenciaMaximaCarga_kW,
        potenciaMaximaDescarga_kW: potenciaMaximaDescarga_kW,
        eficienciaCicloCompleto_pct: eficienciaCicloCompleto_pct,
        profundidadDescargaMax_pct: profundidadDescargaMax_pct,
      );
      
      // Actualizar la lista de activos
      final activosActualizados = state.activos.map((a) {
        return a.idActivoAlmacenamiento == idActivoAlmacenamiento ? activoActualizado : a;
      }).toList();
      
      state = state.copyWith(activos: activosActualizados);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar activo de almacenamiento
  Future<bool> deleteActivoAlmacenamiento(int idActivoAlmacenamiento) async {
    try {
      final success = await ActivoAlmacenamientoApiService.deleteActivoAlmacenamiento(idActivoAlmacenamiento);
      
      if (success) {
        // Remover de la lista
        final activosActualizados = state.activos
            .where((a) => a.idActivoAlmacenamiento != idActivoAlmacenamiento)
            .toList();
        
        state = state.copyWith(activos: activosActualizados);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final activosAlmacenamientoProvider = StateNotifierProvider<ActivosAlmacenamientoNotifier, ActivosAlmacenamientoState>((ref) {
  return ActivosAlmacenamientoNotifier();
});

// Provider para obtener un activo de almacenamiento específico
final activoAlmacenamientoByIdProvider = FutureProvider.family<ActivoAlmacenamiento?, int>((ref, idActivo) async {
  try {
    return await ActivoAlmacenamientoApiService.getActivoAlmacenamiento(idActivo);
  } catch (e) {
    return null;
  }
});

// Provider para estadísticas de activo de almacenamiento
final estadisticasActivoAlmacenamientoProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, idActivo) async {
  try {
    return await ActivoAlmacenamientoApiService.getEstadisticasActivoAlmacenamiento(idActivo);
  } catch (e) {
    return null;
  }
}); 