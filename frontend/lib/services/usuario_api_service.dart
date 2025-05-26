import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:frontend/models/usuario.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';


class UsuarioApiService {
  final ApiService _apiService;

  UsuarioApiService(this._apiService);

  Future<Usuario> getUsuario(int id) async {
    final response = await _apiService.get('usuarios/$id');
    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load usuario');
    }
  }

  Future<Usuario> createUsuario(Usuario usuario, String hashPassword) async {
    final body = {
      'nombre': usuario.nombre,
      'correo': usuario.correo,
      'hashContrasena': hashPassword,
    };

    final response = await _apiService.post('usuarios', body);
    if (response.statusCode == 200) {
      final token = json.decode(response.body)['access_token'];
      await _apiService.saveToken(token);
      final usuarioData = json.decode(response.body)['usuario'];
      return Usuario.fromJson(usuarioData);
    } else {
      throw Exception('Failed to create usuario');
    }
  }
}