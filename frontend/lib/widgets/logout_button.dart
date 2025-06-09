import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/user_provider.dart';
import '../views/login_view.dart';

class LogoutButton extends ConsumerWidget {
  final bool showConfirmDialog;
  final String? customText;
  final IconData? customIcon;
  final ButtonStyle? buttonStyle;

  const LogoutButton({
    super.key,
    this.showConfirmDialog = true,
    this.customText,
    this.customIcon,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => _handleLogout(context, ref),
      icon: Icon(
        customIcon ?? Icons.logout,
        color: AppColors.error,
      ),
      tooltip: 'Cerrar sesión',
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    if (showConfirmDialog) {
      final shouldLogout = await _showLogoutConfirmDialog(context);
      if (!shouldLogout) return;
    }

    try {
      // Cerrar sesión
      await ref.read(authProvider.notifier).logout();

      // Navegar al login y limpiar stack de navegación
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );

        // Mostrar mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showLogoutConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.logout,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8.w),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text(
                  'Cerrar sesión',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }
}

// Widget alternativo para usar como menú item
class LogoutMenuItem extends ConsumerWidget {
  const LogoutMenuItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.logout,
          color: AppColors.error,
          size: 20.w,
        ),
      ),
      title: Text(
        'Cerrar sesión',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Salir de la aplicación',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: () => LogoutButton()._handleLogout(context, ref),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.w,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// Widget para mostrar información del usuario logueado
class UserInfoWidget extends ConsumerWidget {
  final bool showLogoutButton;

  const UserInfoWidget({
    super.key,
    this.showLogoutButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;

    if (usuario == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                usuario.nombre.isNotEmpty 
                    ? usuario.nombre[0].toUpperCase()
                    : 'U',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  usuario.correo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Botón de logout
          if (showLogoutButton) ...[
            SizedBox(width: 8.w),
            const LogoutButton(),
          ],
        ],
      ),
    );
  }
} 