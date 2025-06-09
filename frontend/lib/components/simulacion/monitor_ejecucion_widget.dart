import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/simulacion.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MonitorEjecucionWidget extends ConsumerStatefulWidget {
  final Simulacion simulacion;
  final double progreso;
  final List<String> logs;
  final String mensajeEstado;
  final Duration? tiempoRestante;
  final VoidCallback onCancelar;

  const MonitorEjecucionWidget({
    Key? key,
    required this.simulacion,
    required this.progreso,
    required this.logs,
    required this.mensajeEstado,
    this.tiempoRestante,
    required this.onCancelar,
  }) : super(key: key);

  @override
  ConsumerState<MonitorEjecucionWidget> createState() => _MonitorEjecucionWidgetState();
}

class _MonitorEjecucionWidgetState extends ConsumerState<MonitorEjecucionWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  final ScrollController _logsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MonitorEjecucionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll a los logs más recientes
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logsScrollController.hasClients) {
          _logsScrollController.animateTo(
            _logsScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderCard(),
                  SizedBox(height: 16.h),
                  _buildProgresoCard(),
                  SizedBox(height: 16.h),
                  _buildEstadisticasCard(),
                  SizedBox(height: 16.h),
                  _buildLogsCard(),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildBotonesAccion(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Icono animado
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12.r,
                                spreadRadius: 2.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Título y estado
            Text(
              widget.simulacion.nombreSimulacion,
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.mensajeEstado,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresoCard() {
    final porcentaje = (widget.progreso * 100).round();
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Progreso de Ejecución',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Barra de progreso principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completado',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$porcentaje%',
                      style: AppTextStyles.headline4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: widget.progreso,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.progreso < 0.3 
                          ? AppColors.warning
                          : widget.progreso < 0.7 
                            ? AppColors.info 
                            : AppColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (widget.tiempoRestante != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: AppColors.info),
                    SizedBox(width: 6.w),
                    Text(
                      'Tiempo restante estimado: ${_formatearTiempoRestante(widget.tiempoRestante!)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.info),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    final duracionPeriodo = widget.simulacion.fechaFin.difference(widget.simulacion.fechaInicio);
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Información de la Simulación',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Column(
              children: [
                _buildEstadisticaItem(
                  'Período',
                  '${widget.simulacion.fechaInicio.day}/${widget.simulacion.fechaInicio.month}/${widget.simulacion.fechaInicio.year} - '
                  '${widget.simulacion.fechaFin.day}/${widget.simulacion.fechaFin.month}/${widget.simulacion.fechaFin.year}',
                  Icons.date_range,
                ),
                _buildEstadisticaItem(
                  'Duración',
                  '${duracionPeriodo.inDays} días',
                  Icons.schedule,
                ),
                _buildEstadisticaItem(
                  'Intervalo',
                  '${widget.simulacion.tiempo_medicion} minutos',
                  Icons.access_time,
                ),
                _buildEstadisticaItem(
                  'Estrategia',
                  widget.simulacion.tipoEstrategiaExcedentes.toBackendString(),
                  Icons.flash_on,
                ),
                _buildEstadisticaItem(
                  'Estado',
                  widget.simulacion.estado.name,
                  Icons.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String label, String valor, IconData icono) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
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

  Widget _buildLogsCard() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Log de Ejecución',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '${widget.logs.length} entradas',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: AppColors.border),
              ),
              child: widget.logs.isEmpty
                ? Center(
                    child: Text(
                      'Esperando logs del sistema...',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _logsScrollController,
                    padding: EdgeInsets.all(8.w),
                    itemCount: widget.logs.length,
                    itemBuilder: (context, index) {
                      final log = widget.logs[index];
                      final esNuevo = index >= widget.logs.length - 3;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: esNuevo ? BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.r),
                        ) : null,
                        child: Text(
                          log,
                          style: AppTextStyles.caption.copyWith(
                            fontFamily: 'monospace',
                            color: esNuevo 
                              ? AppColors.primary
                              : Colors.grey[300],
                            fontSize: 9.sp,
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onCancelar,
            icon: Icon(Icons.stop, size: 16.sp),
            label: Text('Cancelar Simulación', style: AppTextStyles.button),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error, width: 1),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }

  String _formatearTiempoRestante(Duration duracion) {
    if (duracion.inSeconds < 60) {
      return '${duracion.inSeconds} segundos';
    } else if (duracion.inMinutes < 60) {
      return '${duracion.inMinutes} minutos';
    } else {
      final horas = duracion.inHours;
      final minutos = duracion.inMinutes % 60;
      return '${horas}h ${minutos}min';
    }
  }
} 