import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../providers/comunidad_energetica_provider.dart';
import '../providers/participante_provider.dart';
import '../providers/activo_generacion_provider.dart';
import '../providers/simulacion_provider.dart';
import '../providers/user_provider.dart';

class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && authState.usuario != null) {
      final usuario = authState.usuario!;
      ref.read(comunidadesNotifierProvider.notifier).loadComunidadesUsuario(usuario.idUsuario).then((_) {
        final comunidades = ref.read(comunidadesNotifierProvider);
        ref.read(comunidadSeleccionadaProvider.notifier).autoSeleccionarPrimera(comunidades);
        
        if (comunidades.isNotEmpty) {
          final idComunidad = comunidades.first.idComunidadEnergetica;
          ref.read(participantesProvider.notifier).loadParticipantesByComunidad(idComunidad);
          ref.read(activosGeneracionProvider.notifier).loadActivosGeneracionByComunidad(idComunidad);
          ref.invalidate(simulacionesComunidadProvider(idComunidad));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final comunidadSeleccionada = ref.watch(comunidadSeleccionadaProvider);
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;

    if (comunidadSeleccionada == null) {
      return _buildNoCommunitySelected();
    }

    // Watch providers específicos para la comunidad seleccionada
    final participantesState = ref.watch(participantesProvider);
    final activosState = ref.watch(activosGeneracionProvider);
    final simulacionesAsync = ref.watch(simulacionesComunidadProvider(comunidadSeleccionada.idComunidadEnergetica));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(usuario?.nombre ?? 'Usuario', comunidadSeleccionada.nombre),
          SizedBox(height: 20.h),
          _buildDetailedStats(participantesState, activosState, simulacionesAsync),
          SizedBox(height: 20.h),
          _buildSimulationsStatus(simulacionesAsync),
        ],
      ),
    );
  }

  Widget _buildNoCommunitySelected() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
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
              'Selecciona una comunidad desde el menú superior para ver su información',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String nombreUsuario, String nombreComunidad) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.dashboard, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard de $nombreComunidad',
                  style: AppTextStyles.headline4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Resumen de la información de tu comunidad energética',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDetailedStats(
    ParticipantesState participantesState,
    dynamic activosState,
    AsyncValue simulacionesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Detallada',
          style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                title: 'Estado de Participantes',
                content: _buildParticipantesInfo(participantesState),
                icon: Icons.people_outline,
                color: AppColors.info,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDetailCard(
                title: 'Estado de Activos',
                content: _buildActivosInfo(activosState),
                icon: Icons.settings_input_component,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required Widget content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          content,
        ],
      ),
    );
  }

  Widget _buildParticipantesInfo(ParticipantesState participantesState) {
    if (participantesState.isLoading) {
      return const LoadingSpinner();
    }

    if (participantesState.error != null) {
      return Text(
        'Error al cargar participantes',
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      );
    }

    final participantes = participantesState.participantes;
    
    if (participantes.isEmpty) {
      return Text(
        'No hay participantes registrados',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${participantes.length} participante(s) registrado(s)',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        ...participantes.take(3).map((participante) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Icon(Icons.person, size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  participante.nombre,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (participantes.length > 3)
          Text(
            'y ${participantes.length - 3} más...',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildActivosInfo(dynamic activosState) {
    if (activosState.isLoading) {
      return const LoadingSpinner();
    }

    if (activosState.error != null) {
      return Text(
        'Error al cargar activos',
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      );
    }

    final activos = activosState.activos ?? [];
    
    if (activos.isEmpty) {
      return Text(
        'No hay activos energéticos configurados',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${activos.length} activo(s) energético(s)',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        ...activos.take(3).map((activo) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            children: [
              Icon(Icons.solar_power, size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  activo.nombreDescriptivo ?? 'Activo sin nombre',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (activos.length > 3)
          Text(
            'y ${activos.length - 3} más...',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildSimulationsStatus(AsyncValue simulacionesAsync) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Estado de Simulaciones',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          simulacionesAsync.when(
            data: (simulaciones) => _buildSimulationsData(simulaciones),
            loading: () => const LoadingSpinner(),
            error: (error, stack) => Text(
              'Error al cargar simulaciones',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationsData(List simulaciones) {
    if (simulaciones.isEmpty) {
      return Text(
        'No hay simulaciones creadas para esta comunidad',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      );
    }

    final ejecutando = simulaciones.where((s) => s.estado.toString() == 'EstadoSimulacion.EJECUTANDO').length;
    final pendientes = simulaciones.where((s) => s.estado.toString() == 'EstadoSimulacion.PENDIENTE').length;
    final completadas = simulaciones.where((s) => s.estado.toString() == 'EstadoSimulacion.COMPLETADA').length;
    final fallidas = simulaciones.where((s) => s.estado.toString() == 'EstadoSimulacion.FALLIDA').length;

    return Column(
      children: [
        if (ejecutando > 0)
          _buildSimulationStatusRow(
            'Ejecutándose',
            ejecutando.toString(),
            AppColors.info,
            Icons.play_circle_outline,
          ),
        if (pendientes > 0)
          _buildSimulationStatusRow(
            'Pendientes',
            pendientes.toString(),
            AppColors.warning,
            Icons.pending,
          ),
        if (completadas > 0)
          _buildSimulationStatusRow(
            'Completadas',
            completadas.toString(),
            AppColors.success,
            Icons.check_circle_outline,
          ),
        if (fallidas > 0)
          _buildSimulationStatusRow(
            'Fallidas',
            fallidas.toString(),
            AppColors.error,
            Icons.error_outline,
          ),
        if (ejecutando == 0 && pendientes == 0 && completadas == 0 && fallidas == 0)
          Text(
            'Total: ${simulaciones.length} simulación(es)',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildSimulationStatusRow(String label, String count, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: color),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              count,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 