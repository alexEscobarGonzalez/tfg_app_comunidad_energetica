import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../providers/participante_provider.dart';
import '../models/comunidad_energetica.dart';
import '../models/enums/tipo_estrategia_excedentes.dart';

class ComunidadContentView extends ConsumerStatefulWidget {
  const ComunidadContentView({super.key});

  @override
  ConsumerState<ComunidadContentView> createState() => _ComunidadContentViewState();
}

class _ComunidadContentViewState extends ConsumerState<ComunidadContentView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TipoEstrategiaExcedentes _tipoEstrategiaSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _latitudController = TextEditingController();
    _longitudController = TextEditingController();
    _tipoEstrategiaSeleccionada = TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  void _initializeControllers(ComunidadEnergetica comunidad) {
    _nombreController.text = comunidad.nombre;
    _latitudController.text = comunidad.latitud.toString();
    _longitudController.text = comunidad.longitud.toString();
    _tipoEstrategiaSeleccionada = comunidad.tipoEstrategiaExcedentes;
  }

  String _getStrategyDisplayName(TipoEstrategiaExcedentes tipo) {
    switch (tipo) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual sin Excedentes';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo sin Excedentes';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual con Compensación';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo con Compensación Externa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);

    if (comunidadSeleccionada == null) {
      return _buildNoCommunitySelected();
    }

    return Column(
      children: [
        // Header con título y botón
        _buildHeader(comunidadSeleccionada),
        
        // Grid con información
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: _buildInfoGrid(comunidadSeleccionada),
          ),
        ),
      ],
    );
  }

  Widget _buildNoCommunitySelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No hay comunidad seleccionada',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Selecciona una comunidad desde el menú superior',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ComunidadEnergetica comunidad) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(2.r),
          bottomRight: Radius.circular(2.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de la Comunidad',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  comunidad.nombre,
                  style: AppTextStyles.tabDescription
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showEditDialog(context, comunidad);
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: Text('Modificar', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(ComunidadEnergetica comunidad) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      children: [
        _buildInfoCard(
          'Nombre',
          comunidad.nombre,
          Icons.location_city,
          AppColors.primary,
        ),
        _buildInfoCard(
          'Latitud',
          '${comunidad.latitud.toStringAsFixed(4)}°',
          Icons.my_location,
          AppColors.info,
        ),
        _buildInfoCard(
          'Longitud',
          '${comunidad.longitud.toStringAsFixed(4)}°',
          Icons.place,
          AppColors.warning,
        ),
        _buildInfoCard(
          'Usuario',
          '#${comunidad.idUsuario}',
          Icons.person,
          AppColors.success,
        ),
        _buildInfoCard(
          'Estrategia',
          _getStrategyDisplayName(comunidad.tipoEstrategiaExcedentes),
          Icons.settings,
          AppColors.primary,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(icon, color: color, size: 10.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: isFullWidth ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ComunidadEnergetica comunidad) {
    // Inicializar controladores con los valores actuales
    _initializeControllers(comunidad);
    
    // Cargar participantes de la comunidad para las validaciones
    ref.read(participantesProvider.notifier).loadParticipantesByComunidad(comunidad.idComunidadEnergetica);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Modificar Comunidad',
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
                            // Nombre
                            _buildFormField(
                              label: 'Nombre',
                              controller: _nombreController,
                              icon: Icons.location_city,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo requerido';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Coordenadas
                            Text(
                              'Ubicación',
                              style: AppTextStyles.headline4,
                            ),
                            SizedBox(height: 8.h),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Latitud',
                                    controller: _latitudController,
                                    icon: Icons.my_location,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Requerido';
                                      final lat = double.tryParse(value);
                                      if (lat == null || lat < -90 || lat > 90) return 'Latitud inválida';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Longitud',
                                    controller: _longitudController,
                                    icon: Icons.place,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Requerido';
                                      final lng = double.tryParse(value);
                                      if (lng == null || lng < -180 || lng > 180) return 'Longitud inválida';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Estrategia
                            Text(
                              'Estrategia de Excedentes',
                              style: AppTextStyles.headline4,
                            ),
                            SizedBox(height: 8.h),
                            
                            _buildStrategySelector(),
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
                          onPressed: _isLoading ? null : () => _updateComunidadFromDialog(context, comunidad, setDialogState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text('Guardar', style: AppTextStyles.button),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateComunidadFromDialog(BuildContext context, ComunidadEnergetica comunidad, StateSetter setDialogState) async {
    if (!_formKey.currentState!.validate()) return;

    setDialogState(() {
      _isLoading = true;
    });

    try {
      final comunidadActualizada = ComunidadEnergetica(
        idComunidadEnergetica: comunidad.idComunidadEnergetica,
        nombre: _nombreController.text.trim(),
        latitud: double.parse(_latitudController.text),
        longitud: double.parse(_longitudController.text),
        tipoEstrategiaExcedentes: _tipoEstrategiaSeleccionada,
        idUsuario: comunidad.idUsuario,
      );

      await ref.read(comunidadesNotifierProvider.notifier)
          .updateComunidad(comunidad.idComunidadEnergetica, comunidadActualizada);

      ref.read(comunidadSeleccionadaProvider.notifier)
          .seleccionarComunidad(comunidadActualizada);

      if (mounted) {
        Navigator.pop(context); // Cerrar el dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comunidad actualizada con éxito', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setDialogState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Consumer(
      builder: (context, ref, child) {
        final participantesState = ref.watch(participantesProvider);
        final numParticipantes = participantesState.participantes.length;
        
        // Determinar qué estrategias están disponibles
        List<TipoEstrategiaExcedentes> estrategiasDisponibles;
        if (numParticipantes > 1) {
          // Si hay más de un participante, solo permitir modalidades colectivas
          estrategiasDisponibles = [
            TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES,
            TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA,
          ];
          
          // Si la estrategia actual es individual, cambiarla a colectiva por defecto
          if (_tipoEstrategiaSeleccionada == TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES ||
              _tipoEstrategiaSeleccionada == TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _tipoEstrategiaSeleccionada = TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES;
              });
            });
          }
        } else {
          // Si hay 1 o 0 participantes, permitir todas las modalidades
          estrategiasDisponibles = TipoEstrategiaExcedentes.values;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<TipoEstrategiaExcedentes>(
              value: estrategiasDisponibles.contains(_tipoEstrategiaSeleccionada) 
                  ? _tipoEstrategiaSeleccionada 
                  : estrategiasDisponibles.first,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Estrategia',
                prefixIcon: Icon(Icons.settings),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              items: estrategiasDisponibles.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(_getStrategyDisplayName(tipo), style: AppTextStyles.bodyMedium),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoEstrategiaSeleccionada = value;
                  });
                }
              },
              validator: (value) => value == null ? 'Campo requerido' : null,
            ),
            if (numParticipantes > 1)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 4.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Las modalidades individuales no están disponibles porque la comunidad tiene $numParticipantes participantes.',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
} 