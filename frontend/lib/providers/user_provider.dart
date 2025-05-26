import 'package:flutter/material.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/models/usuario.dart';
import 'package:frontend/services/usuario_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final usuarioApiServiceProvider = Provider<UsuarioApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UsuarioApiService(apiService);
});

final userProvider = StateNotifierProvider<UserNotifier, Usuario?>((ref) {
  final usuarioApiService = ref.watch(usuarioApiServiceProvider);
  return UserNotifier(usuarioApiService);
});

class UserNotifier extends StateNotifier<Usuario?> {
  final UsuarioApiService _usuarioApiService;

  UserNotifier(this._usuarioApiService) : super(null);

  Future<void> getUser(int id) async {
    try {
      final user = await _usuarioApiService.getUsuario(id);
      state = user;
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> createUser(Usuario usuario, String hashPassword) async {
    try {
      final newUser = await _usuarioApiService.createUsuario(usuario, hashPassword);
      state = newUser;
    } catch (e) {
      print('Error creating user: $e');
    }
  }
}