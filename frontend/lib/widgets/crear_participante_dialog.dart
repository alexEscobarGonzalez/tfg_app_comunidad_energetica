import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/loading_indicators.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/participante_provider.dart';

class CrearParticipanteDialog extends ConsumerStatefulWidget {
  final int idComunidad;
  final String nombreComunidad;

  const CrearParticipanteDialog({
    super.key,
    required this.idComunidad,
    required this.nombreComunidad,
  });

  @override
  ConsumerState<CrearParticipanteDialog> createState() => _CrearParticipanteDialogState();
}

class _CrearParticipanteDialogState extends ConsumerState<CrearParticipanteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _createParticipante(StateSetter setDialogState) async {
    if (!_formKey.currentState!.validate()) return;

    setDialogState(() {
      _isLoading = true;
    });
    
    try {
      // Crear participante usando el provider
      final success = await ref.read(participantesProvider.notifier).createParticipante(
        nombre: _nombreController.text.trim(),
        idComunidadEnergetica: widget.idComunidad,
      );
      
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pop(true); // Cerrar el dialog
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Participante creado con éxito',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception('No se pudo crear el participante');
      }
      
    } catch (e) {
      if (mounted) {
        setDialogState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Container(
            padding: EdgeInsets.all(8.w),
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Agregar Participante',
                        style: AppTextStyles.headline2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 5.w,
                    ),
                  ],
                ),
                
                Divider(height: 16.h),
                SizedBox(height: 16.h),

                // Formulario
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información de la comunidad
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_city, 
                                  color: AppColors.primary, 
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comunidad:',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        widget.nombreComunidad,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Campo nombre
                          _buildFormField(
                            label: 'Nombre del participante',
                            controller: _nombreController,
                            icon: Icons.person,
                            hintText: 'Ejemplo: Juan Pérez García',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un nombre';
                              }
                              if (value.trim().length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              if (value.trim().length > 100) {
                                return 'El nombre no puede exceder 100 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Información adicional
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline, 
                                  color: AppColors.info, 
                                  size: 16.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Solo se requiere el nombre del participante. Información adicional se podrá agregar después desde la vista de detalle.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.info,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Divider(height: 16.h),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar', style: AppTextStyles.button),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _createParticipante(setDialogState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                                child: _isLoading
            ? const ButtonLoadingSpinner()
                            : Text('Agregar', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
} 