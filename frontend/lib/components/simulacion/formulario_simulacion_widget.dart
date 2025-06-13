import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/providers/simulacion_provider.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FormularioSimulacionWidget extends ConsumerStatefulWidget {
  final int idComunidad;
  final int idUsuario;
  final Function(dynamic) onSubmit;
  final VoidCallback onCancel;

  const FormularioSimulacionWidget({
    Key? key,
    required this.idComunidad,
    required this.idUsuario,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<FormularioSimulacionWidget> createState() => _FormularioSimulacionWidgetState();
}

class _FormularioSimulacionWidgetState extends ConsumerState<FormularioSimulacionWidget> {
  final _nombreController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _nombreController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formularioState = ref.watch(formularioSimulacionProvider);
    final estrategias = ref.watch(estrategiasSimulacionProvider);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfiguracionBasica(formularioState),
                  SizedBox(height: 16.h),
                  _buildSeleccionPeriodo(formularioState),
                  SizedBox(height: 16.h),
                  _buildSeleccionEstrategia(formularioState, estrategias),
                  SizedBox(height: 16.h),
                  _buildParametrosMedicion(formularioState),
                  if (formularioState.mostrarParametrosAvanzados) ...[
                    SizedBox(height: 16.h),
                    _buildParametrosAvanzados(formularioState),
                  ],
                  SizedBox(height: 16.h),
                  _buildResumenConfiguracion(formularioState),
                  if (formularioState.erroresValidacion.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildErrores(formularioState.erroresValidacion),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildBotonesAccion(formularioState),
        ],
      ),
    );
  }

  Widget _buildConfiguracionBasica(FormularioSimulacionState state) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Configuración Básica',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _nombreController,
              onChanged: (value) => ref.read(formularioSimulacionProvider.notifier).actualizarNombre(value),
              decoration: InputDecoration(
                labelText: 'Nombre de la Simulación',
                hintText: 'Ej: Simulación Verano 2024',
                prefixIcon: Icon(Icons.title, size: 16.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              ),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionPeriodo(FormularioSimulacionState state) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Período de Simulación',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            // Configuración rápida
            Text(
              'Configuración Rápida',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                _buildChipPeriodo('Última Semana', 'semana', state),
                _buildChipPeriodo('Último Mes', 'mes', state),
                _buildChipPeriodo('Último Trimestre', 'trimestre', state),
                _buildChipPeriodo('Último Año', 'año', state),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Selección manual
            Text(
              'Configuración Manual',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: _buildSelectorFecha(
                    'Fecha Inicio',
                    state.fechaInicio,
                    (fecha) => ref.read(formularioSimulacionProvider.notifier).actualizarFechaInicio(fecha),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildSelectorFecha(
                    'Fecha Fin',
                    state.fechaFin,
                    (fecha) => ref.read(formularioSimulacionProvider.notifier).actualizarFechaFin(fecha),
                  ),
                ),
              ],
            ),
            
            if (state.duracionSimulacion != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Duración: ${state.duracionSimulacion!.inDays} días • '
                  'Tiempo estimado: ${_formatearDuracion(state.tiempoEjecucionEstimado)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipPeriodo(String label, String tipo, FormularioSimulacionState state) {
    return ActionChip(
      label: Text(label, style: AppTextStyles.caption),
      onPressed: () => ref.read(formularioSimulacionProvider.notifier).configurarPeriodoRapido(tipo),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border, width: 0.5),
      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSelectorFecha(String label, DateTime? fecha, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        // Usar el rango máximo permitido en la aplicación (PVGIS SARAH3)
        final fechaMinima = DateTime(2005, 1, 1);
        final fechaMaxima = DateTime(2023, 12, 31);
        
        final fechaSeleccionada = await showDatePicker(
          context: context,
          initialDate: fecha ?? fechaMaxima, // Usar fecha máxima como inicial si no hay fecha
          firstDate: fechaMinima,
          lastDate: fechaMaxima,
        );
        if (fechaSeleccionada != null) {
          onSelected(fechaSeleccionada);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 2.h),
            Text(
              fecha != null 
                ? '${fecha.day}/${fecha.month}/${fecha.year}'
                : 'Seleccionar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: fecha != null ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionEstrategia(FormularioSimulacionState state, List<EstrategiaSimulacion> estrategias) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Estrategia de Excedentes',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ...estrategias.map((estrategia) => _buildTarjetaEstrategia(estrategia, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaEstrategia(EstrategiaSimulacion estrategia, FormularioSimulacionState state) {
    final seleccionada = state.estrategiaSeleccionada == estrategia.tipo;
    
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: InkWell(
        onTap: () => ref.read(formularioSimulacionProvider.notifier).actualizarEstrategia(estrategia.tipo),
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: seleccionada ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: seleccionada ? AppColors.primary : AppColors.border,
              width: seleccionada ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: seleccionada ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Center(
                  child: seleccionada
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : Text(estrategia.icono, style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            estrategia.nombre,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: seleccionada ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (estrategia.recomendada) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Recomendada',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      estrategia.descripcion,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParametrosMedicion(FormularioSimulacionState state) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Parámetros de Medición',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () => ref.read(formularioSimulacionProvider.notifier).toggleParametrosAvanzados(),
                  icon: Icon(
                    state.mostrarParametrosAvanzados ? Icons.expand_less : Icons.expand_more,
                    size: 14.sp,
                  ),
                  label: Text(
                    'Avanzado',
                    style: AppTextStyles.caption,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            Text(
              'Intervalo de Medición',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              children: [15, 30, 60].map((minutos) => 
                ChoiceChip(
                  label: Text('$minutos min', style: AppTextStyles.caption),
                  selected: state.tiempoMedicion == minutos,
                  onSelected: (_) => ref.read(formularioSimulacionProvider.notifier).actualizarTiempoMedicion(minutos),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  side: BorderSide(color: AppColors.border, width: 0.5),
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametrosAvanzados(FormularioSimulacionState state) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, size: 16.sp, color: AppColors.warning),
                SizedBox(width: 6.w),
                Text(
                  'Parámetros Avanzados',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Configuración opcional para usuarios expertos',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            
            // Aquí se pueden agregar más parámetros avanzados
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Los valores por defecto son óptimos para la mayoría de casos de uso.',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenConfiguracion(FormularioSimulacionState state) {
    if (!state.esValido) return SizedBox.shrink();
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.success.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 16.sp, color: AppColors.success),
                SizedBox(width: 6.w),
                Text(
                  'Resumen de Configuración',
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildItemResumen('Nombre', state.nombre),
            if (state.fechaInicio != null && state.fechaFin != null)
              _buildItemResumen(
                'Período',
                '${state.fechaInicio!.day}/${state.fechaInicio!.month}/${state.fechaInicio!.year} - '
                '${state.fechaFin!.day}/${state.fechaFin!.month}/${state.fechaFin!.year}',
              ),
            if (state.duracionSimulacion != null)
              _buildItemResumen('Duración', '${state.duracionSimulacion!.inDays} días'),
            _buildItemResumen('Intervalo', '${state.tiempoMedicion} minutos'),
            if (state.estrategiaSeleccionada != null)
              _buildItemResumen('Estrategia', state.estrategiaSeleccionada!.toBackendString()),
            _buildItemResumen(
              'Tiempo estimado',
              _formatearDuracion(state.tiempoEjecucionEstimado),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemResumen(String label, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrores(List<String> errores) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: AppColors.error.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, size: 16.sp, color: AppColors.error),
                SizedBox(width: 6.w),
                Text(
                  'Errores de Validación',
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ...errores.map((error) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 4.sp, color: AppColors.error),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      error,
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(FormularioSimulacionState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border, width: 1),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text('Cancelar', style: AppTextStyles.button),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: state.esValido ? () => _crearSimulacion(state) : null,
            icon: Icon(Icons.add, size: 16.sp),
            label: Text('Crear Simulación', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              elevation: state.esValido ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  void _crearSimulacion(FormularioSimulacionState state) {
    try {
      final notifier = ref.read(formularioSimulacionProvider.notifier);
      final simulacion = notifier.crearSimulacion(widget.idUsuario, widget.idComunidad);
      widget.onSubmit(simulacion);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatearDuracion(Duration duracion) {
    if (duracion.inMinutes < 60) {
      return '${duracion.inMinutes} min';
    }
    return '${duracion.inHours}h ${duracion.inMinutes % 60}min';
  }
} 