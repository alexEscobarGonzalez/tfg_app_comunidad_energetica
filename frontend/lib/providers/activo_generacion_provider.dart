import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activo_generacion.dart';
import '../models/enums/tipo_activo_generacion.dart';
import '../services/activo_generacion_api_service.dart';

// Estado para la lista de activos de generación
class ActivosGeneracionState {
  final List<ActivoGeneracion> activos;
  final bool isLoading;
  final String? error;

  ActivosGeneracionState({
    required this.activos,
    required this.isLoading,
    this.error,
  });

  ActivosGeneracionState copyWith({
    List<ActivoGeneracion>? activos,
    bool? isLoading,
    String? error,
  }) {
    return ActivosGeneracionState(
      activos: activos ?? this.activos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider para gestionar activos de generación
class ActivosGeneracionNotifier extends StateNotifier<ActivosGeneracionState> {
  ActivosGeneracionNotifier() : super(ActivosGeneracionState(activos: [], isLoading: false));

  // Cargar activos de generación por comunidad
  Future<void> loadActivosGeneracionByComunidad(int idComunidad) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final activos = await ActivoGeneracionApiService.getActivosGeneracionByComunidad(idComunidad);
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

  // Crear nuevo activo de generación
  Future<bool> createActivoGeneracion({
    required String nombreDescriptivo,
    required DateTime fechaInstalacion,
    required double costeInstalacion_eur,
    required int vidaUtil_anios,
    required double latitud,
    required double longitud,
    required double potenciaNominal_kWp,
    required int idComunidadEnergetica,
    required TipoActivoGeneracion tipo_activo,
    String? inclinacionGrados,
    String? azimutGrados,
    String? tecnologiaPanel,
    String? perdidaSistema,
    String? posicionMontaje,
    Map<String, dynamic>? curvaPotencia,
  }) async {
    try {
      final nuevoActivo = await ActivoGeneracionApiService.createActivoGeneracion(
        nombreDescriptivo: nombreDescriptivo,
        fechaInstalacion: fechaInstalacion,
        costeInstalacion_eur: costeInstalacion_eur,
        vidaUtil_anios: vidaUtil_anios,
        latitud: latitud,
        longitud: longitud,
        potenciaNominal_kWp: potenciaNominal_kWp,
        idComunidadEnergetica: idComunidadEnergetica,
        tipo_activo: tipo_activo,
        inclinacionGrados: inclinacionGrados,
        azimutGrados: azimutGrados,
        tecnologiaPanel: tecnologiaPanel,
        perdidaSistema: perdidaSistema,
        posicionMontaje: posicionMontaje,
        curvaPotencia: curvaPotencia,
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

  // Actualizar activo de generación
  Future<bool> updateActivoGeneracion({
    required int idActivoGeneracion,
    required String nombreDescriptivo,
    required DateTime fechaInstalacion,
    required double costeInstalacion_eur,
    required int vidaUtil_anios,
    required double latitud,
    required double longitud,
    required double potenciaNominal_kWp,
    required TipoActivoGeneracion tipo_activo,
    String? inclinacionGrados,
    String? azimutGrados,
    String? tecnologiaPanel,
    String? perdidaSistema,
    String? posicionMontaje,
    Map<String, dynamic>? curvaPotencia,
  }) async {
    try {
      final activoActualizado = await ActivoGeneracionApiService.updateActivoGeneracion(
        idActivoGeneracion: idActivoGeneracion,
        nombreDescriptivo: nombreDescriptivo,
        fechaInstalacion: fechaInstalacion,
        costeInstalacion_eur: costeInstalacion_eur,
        vidaUtil_anios: vidaUtil_anios,
        latitud: latitud,
        longitud: longitud,
        potenciaNominal_kWp: potenciaNominal_kWp,
        tipo_activo: tipo_activo,
        inclinacionGrados: inclinacionGrados,
        azimutGrados: azimutGrados,
        tecnologiaPanel: tecnologiaPanel,
        perdidaSistema: perdidaSistema,
        posicionMontaje: posicionMontaje,
        curvaPotencia: curvaPotencia,
      );
      
      // Actualizar la lista de activos
      final activosActualizados = state.activos.map((a) {
        return a.idActivoGeneracion == idActivoGeneracion ? activoActualizado : a;
      }).toList();
      
      state = state.copyWith(activos: activosActualizados);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar activo de generación
  Future<bool> deleteActivoGeneracion(int idActivoGeneracion) async {
    try {
      final success = await ActivoGeneracionApiService.deleteActivoGeneracion(idActivoGeneracion);
      
      if (success) {
        // Remover de la lista
        final activosActualizados = state.activos
            .where((a) => a.idActivoGeneracion != idActivoGeneracion)
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
final activosGeneracionProvider = StateNotifierProvider<ActivosGeneracionNotifier, ActivosGeneracionState>((ref) {
  return ActivosGeneracionNotifier();
});

// Provider para obtener un activo de generación específico
final activoGeneracionByIdProvider = FutureProvider.family<ActivoGeneracion?, int>((ref, idActivo) async {
  try {
    return await ActivoGeneracionApiService.getActivoGeneracion(idActivo);
  } catch (e) {
    return null;
  }
});

// Provider para estadísticas de activo de generación
final estadisticasActivoGeneracionProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, idActivo) async {
  try {
    return await ActivoGeneracionApiService.getEstadisticasActivoGeneracion(idActivo);
  } catch (e) {
    return null;
  }
});

// Provider para datos PVGIS
final datosPVGISProvider = FutureProvider.family<Map<String, dynamic>?, Map<String, dynamic>>((ref, params) async {
  try {
    return await ActivoGeneracionApiService.generarDatosPVGIS(
      latitud: params['latitud'],
      longitud: params['longitud'],
      potenciaNominal_kWp: params['potenciaNominal_kWp'],
      inclinacion: params['inclinacion'],
      azimut: params['azimut'],
    );
  } catch (e) {
    return null;
  }
}); 