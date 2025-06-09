import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/participante.dart';
import '../services/participante_api_service.dart';

// Estado para la lista de participantes
class ParticipantesState {
  final List<Participante> participantes;
  final bool isLoading;
  final String? error;

  ParticipantesState({
    required this.participantes,
    required this.isLoading,
    this.error,
  });

  ParticipantesState copyWith({
    List<Participante>? participantes,
    bool? isLoading,
    String? error,
  }) {
    return ParticipantesState(
      participantes: participantes ?? this.participantes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider para gestionar participantes
class ParticipantesNotifier extends StateNotifier<ParticipantesState> {
  ParticipantesNotifier() : super(ParticipantesState(participantes: [], isLoading: false));

  // Cargar participantes por comunidad
  Future<void> loadParticipantesByComunidad(int idComunidad) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final participantes = await ParticipanteApiService.getParticipantesByComunidad(idComunidad);
      state = state.copyWith(
        participantes: participantes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear nuevo participante
  Future<bool> createParticipante({
    required String nombre,
    required int idComunidadEnergetica,
    String? email,
    String? telefono,
    String? direccion,
    String? rol,
  }) async {
    try {
      final nuevoParticipante = await ParticipanteApiService.createParticipante(
        nombre: nombre,
        idComunidadEnergetica: idComunidadEnergetica,
        email: email,
        telefono: telefono,
        direccion: direccion,
        rol: rol,
      );
      
      // Agregar el nuevo participante a la lista
      final participantesActualizados = [...state.participantes, nuevoParticipante];
      state = state.copyWith(participantes: participantesActualizados);
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Actualizar participante
  Future<bool> updateParticipante({
    required int idParticipante,
    required String nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? rol,
  }) async {
    try {
      final participanteActualizado = await ParticipanteApiService.updateParticipante(
        idParticipante: idParticipante,
        nombre: nombre,
        email: email,
        telefono: telefono,
        direccion: direccion,
        rol: rol,
      );
      
      // Actualizar la lista de participantes
      final participantesActualizados = state.participantes.map((p) {
        return p.idParticipante == idParticipante ? participanteActualizado : p;
      }).toList();
      
      state = state.copyWith(participantes: participantesActualizados);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar participante
  Future<bool> deleteParticipante(int idParticipante) async {
    try {
      final success = await ParticipanteApiService.deleteParticipante(idParticipante);
      
      if (success) {
        // Remover de la lista
        final participantesActualizados = state.participantes
            .where((p) => p.idParticipante != idParticipante)
            .toList();
        
        state = state.copyWith(participantes: participantesActualizados);
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
final participantesProvider = StateNotifierProvider<ParticipantesNotifier, ParticipantesState>((ref) {
  return ParticipantesNotifier();
});

// Provider para obtener un participante específico
final participanteByIdProvider = FutureProvider.family<Participante?, int>((ref, idParticipante) async {
  try {
    return await ParticipanteApiService.getParticipante(idParticipante);
  } catch (e) {
    return null;
  }
});

// Provider para estadísticas de participante
final estadisticasParticipanteProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, idParticipante) async {
  try {
    return await ParticipanteApiService.getEstadisticasParticipante(idParticipante);
  } catch (e) {
    return null;
  }
}); 