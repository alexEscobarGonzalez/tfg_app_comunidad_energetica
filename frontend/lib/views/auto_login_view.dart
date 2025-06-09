import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/usuario.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/loading_indicators.dart';

class AutoLoginView extends ConsumerStatefulWidget {
  const AutoLoginView({super.key});

  @override
  ConsumerState<AutoLoginView> createState() => _AutoLoginViewState();
}

class _AutoLoginViewState extends ConsumerState<AutoLoginView> {
  bool _isInitializing = true;
  String _status = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _performAutoLogin();
  }

  Future<void> _performAutoLogin() async {
    try {
      setState(() {
        _status = 'Iniciando sesión automáticamente...';
      });

      // Esperar un momento para mostrar la pantalla de carga
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _status = 'Verificando credenciales...';
      });

      await Future.delayed(const Duration(milliseconds: 800));

      // Simular login automático con usuario predefinido
      final testUser = Usuario(
        idUsuario: 1, // ID fijo para test
        nombre: 'Usuario Test TFG',
        correo: 'test@tfg.comunidad.es',
      );

      // Establecer usuario logueado en el provider (sin crear, solo login)
      final userNotifier = ref.read(userProvider.notifier);
      userNotifier.setUser(testUser); // Método directo de login

      setState(() {
        _status = 'Sesión iniciada. Cargando dashboard...';
      });

      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        // Navegar al dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _status = 'Error al iniciar sesión: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título
            const Text(
              'Comunidad Energética',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Trabajo de Fin de Grado - Demo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Indicador de carga
            if (_isInitializing) ...[
              const LoadingSpinner(
                color: Colors.white,
              ),
              
              const SizedBox(height: 20),
              
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Error state
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              
              const SizedBox(height: 20),
              
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: () => _performAutoLogin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Reintentar Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 