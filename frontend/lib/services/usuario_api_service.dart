import 'package:frontend/models/usuario.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final Usuario usuario;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.usuario,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'bearer',
      usuario: Usuario.fromJson(json['usuario']),
    );
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UsuarioApiService {
  final ApiService _apiService;

  UsuarioApiService(this._apiService);

  Future<Usuario> getUsuario(int id) async {
    try {
      final response = await _apiService.get('usuarios/$id');
      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else {
        throw AuthException('Error al obtener usuario', statusCode: response.statusCode);
      }
    } catch (e) {
      throw AuthException('Error de conexión al obtener usuario');
    }
  }

  /// Registro de nuevo usuario
  /// Request: UsuarioCreate { nombre, correo, hashContrasena }
  /// Response: Token { access_token, token_type, usuario }
  Future<TokenResponse> registrarUsuario({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final body = {
        'nombre': nombre.trim(),
        'correo': correo.trim().toLowerCase(),
        'hashContrasena': contrasena, // El backend se encarga del hash
      };

      final response = await _apiService.post('usuarios/', body, auth: false);
      
      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(json.decode(response.body));
        await _apiService.saveToken(tokenResponse.accessToken);
        await _saveUserInfo(tokenResponse.usuario);
        return tokenResponse;
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Error al registrar usuario';
        
        if (response.statusCode == 422) {
          // Error de validación
          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              errorMessage = errorData['detail'][0]['msg'] ?? errorMessage;
            } else if (errorData['detail'] is String) {
              errorMessage = errorData['detail'];
            }
          }
        } else if (response.statusCode == 400) {
          errorMessage = 'El correo ya está registrado';
        }
        
        throw AuthException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Error de conexión. Verifica tu conexión a internet.');
    }
  }

  /// Login de usuario existente
  /// Request: UsuarioLogin { correo, contrasena }
  /// Response: Token { access_token, token_type, usuario }
  Future<TokenResponse> loginUsuario({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final body = {
        'correo': correo.trim().toLowerCase(),
        'contrasena': contrasena, // No hashear aquí, el backend lo maneja
      };

      final response = await _apiService.post('usuarios/login', body, auth: false);
      
      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(json.decode(response.body));
        await _apiService.saveToken(tokenResponse.accessToken);
        await _saveUserInfo(tokenResponse.usuario);
        return tokenResponse;
      } else {
        String errorMessage = 'Credenciales incorrectas';
        
        if (response.statusCode == 422) {
          final errorData = json.decode(response.body);
          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              errorMessage = errorData['detail'][0]['msg'] ?? errorMessage;
            } else if (errorData['detail'] is String) {
              errorMessage = errorData['detail'];
            }
          }
        } else if (response.statusCode == 401 || response.statusCode == 404) {
          errorMessage = 'Correo o contraseña incorrectos';
        }
        
        throw AuthException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Error de conexión. Verifica tu conexión a internet.');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _apiService.removeToken();
    await _clearUserInfo(); // Limpiar también info del usuario
  }

  /// Limpiar información del usuario guardada
  Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  /// Verificar si hay una sesión activa
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtener token actual
  Future<String?> getCurrentToken() async {
    return await _apiService.getToken();
  }

  // Métodos legacy para compatibilidad (DEPRECATED)
  @Deprecated('Usar registrarUsuario en su lugar')
  Future<Usuario> createUsuario(Usuario usuario, String hashPassword) async {
    final tokenResponse = await registrarUsuario(
      nombre: usuario.nombre,
      correo: usuario.correo,
      contrasena: hashPassword,
    );
    return tokenResponse.usuario;
  }

  @Deprecated('Usar loginUsuario en su lugar')
  Future<Usuario> loginUsuarioLegacy(String correo, String hashPassword) async {
    final tokenResponse = await loginUsuario(
      correo: correo,
      contrasena: hashPassword,
    );
    return tokenResponse.usuario;
  }

  // Almacenar información del usuario
  Future<void> _saveUserInfo(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', usuario.idUsuario.toString());
    await prefs.setString('user_name', usuario.nombre);
    await prefs.setString('user_email', usuario.correo);
  }

  // Recuperar información del usuario guardada
  Future<Usuario?> getSavedUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      
      if (userId != null && userName != null && userEmail != null) {
        return Usuario(
          idUsuario: int.parse(userId),
          nombre: userName,
          correo: userEmail,
        );
      }
    } catch (e) {
      print('Error recuperando info del usuario: $e');
    }
    return null;
  }
}