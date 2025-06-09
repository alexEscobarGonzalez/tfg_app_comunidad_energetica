import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/enums/tipo_estrategia_excedentes.dart';
import '../models/enums/estado_simulacion.dart';
import '../services/simulacion_api_service.dart';
import '../providers/user_provider.dart';
import '../providers/participante_provider.dart';
import '../models/simulacion.dart';

class CrearSimulacionDialog extends ConsumerStatefulWidget {
  final int idComunidad;
  final Simulacion? simulacionParaEditar;

  const CrearSimulacionDialog({
    super.key,
    required this.idComunidad,
    this.simulacionParaEditar,
  });

  @override
  ConsumerState<CrearSimulacionDialog> createState() => _CrearSimulacionDialogState();
}

class _CrearSimulacionDialogState extends ConsumerState<CrearSimulacionDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de formulario
  final _nombreController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TipoEstrategiaExcedentes _estrategiaSeleccionada = TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES;
  static const int _tiempoMedicion = 60; // Fijo en 1 hora

  @override
  void initState() {
    super.initState();
    
    if (widget.simulacionParaEditar != null) {
      // Modo edición: usar datos de la simulación existente
      final simulacion = widget.simulacionParaEditar!;
      _nombreController.text = simulacion.nombreSimulacion;
      _fechaInicio = simulacion.fechaInicio;
      _fechaFin = simulacion.fechaFin;
      _estrategiaSeleccionada = simulacion.tipoEstrategiaExcedentes;
      _fechaInicioController.text = _formatearFecha(_fechaInicio!);
      _fechaFinController.text = _formatearFecha(_fechaFin!);
    } else {
      // Modo crear: configurar fechas por defecto dentro del rango PVGIS SARAH3
      // Usar el último año disponible (2023) por defecto
      _fechaFin = DateTime(2023, 12, 31);
      _fechaInicio = DateTime(2023, 1, 1);
      
      // Establecer valores iniciales en los controladores
      _fechaInicioController.text = _formatearFecha(_fechaInicio!);
      _fechaFinController.text = _formatearFecha(_fechaFin!);
    }
    
    // Cargar participantes de la comunidad para validaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(participantesProvider.notifier).loadParticipantesByComunidad(widget.idComunidad);
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
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
                    widget.simulacionParaEditar != null ? 'Editar Simulación' : 'Crear Nueva Simulación',
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
                      // Nombre de la simulación
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la simulación',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        ),
                        style: AppTextStyles.bodyMedium,
                        validator: (value) => value?.trim().isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Período de simulación
                      Text(
                        'Período de simulación',
                        style: AppTextStyles.headline4,
                      ),
                      SizedBox(height: 8.h),
                    
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildCampoFecha(
                              'Fecha inicio',
                              _fechaInicioController,
                              (fecha) => setState(() => _fechaInicio = fecha),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildCampoFecha(
                              'Fecha fin',
                              _fechaFinController,
                              (fecha) => setState(() => _fechaFin = fecha),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Selector de estrategia
                      Text(
                        'Estrategia de gestión de excedentes',
                        style: AppTextStyles.headline4,
                      ),
                      SizedBox(height: 8.h),
                      _buildSelectorEstrategia(),
                      
                      SizedBox(height: 16.h),
                      
                      // Estimación de duración
                      if (_fechaInicio != null && _fechaFin != null)
                        _buildEstimacionDuracion(),
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
                    onPressed: _isLoading ? null : _crearOEditarSimulacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const ButtonLoadingSpinner()
                        : Text(widget.simulacionParaEditar != null ? 'Actualizar' : 'Crear', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoFecha(String label, TextEditingController controller, Function(DateTime?) onChanged) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        suffixIcon: Icon(Icons.calendar_today, size: 4.w, color: AppColors.textSecondary),
        hintText: 'dd/mm/yyyy',
        hintStyle: AppTextStyles.bodySecondary,
      ),
      style: AppTextStyles.bodyMedium,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _DateInputFormatter(),
      ],
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Campo requerido';
        }
        
        final fecha = _parsearFecha(value!);
        if (fecha == null) {
          return 'Formato inválido (dd/mm/yyyy)';
        }
        
        // Validar rango de PVGIS SARAH3 (2005-2023)
        final fechaMinima = DateTime(2005, 1, 1);
        final fechaMaxima = DateTime(2023, 12, 31);
        
        if (fecha.isBefore(fechaMinima)) {
          return 'Fecha mínima: 01/01/2005 (PVGIS SARAH3)';
        }
        
        if (fecha.isAfter(fechaMaxima)) {
          return 'Fecha máxima: 31/12/2023 (PVGIS SARAH3)';
        }
        
        return null;
      },
      onChanged: (value) {
        final fecha = _parsearFecha(value);
        onChanged(fecha);
      },
    );
  }

  Widget _buildEstimacionDuracion() {
    final duracion = _fechaFin!.difference(_fechaInicio!);
    final dias = duracion.inDays;
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimación de la simulación',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.info,
                  ),
                ),
                Text(
                  'Período: $dias días\nTiempo estimado: ${_getTiempoEjecucionEstimado(dias)}\nEstrategia: ${_estrategiaSeleccionada.toBackendString()}',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorEstrategia() {
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
          if (_estrategiaSeleccionada == TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES ||
              _estrategiaSeleccionada == TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _estrategiaSeleccionada = TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES;
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
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: estrategiasDisponibles.length,
                itemBuilder: (context, index) {
                  final estrategia = estrategiasDisponibles[index];
                  final isSelected = _estrategiaSeleccionada == estrategia;
                  final isDisabled = !estrategiasDisponibles.contains(estrategia);
                  
                  return InkWell(
                    onTap: isDisabled ? null : () => setState(() => _estrategiaSeleccionada = estrategia),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDisabled ? Colors.grey[300]! : AppColors.border),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getEstrategiaIcon(estrategia),
                            color: isSelected ? AppColors.primary : (isDisabled ? Colors.grey[400] : AppColors.textSecondary),
                            size: 6.sp,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            estrategia.toBackendString(),
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? AppColors.primary : (isDisabled ? Colors.grey[400] : AppColors.textSecondary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Mensaje de limitaciones de PVGIS
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    size: 8.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Limitación Principal: PVGIS SARAH3 (2005-2023)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Base de datos de radiación solar: PVGIS-SARAH3 solo tiene datos disponibles desde 2005 hasta 2023. Las simulaciones NO pueden ejecutarse para fechas anteriores a 2005 o posteriores a 2023.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
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

  IconData _getEstrategiaIcon(TipoEstrategiaExcedentes estrategia) {
    switch (estrategia) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return Icons.person_outline;
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return Icons.group_outlined;
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return Icons.person_add_outlined;
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return Icons.group_add_outlined;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  DateTime? _parsearFecha(String texto) {
    if (texto.length != 10) return null;
    
    final partes = texto.split('/');
    if (partes.length != 3) return null;
    
    try {
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);
      
      if (dia < 1 || dia > 31 || mes < 1 || mes > 12 || ano < 1900 || ano > 2100) {
        return null;
      }
      
      return DateTime(ano, mes, dia);
    } catch (e) {
      return null;
    }
  }

  String _getTiempoEjecucionEstimado(int dias) {
    if (dias <= 30) return '~1 minuto';
    if (dias <= 90) return '~3 minutos';
    if (dias <= 180) return '~8 minutos';
    return '~20 minutos';
  }

  Future<void> _crearOEditarSimulacion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, verifica que las fechas sean válidas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaInicio!.isAfter(_fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio debe ser anterior a la fecha de fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar rango de PVGIS SARAH3 (2005-2023)
    final fechaMinima = DateTime(2005, 1, 1);
    final fechaMaxima = DateTime(2023, 12, 31);
    
    if (_fechaInicio!.isBefore(fechaMinima) || _fechaFin!.isAfter(fechaMaxima)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las fechas deben estar entre 01/01/2005 y 31/12/2023 (limitación PVGIS SARAH3)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      if (!authState.isLoggedIn || authState.usuario == null) {
        throw Exception('Usuario no autenticado');
      }
      final usuario = authState.usuario!;

      final isEditing = widget.simulacionParaEditar != null;

      // Crear objeto Simulacion
      final simulacion = Simulacion(
        idSimulacion: isEditing ? widget.simulacionParaEditar!.idSimulacion : 0,
        nombreSimulacion: _nombreController.text.trim(),
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        tiempo_medicion: _tiempoMedicion,
        tipoEstrategiaExcedentes: _estrategiaSeleccionada,
        idUsuario_creador: usuario.idUsuario,
        idComunidadEnergetica: widget.idComunidad,
        estado: isEditing ? widget.simulacionParaEditar!.estado : EstadoSimulacion.PENDIENTE,
      );

      final resultado = isEditing 
          ? await SimulacionApiService.actualizarSimulacion(simulacion)
          : await SimulacionApiService.crearSimulacion(simulacion);
      
      if (resultado == null) {
        throw Exception(isEditing 
            ? 'Error al actualizar la simulación en el servidor'
            : 'Error al crear la simulación en el servidor');
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Simulación actualizada correctamente'
                : 'Simulación creada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.simulacionParaEditar != null 
                ? 'Error al actualizar la simulación: $e'
                : 'Error al crear la simulación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Formateador personalizado para entrada de fecha
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length > 10) {
      return oldValue;
    }
    
    String formatted = '';
    int cursorPosition = newValue.selection.end;
    
    for (int i = 0; i < newText.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
        if (cursorPosition > i) cursorPosition++;
      }
      
      if (formatted.length < 10) {
        formatted += newText[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
} 