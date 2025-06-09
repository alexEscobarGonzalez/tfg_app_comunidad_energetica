import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/loading_widget.dart';
import '../core/widgets/custom_button.dart';
import '../providers/participante_provider.dart';
import '../models/participante.dart';

class DetalleParticipanteView extends ConsumerWidget {
  final int idParticipante;

  const DetalleParticipanteView({
    super.key,
    required this.idParticipante,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participanteAsyncValue = ref.watch(participanteByIdProvider(idParticipante));
    final estadisticasAsyncValue = ref.watch(estadisticasParticipanteProvider(idParticipante));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Participante', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navegarAEditar(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _mostrarDialogoEliminar(context, ref),
          ),
        ],
      ),
      body: participanteAsyncValue.when(
        loading: () => const LoadingCardWidget(),
        error: (error, stackTrace) => _buildErrorWidget(error.toString()),
        data: (participante) => participante == null
            ? _buildNotFoundWidget()
            : _buildDetalleView(context, participante, estadisticasAsyncValue),
      ),
    );
  }

  Widget _buildDetalleView(
    BuildContext context,
    Participante participante,
    AsyncValue<Map<String, dynamic>?> estadisticasAsyncValue,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeaderCard(participante),
          SizedBox(height: 16.h),
          _buildInfoCard(participante),
          SizedBox(height: 16.h),
          _buildEstadisticasCard(estadisticasAsyncValue),
          SizedBox(height: 16.h),
          _buildActionButtons(context, participante),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Participante participante) {
    return CustomCard(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 40.r,
            child: Text(
              participante.nombre.isNotEmpty 
                  ? participante.nombre[0].toUpperCase()
                  : 'P',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            participante.nombre,
            style: AppTextStyles.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'MIEMBRO',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Participante participante) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información Personal', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          _buildInfoRow('ID Participante', participante.idParticipante.toString(), icon: Icons.badge),
          _buildInfoRow('Nombre Completo', participante.nombre, icon: Icons.person),
          _buildInfoRow('ID Comunidad', participante.idComunidadEnergetica.toString(), icon: Icons.business),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Para información adicional como email, teléfono o dirección, edite el participante.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
          ],
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasCard(AsyncValue<Map<String, dynamic>?> estadisticasAsyncValue) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estadísticas', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          estadisticasAsyncValue.when(
            loading: () => LoadingWidget(height: 100.h),
            error: (error, stackTrace) => Text(
              'Error al cargar estadísticas',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            data: (estadisticas) => estadisticas == null
                ? Text(
                    'No hay estadísticas disponibles',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  )
                : _buildEstadisticasContent(estadisticas),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasContent(Map<String, dynamic> estadisticas) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Consumo Mensual',
                '${estadisticas['consumoMensual'] ?? 0} kWh',
                Icons.electrical_services,
                AppColors.warning,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Ahorro Estimado',
                '€${estadisticas['ahorroEstimado'] ?? 0}',
                Icons.savings,
                AppColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Generación',
                '${estadisticas['generacion'] ?? 0} kWh',
                Icons.solar_power,
                AppColors.solar,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Participación',
                '${estadisticas['participacion'] ?? 0}%',
                Icons.pie_chart,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.statisticValue.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.statisticLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Participante participante) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Acciones', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Editar',
                  icon: Icons.edit,
                  type: ButtonType.outline,
                  onPressed: () => _navegarAEditar(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: 'Contratos',
                  icon: Icons.description,
                  onPressed: () => _navegarAContratos(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomButton(
            text: 'Ver Comunidad',
            icon: Icons.business,
            type: ButtonType.secondary,
            fullWidth: true,
            onPressed: () => _navegarAComunidad(context, participante.idComunidadEnergetica),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Error al cargar participante',
              style: AppTextStyles.headline3.copyWith(color: AppColors.error),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text(
              'Participante no encontrado',
              style: AppTextStyles.headline3.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'El participante solicitado no existe o ha sido eliminado',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navegarAEditar(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/participante/$idParticipante/editar',
    );
  }

  void _navegarAContratos(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/participante/$idParticipante/contratos',
    );
  }

  void _navegarAComunidad(BuildContext context, int idComunidad) {
    Navigator.pushNamed(
      context,
      '/comunidad/$idComunidad',
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar participante'),
        content: const Text('¿Estás seguro de que deseas eliminar este participante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(participantesProvider.notifier)
                  .deleteParticipante(idParticipante);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Participante eliminado correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 