import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/providers/simulacion_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/components/simulacion/formulario_simulacion_widget.dart';
import 'package:frontend/components/simulacion/monitor_ejecucion_widget.dart';
import 'package:frontend/components/simulacion/vista_resultados_widget.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/loading_indicators.dart';

class GestorSimulacionWidget extends ConsumerWidget {
  final int idComunidad;
  final String nombreComunidad;

  const GestorSimulacionWidget({
    Key? key,
    required this.idComunidad,
    required this.nombreComunidad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestorState = ref.watch(gestorSimulacionProvider);
    final usuario = ref.watch(userProvider);

    return Column(
      children: [
        // Header con título y acciones
        _buildHeader(context, gestorState),
        // Contenido principal
        Expanded(
          child: _buildBody(context, ref, gestorState, usuario?.idUsuario ?? 0),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GestorSimulacionState state) {
    String titulo;
    IconData? icono;

    switch (state.estadoActual) {
      case EstadoUISimulacion.creando:
        titulo = 'Nueva Simulación';
        icono = Icons.add_circle_outline;
        break;
      case EstadoUISimulacion.configurando:
        titulo = 'Configurando...';
        icono = Icons.settings;
        break;
      case EstadoUISimulacion.simulacionCreada:
        titulo = 'Simulación Creada';
        icono = Icons.check_circle_outline;
        break;
      case EstadoUISimulacion.ejecutando:
        titulo = 'Ejecutando Simulación';
        icono = Icons.play_circle_outline;
        break;
      case EstadoUISimulacion.completada:
        titulo = 'Simulación Completada';
        icono = Icons.check_circle_outline;
        break;
      case EstadoUISimulacion.fallida:
        titulo = 'Error en Simulación';
        icono = Icons.error_outline;
        break;
      case EstadoUISimulacion.resultados:
        titulo = 'Resultados';
        icono = Icons.analytics;
        break;
      default:
        titulo = 'Simulaciones';
        icono = Icons.science;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icono, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  nombreComunidad,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ..._buildHeaderActions(context, state),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderActions(BuildContext context, GestorSimulacionState state) {
    switch (state.estadoActual) {
      case EstadoUISimulacion.ejecutando:
        return [
          IconButton(
            onPressed: () => _mostrarDialogoCancelar(context),
            icon: const Icon(Icons.stop, color: Colors.white),
            tooltip: 'Cancelar simulación',
          ),
        ];
      case EstadoUISimulacion.completada:
      case EstadoUISimulacion.resultados:
        return [
          IconButton(
            onPressed: () => _exportarResultados(context, state),
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Exportar resultados',
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, GestorSimulacionState state, int idUsuario) {
    switch (state.estadoActual) {
      case EstadoUISimulacion.listado:
        return _buildVistaListado(context, ref);
        
      case EstadoUISimulacion.creando:
        return FormularioSimulacionWidget(
          idComunidad: idComunidad,
          idUsuario: idUsuario,
          onSubmit: (simulacion) => _crearSimulacion(ref, simulacion),
          onCancel: () => ref.read(gestorSimulacionProvider.notifier).volverAListado(),
        );
        
      case EstadoUISimulacion.configurando:
        return _buildVistaConfigurandoCreacion(context, state);
        
      case EstadoUISimulacion.simulacionCreada:
        return _buildVistaSimulacionCreada(context, ref, state);
        
      case EstadoUISimulacion.ejecutando:
        if (state.simulacionActual == null) {
          return _buildVistaError(context, ref, state.copyWith(
            mensajeEstado: 'Error: No se pudo cargar los datos de la simulación'
          ));
        }
        return MonitorEjecucionWidget(
          simulacion: state.simulacionActual!,
          progreso: state.progreso,
          logs: state.logs,
          mensajeEstado: state.mensajeEstado ?? '',
          tiempoRestante: state.tiempoRestanteEstimado,
          onCancelar: () => ref.read(gestorSimulacionProvider.notifier).cancelarSimulacion(),
        );
        
      case EstadoUISimulacion.completada:
        return _buildVistaCompletada(context, ref, state);
        
      case EstadoUISimulacion.resultados:
        if (state.simulacionActual == null) {
          return _buildVistaError(context, ref, state.copyWith(
            mensajeEstado: 'Error: No se pudieron cargar los resultados'
          ));
        }
        return VistaResultadosWidget(
          simulacion: state.simulacionActual!,
          datosResultados: state.datosResultados ?? {},
          onVolver: () => ref.read(gestorSimulacionProvider.notifier).volverAListado(),
        );
        
      case EstadoUISimulacion.fallida:
        return _buildVistaError(context, ref, state);
    }
  }

  Widget _buildVistaListado(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              size: 40.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              'Gestión de Simulaciones',
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Simula el comportamiento energético de tu comunidad',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => ref.read(gestorSimulacionProvider.notifier).iniciarCreacion(),
              icon: Icon(Icons.add, size: 14.sp),
              label: Text('Nueva Simulación', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                elevation: 2,
              ),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/comunidad/$idComunidad/simulaciones',
              ),
              icon: Icon(Icons.list, size: 14.sp),
              label: Text('Ver Todas las Simulaciones', style: AppTextStyles.button),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 1),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaCompletada(BuildContext context, WidgetRef ref, GestorSimulacionState state) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 48.sp,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '¡Simulación Completada!',
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.simulacionActual?.nombreSimulacion ?? '',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Progreso Final',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      LinearLoading(
                        value: 1.0,
                        backgroundColor: AppColors.surface,
                        color: AppColors.success,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '100% Completado',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(gestorSimulacionProvider.notifier).verResultados(),
                  icon: Icon(Icons.analytics, size: 16.sp),
                  label: Text('Ver Resultados Detallados', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(gestorSimulacionProvider.notifier).volverAListado(),
                  icon: Icon(Icons.list, size: 16.sp),
                  label: Text('Volver a Simulaciones', style: AppTextStyles.button),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVistaError(BuildContext context, WidgetRef ref, GestorSimulacionState state) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    size: 48.sp,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error en la Simulación',
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.mensajeEstado ?? 'Ha ocurrido un error inesperado',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                if (state.logs.isNotEmpty) ...[
                  Container(
                    height: 120.h,
                    width: double.infinity,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.logs.map((log) => Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            log,
                            style: AppTextStyles.caption.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(gestorSimulacionProvider.notifier).iniciarCreacion(),
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: Text('Crear Nueva Simulación', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(gestorSimulacionProvider.notifier).volverAListado(),
                  icon: Icon(Icons.arrow_back, size: 16.sp),
                  label: Text('Volver', style: AppTextStyles.button),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVistaConfigurandoCreacion(BuildContext context, GestorSimulacionState state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingSpinner(),
            SizedBox(height: 16.h),
            Text(
              'Configurando Simulación',
              style: AppTextStyles.headline4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.mensajeEstado ?? 'Preparando simulación...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaSimulacionCreada(BuildContext context, WidgetRef ref, GestorSimulacionState state) {
    if (state.simulacionActual == null) {
      return _buildVistaError(context, ref, state.copyWith(
        mensajeEstado: 'Error: No se pudo cargar los datos de la simulación'
      ));
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 48.sp,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '¡Simulación Creada!',
                  style: AppTextStyles.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.simulacionActual!.nombreSimulacion,
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16.sp, color: AppColors.info),
                          SizedBox(width: 6.w),
                          Text(
                            'Detalles de la Simulación',
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      _buildItemDetalle('ID', '#${state.simulacionActual!.idSimulacion}'),
                      _buildItemDetalle(
                        'Período', 
                        '${state.simulacionActual!.fechaInicio.day}/${state.simulacionActual!.fechaInicio.month}/${state.simulacionActual!.fechaInicio.year} - '
                        '${state.simulacionActual!.fechaFin.day}/${state.simulacionActual!.fechaFin.month}/${state.simulacionActual!.fechaFin.year}'
                      ),
                      _buildItemDetalle('Intervalo', '${state.simulacionActual!.tiempo_medicion} minutos'),
                      _buildItemDetalle('Estrategia', state.simulacionActual!.tipoEstrategiaExcedentes.toBackendString()),
                      _buildItemDetalle('Estado', state.simulacionActual!.estado.toString().split('.').last),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'La simulación ha sido creada exitosamente. Ahora puedes ejecutarla para obtener los resultados del análisis energético.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _ejecutarSimulacion(ref),
                  icon: Icon(Icons.play_arrow, size: 16.sp),
                  label: Text('Ejecutar Simulación', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(gestorSimulacionProvider.notifier).volverAListado(),
                  icon: Icon(Icons.arrow_back, size: 16.sp),
                  label: Text('Volver al Listado', style: AppTextStyles.button),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetalle(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarSimulacion(WidgetRef ref) async {
    final gestor = ref.read(gestorSimulacionProvider.notifier);
    final exito = await gestor.ejecutarSimulacion();
    
    if (!exito) {
      // El gestor ya maneja el estado de error
      return;
    }
  }

  Future<void> _crearSimulacion(WidgetRef ref, dynamic simulacion) async {
    final gestor = ref.read(gestorSimulacionProvider.notifier);
    final exito = await gestor.crearSimulacion(simulacion);
    
    if (!exito) {
      // El gestor ya maneja el estado de error
      return;
    }
  }

  void _mostrarDialogoCancelar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Simulación'),
        content: Text('¿Estás seguro de que quieres cancelar la simulación en curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar cancelación
            },
            child: Text('Sí, Cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _exportarResultados(BuildContext context, GestorSimulacionState state) {
    // Implementar exportación de resultados
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Función de exportación en desarrollo')),
    );
  }
} 