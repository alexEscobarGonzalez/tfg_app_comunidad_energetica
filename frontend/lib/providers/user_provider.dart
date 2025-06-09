import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/models/usuario.dart';
import 'package:frontend/services/usuario_api_service.dart';

final usuarioApiServiceProvider = Provider<UsuarioApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UsuarioApiService(apiService);
});

// Estado de autenticación
class AuthState {
  final Usuario? usuario;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  const AuthState({
    this.usuario,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    Usuario? usuario,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final usuarioApiService = ref.watch(usuarioApiServiceProvider);
  return AuthNotifier(usuarioApiService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final UsuarioApiService _usuarioApiService;

  AuthNotifier(this._usuarioApiService) : super(const AuthState()) {
    _checkInitialAuthState();
  }

  // Verificar si hay sesión activa al inicializar
  Future<void> _checkInitialAuthState() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final isLoggedIn = await _usuarioApiService.isLoggedIn();
      if (isLoggedIn) {
        print('🔍 DEBUG AUTH - Token encontrado, verificando validez...');
        
        // Intentar obtener info del usuario guardada
        final savedUser = await _usuarioApiService.getSavedUserInfo();
        
        if (savedUser != null) {
          print('✅ DEBUG AUTH - Sesión válida encontrada con usuario: ${savedUser.nombre}');
          state = state.copyWith(
            isLoggedIn: true,
            isLoading: false,
            usuario: savedUser,
          );
        } else {
          print('⚠️ DEBUG AUTH - Token válido pero sin info del usuario');
          // Token válido pero sin info del usuario, limpiar sesión
          await _usuarioApiService.logout();
          state = state.copyWith(isLoggedIn: false, isLoading: false);
        }
      } else {
        print('⚠️ DEBUG AUTH - No hay token válido');
        state = state.copyWith(isLoggedIn: false, isLoading: false);
      }
    } catch (e) {
      print('💥 DEBUG AUTH - Error verificando sesión: $e');
      // Si hay error, limpiar sesión
      await _usuarioApiService.logout();
      state = state.copyWith(isLoggedIn: false, isLoading: false);
    }
  }

  // Registro de nuevo usuario
  Future<bool> register({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tokenResponse = await _usuarioApiService.registrarUsuario(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
      );
      
      state = state.copyWith(
        usuario: tokenResponse.usuario,
        isLoading: false,
        isLoggedIn: true,
        error: null,
      );
      
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isLoggedIn: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado. Inténtalo de nuevo.',
        isLoggedIn: false,
      );
      return false;
    }
  }

  // Login de usuario existente
  Future<bool> login({
    required String correo,
    required String contrasena,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tokenResponse = await _usuarioApiService.loginUsuario(
        correo: correo,
        contrasena: contrasena,
      );
      
      state = state.copyWith(
        usuario: tokenResponse.usuario,
        isLoading: false,
        isLoggedIn: true,
        error: null,
      );
      
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isLoggedIn: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado. Inténtalo de nuevo.',
        isLoggedIn: false,
      );
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _usuarioApiService.logout();
    state = const AuthState();
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Establecer usuario directamente (para compatibilidad)
  void setUser(Usuario usuario) {
    state = state.copyWith(
      usuario: usuario,
      isLoggedIn: true,
    );
  }

  // Obtener usuario por ID (método legacy)
  Future<void> getUser(int id) async {
    try {
      final user = await _usuarioApiService.getUsuario(id);
      state = state.copyWith(usuario: user, isLoggedIn: true);
    } catch (e) {
      print('Error fetching user: $e');
      state = state.copyWith(error: 'Error al obtener usuario');
    }
  }

  // Crear usuario (método legacy)
  Future<void> createUser(Usuario usuario, String hashPassword) async {
    try {
      final newUser = await _usuarioApiService.createUsuario(usuario, hashPassword);
      state = state.copyWith(usuario: newUser, isLoggedIn: true);
    } catch (e) {
      print('Error creating user: $e');
      state = state.copyWith(error: 'Error al crear usuario');
    }
  }
}

// Provider legacy para compatibilidad
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

  // Método para establecer usuario directamente (para login automático)
  void setUser(Usuario usuario) {
    state = usuario;
  }
}