import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/comunidad_energetica_api_service.dart';

// Provider para el servicio de comunidad energética
final comunidadEnergeticaApiServiceProvider = Provider<ComunidadEnergeticaApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ComunidadEnergeticaApiService(apiService);
});

// Provider para la lista de comunidades del usuario actual
final comunidadesUsuarioProvider = FutureProvider.autoDispose<List<ComunidadEnergetica>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) {
    return [];
  }
  
  final comunidadService = ref.watch(comunidadEnergeticaApiServiceProvider);
  return await comunidadService.getComunidadesUsuario(user.idUsuario);
});

// Provider para obtener una comunidad específica por ID
final comunidadDetalleProvider = FutureProvider.family<ComunidadEnergetica, int>((ref, idComunidad) async {
  final comunidadService = ref.watch(comunidadEnergeticaApiServiceProvider);
  return await comunidadService.getComunidadById(idComunidad);
});

// Notifier para gestionar las comunidades energéticas
class ComunidadesNotifier extends StateNotifier<List<ComunidadEnergetica>> {
  final ComunidadEnergeticaApiService _comunidadService;
  
  ComunidadesNotifier(this._comunidadService) : super([]);
  
  Future<void> loadComunidadesUsuario(int idUsuario) async {
    try {
      final comunidades = await _comunidadService.getComunidadesUsuario(idUsuario);
      state = comunidades;
    } catch (e) {
      print('Error cargando comunidades: $e');
      state = [];
    }
  }
  
  Future<ComunidadEnergetica> addComunidad(ComunidadEnergetica comunidad) async {
    try {
      final nuevaComunidad = await _comunidadService.createComunidadEnergetica(comunidad);
      state = [...state, nuevaComunidad];
      return nuevaComunidad;
    } catch (e) {
      print('Error creando comunidad: $e');
      throw e;
    }
  }
  
  Future<ComunidadEnergetica> updateComunidad(int idComunidad, ComunidadEnergetica comunidad) async {
    try {
      final comunidadActualizada = await _comunidadService.updateComunidad(idComunidad, comunidad);
      
      // Actualizar la lista de comunidades
      state = state.map((c) => c.idComunidadEnergetica == idComunidad ? comunidadActualizada : c).toList();
      
      return comunidadActualizada;
    } catch (e) {
      print('Error actualizando comunidad: $e');
      throw e;
    }
  }
  
  Future<void> deleteComunidad(int idComunidad) async {
    try {
      await _comunidadService.deleteComunidad(idComunidad);
      
      // Eliminar la comunidad de la lista
      state = state.where((c) => c.idComunidadEnergetica != idComunidad).toList();
    } catch (e) {
      print('Error eliminando comunidad: $e');
      throw e;
    }
  }
}

// Provider para el notifier de comunidades
final comunidadesNotifierProvider = StateNotifierProvider<ComunidadesNotifier, List<ComunidadEnergetica>>((ref) {
  final comunidadService = ref.watch(comunidadEnergeticaApiServiceProvider);
  return ComunidadesNotifier(comunidadService);
});
