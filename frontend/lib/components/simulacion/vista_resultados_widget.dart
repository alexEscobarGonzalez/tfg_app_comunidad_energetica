import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/simulacion.dart';
import 'package:frontend/models/resultado_simulacion.dart';
import 'package:frontend/models/resultado_simulacion_participante.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class VistaResultadosWidget extends ConsumerWidget {
  final Simulacion simulacion;
  final Map<String, dynamic> datosResultados;
  final VoidCallback onVolver;

  const VistaResultadosWidget({
    Key? key,
    required this.simulacion,
    required this.datosResultados,
    required this.onVolver,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultado = datosResultados['resultado'] as ResultadoSimulacion?;
    final participantes = datosResultados['participantes'] as List<ResultadoSimulacionParticipante>? ?? [];
    
    if (resultado == null) {
      return _buildCargando();
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderCard(resultado),
                  SizedBox(height: 16.h),
                  _buildMetricasPrincipales(resultado),
                  SizedBox(height: 16.h),
                  _buildDetallesEnergeticos(resultado),
                  SizedBox(height: 16.h),
                  _buildResultadosParticipantes(participantes),
                  SizedBox(height: 16.h),
                  _buildAnalisisAmbiental(resultado),
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

  Widget _buildCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Cargando resultados...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ResultadoSimulacion resultado) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              'Resultados de la Simulación',
              style: AppTextStyles.headline3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 4.h),
            
            Text(
              simulacion.nombreSimulacion,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16.sp, color: AppColors.success),
                  SizedBox(width: 6.w),
                  Text(
                    'Simulación Completada Exitosamente',
                    style: AppTextStyles.bodyMedium.copyWith(
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
    );
  }

  Widget _buildMetricasPrincipales(ResultadoSimulacion resultado) {
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
                Icon(Icons.insights, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Métricas Principales',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                                 Expanded(
                   child: _buildMetricaCard(
                     'Autosuficiencia',
                     '${(resultado.tasaAutosuficienciaSSR_pct ?? 0.0).toStringAsFixed(1)}%',
                     Icons.battery_charging_full,
                     AppColors.success,
                     'Grado de independencia energética',
                   ),
                 ),
                 SizedBox(width: 8.w),
                 Expanded(
                   child: _buildMetricaCard(
                     'Autoconsumo',
                     '${(resultado.tasaAutoconsumoSCR_pct ?? 0.0).toStringAsFixed(1)}%',
                     Icons.recycling,
                     AppColors.info,
                     'Energía propia consumida',
                   ),
                 ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            Row(
              children: [
                                 Expanded(
                   child: _buildMetricaCard(
                     'ROI',
                     '${(resultado.roi_pct ?? 0.0).toStringAsFixed(1)}%',
                     Icons.eco,
                     AppColors.warning,
                     'Retorno de inversión',
                   ),
                 ),
                 SizedBox(width: 8.w),
                 Expanded(
                   child: _buildMetricaCard(
                     'Ahorro',
                     '${(resultado.ahorroTotal_eur ?? 0.0).toStringAsFixed(2)}€',
                     Icons.savings,
                     AppColors.primary,
                     'Ahorro económico total',
                   ),
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaCard(String titulo, String valor, IconData icono, Color color, String descripcion) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icono, size: 20.sp, color: color),
          SizedBox(height: 6.h),
          Text(
            valor,
            style: AppTextStyles.headline4.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            titulo,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            descripcion,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesEnergeticos(ResultadoSimulacion resultado) {
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
                Icon(Icons.flash_on, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Balance Energético',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Column(
                             children: [
                 _buildDetalleEnergetico(
                   'Coste Total',
                   '${(resultado.costeTotalEnergia_eur ?? 0.0).toStringAsFixed(2)}€',
                   Icons.euro,
                   AppColors.info,
                 ),
                 _buildDetalleEnergetico(
                   'Ingreso Exportación',
                   '${(resultado.ingresoTotalExportacion_eur ?? 0.0).toStringAsFixed(2)}€',
                   Icons.sell,
                   AppColors.success,
                 ),
                 _buildDetalleEnergetico(
                   'Periodo Payback',
                   '${(resultado.paybackPeriod_anios ?? 0.0).toStringAsFixed(1)} años',
                   Icons.schedule,
                   AppColors.primary,
                 ),
               ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleEnergetico(String titulo, String valor, IconData icono, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icono, size: 16.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  valor,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosParticipantes(List<ResultadoSimulacionParticipante> participantes) {
    if (participantes.isEmpty) {
      return SizedBox.shrink();
    }

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
                Icon(Icons.people, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Resultados por Participante',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '${participantes.length} participantes',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Container(
              height: 200.h,
              child: ListView.builder(
                itemCount: participantes.length,
                itemBuilder: (context, index) {
                  final participante = participantes[index];
                  return _buildTarjetaParticipante(participante, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaParticipante(ResultadoSimulacionParticipante participante, int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.error,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: color,
            child: Text(
              'P${participante.idParticipante}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participante ${participante.idParticipante}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                                   Row(
                     children: [
                       Text(
                         'Autosuf: ${(participante.tasaAutosuficienciaSSR_pct ?? 0.0).toStringAsFixed(1)}%',
                         style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                       ),
                       SizedBox(width: 8.w),
                       Text(
                         'Ahorro: ${(participante.ahorroParticipante_eur ?? 0.0).toStringAsFixed(2)}€',
                         style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                       ),
                     ],
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalisisAmbiental(ResultadoSimulacion resultado) {
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
                Icon(Icons.eco, size: 16.sp, color: AppColors.success),
                SizedBox(width: 6.w),
                Text(
                  'Impacto Ambiental',
                  style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.co2, size: 32.sp, color: AppColors.success),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reducción de Emisiones',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${resultado.reduccionCO2_kg?.toStringAsFixed(2) ?? '0.00'} kg CO₂',
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Equivalente a plantar ${((resultado.reduccionCO2_kg ?? 0.0) / 21.77).round()} árboles',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
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
            onPressed: onVolver,
            icon: Icon(Icons.arrow_back, size: 16.sp),
            label: Text('Volver', style: AppTextStyles.button),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border, width: 1),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportarResultados(),
            icon: Icon(Icons.download, size: 16.sp),
            label: Text('Exportar PDF', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () => _compartirResultados(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            elevation: 2,
          ),
          child: Icon(Icons.share, size: 16.sp),
        ),
      ],
    );
  }

  void _exportarResultados() {
    // Implementar exportación a PDF
  }

  void _compartirResultados() {
    // Implementar compartir resultados
  }
} 