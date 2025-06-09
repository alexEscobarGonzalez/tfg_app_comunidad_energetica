import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/loading_indicators.dart';
import 'login_view.dart';
import 'dashboard_view.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mostrar loading mientras se verifica el estado inicial
    if (authState.isLoading) {
      return const AuthLoadingScreen();
    }

    // Si está autenticado, mostrar dashboard
    if (authState.isLoggedIn && authState.usuario != null) {
      return const DashboardView();
    }

    // Si no está autenticado, mostrar login
    return const LoginView();
  }
}

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.energy_savings_leaf,
                size: 50,
                color: AppColors.textOnPrimary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Loading indicator
            const LoadingSpinner(
              strokeWidth: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Texto de carga
            const Text(
              'Cargando...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 