import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reorderable_staggered_scroll_view/reorderable_staggered_scroll_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/simulacion.dart';
import '../../models/resultado_simulacion.dart';
import '../../models/resultado_simulacion_participante.dart';
import '../../providers/participante_provider.dart';
import '../../providers/simulacion_provider.dart';

class TabEconomiaResultados extends ConsumerStatefulWidget {
  final Simulacion simulacionSeleccionada;

  const TabEconomiaResultados({
    super.key,
    required this.simulacionSeleccionada,
  });

  @override
  ConsumerState<TabEconomiaResultados> createState() => _TabEconomiaResultadosState();
}

class _TabEconomiaResultadosState extends ConsumerState<TabEconomiaResultados> {
  bool _dragEnabled = true;
  List<String> _kpiOrder = [
    'costeTotalEnergia',
    'ahorroTotal',
    'paybackPeriod',
    'roi',
  ];

  @override
  Widget build(BuildContext context) {
    final resultadoAsync = ref.watch(resultadoSimulacionProvider(widget.simulacionSeleccionada.idSimulacion));

    return resultadoAsync.when(
      data: (resultado) => _buildContent(resultado),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildContent(ResultadoSimulacion? resultado) {
    if (resultado == null) {
      return _buildNoDataState();
    }

    final participantesAsync = ref.watch(resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 24.h),
        _buildCommunitySection(resultado),
        SizedBox(height: 24.h),
        participantesAsync.when(
          data: (participantes) => _buildParticipantesSection(participantes),
          loading: () => _buildParticipantesLoadingState(),
          error: (error, stack) => _buildParticipantesErrorState(error.toString()),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(ResultadoSimulacion resultado) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildKPIGrid(resultado),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis Económico de la Comunidad',
                  style: AppTextStyles.headline4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.simulacionSeleccionada.nombreSimulacion,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Comunidad',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(ResultadoSimulacion resultado) {
    return ReorderableStaggeredScrollView.grid(
      enable: _dragEnabled,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      isLongPressDraggable: false,
      onDragEnd: (details, item) {
        print('onDragEnd: $details ${item.key}');
        // Aquí puedes actualizar el orden de los KPIs si necesitas persistir el estado
      },
      children: _kpiOrder.asMap().entries.map((entry) {
        final index = entry.key;
        final kpiType = entry.value;
        return _buildKPIGridItem(kpiType, resultado, index);
      }).toList(),
    );
  }

  ReorderableStaggeredScrollViewGridItem _buildKPIGridItem(String kpiType, ResultadoSimulacion resultado, int index) {
    late final String title;
    late final String value;
    late final String unit;
    late final IconData icon;
    late final Color color;
    late final Color backgroundColor;
    late final String description;

    switch (kpiType) {
      case 'costeTotalEnergia':
        title = 'Coste Total de Energía';
        value = resultado.costeTotalEnergia_eur?.toStringAsFixed(2) ?? 'N/A';
        unit = '€';
        icon = Icons.euro_symbol;
        color = AppColors.error;
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        description = 'Inversión total requerida para el proyecto energético';
        break;
      case 'ahorroTotal':
        title = 'Ahorro Total';
        value = resultado.ahorroTotal_eur?.toStringAsFixed(2) ?? 'N/A';
        unit = '€';
        icon = Icons.savings;
        color = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        description = 'Ahorro económico total esperado durante la vida útil';
        break;
      case 'paybackPeriod':
        title = 'Período de Retorno';
        value = resultado.paybackPeriod_anios?.toStringAsFixed(1) ?? 'N/A';
        unit = 'años';
        icon = Icons.schedule;
        color = AppColors.warning;
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        description = 'Tiempo para recuperar la inversión';
        break;
      case 'roi':
        title = 'ROI';
        value = resultado.roi_pct?.toStringAsFixed(1) ?? 'N/A';
        unit = '%';
        icon = Icons.percent;
        color = AppColors.primary;
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        description = 'Retorno de la inversión';
        break;
      default:
        title = 'Desconocido';
        value = 'N/A';
        unit = '';
        icon = Icons.help;
        color = AppColors.textSecondary;
        backgroundColor = AppColors.surface;
        description = '';
    }

    return ReorderableStaggeredScrollViewGridCountItem(
      key: ValueKey(kpiType),
      mainAxisCellCount: _getMainAxisCellCount(kpiType),
      crossAxisCellCount: 1,
      widget: _buildKPICardContent(
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        color: color,
        backgroundColor: backgroundColor,
        description: description,
      ),
    );
  }

  int _getMainAxisCellCount(String kpiType) {
    switch (kpiType) {
      case 'costeTotalEnergia':
      case 'ahorroTotal':
        return 1;
      case 'paybackPeriod':
      case 'roi':
        return 1;
      default:
        return 1;
    }
  }

  Widget _buildKPICardContent({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 8.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.headline3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 1.w),
                Text(
                  unit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
            ),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 80.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          SizedBox(height: 200.h), // Espacio para simular contenido
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error al cargar datos económicos',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  error,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.refresh(resultadoSimulacionProvider(widget.simulacionSeleccionada.idSimulacion));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Sin resultados económicos',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Los resultados económicos aparecerán una vez que la simulación se complete exitosamente.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantesSection(List<ResultadoSimulacionParticipante> participantes) {
    if (participantes.isEmpty) {
      return _buildNoParticipantesState();
    }

    final participantesState = ref.watch(participantesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: participantes.length,
          itemBuilder: (context, index) {
            final participante = participantes[index];
            
            // Buscar el nombre del participante
            final participanteInfo = participantesState.participantes.firstWhere(
              (p) => p.idParticipante == participante.idParticipante,
              orElse: () => throw StateError('Participante no encontrado'),
            );
            
            return _buildParticipanteCard(participante, participanteInfo.nombre);
          },
        ),
      ],
    );
  }

  Widget _buildParticipantesHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.white,
            size: 12.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Análisis por Participante Individual',
              style: AppTextStyles.headline4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Individual',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipanteCard(ResultadoSimulacionParticipante participante, String nombreParticipante) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del participante
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 8.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  nombreParticipante,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // KPIs del participante
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildParticipanteKPI(
                    title: 'Coste Neto',
                    value: participante.costeNetoParticipante_eur?.toStringAsFixed(2) ?? 'N/A',
                    unit: '€',
                    icon: Icons.euro_symbol,
                    color: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    description: 'Coste neto total del participante después de considerar ahorros y gastos energéticos.',
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: _buildParticipanteKPI(
                    title: 'Ahorro Total',
                    value: participante.ahorroParticipante_eur?.toStringAsFixed(2) ?? 'N/A',
                    unit: '€',
                    icon: Icons.savings,
                    color: AppColors.success,
                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                    description: 'Ahorro económico total que obtiene el participante al formar parte de la comunidad energética.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipanteKPI({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    String? description,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 4.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (description != null)
                          GestureDetector(
                            onTap: () => _showInfoDialog(title, description),
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: Icon(
                                Icons.help_outline,
                                size: 6.sp,
                                color: AppColors.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  Row(
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (unit.isNotEmpty) ...[
                        SizedBox(width: 1.w),
                        Text(
                          unit,
                          style: AppTextStyles.caption.copyWith(
                            color: color.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  ],
                ),
              ),
            ],
          ),
          ],
      ),
    );
  }

  Widget _buildParticipantesLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipantesErrorState(String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error al cargar datos de participantes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  ref.refresh(resultadosParticipantesProvider(widget.simulacionSeleccionada.idSimulacion));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoParticipantesState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantesHeader(),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48.sp,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16.h),
              Text(
                'Sin datos de participantes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'No se encontraron datos económicos para los participantes individuales.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 