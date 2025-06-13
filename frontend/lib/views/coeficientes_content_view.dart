import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/coeficiente_reparto.dart';
import '../models/participante.dart';
import '../models/activo_generacion.dart';
import '../models/activo_almacenamiento.dart';
import '../models/enums/tipo_reparto.dart';
import '../providers/participante_provider.dart';
import '../providers/activo_generacion_provider.dart';
import '../services/coeficiente_reparto_api_service.dart';
import '../services/activo_almacenamiento_api_service.dart';
import '../widgets/repartir_coeficientes_dialog.dart';

class CoeficientesContentView extends ConsumerStatefulWidget {
  final int idComunidad;
  final String nombreComunidad;

  const CoeficientesContentView({
    super.key,
    required this.idComunidad,
    required this.nombreComunidad,
  });

  @override
  ConsumerState<CoeficientesContentView> createState() => _CoeficientesContentViewState();
}

class _CoeficientesContentViewState extends ConsumerState<CoeficientesContentView> {
  List<CoeficienteReparto> _coeficientes = [];
  List<Participante> _participantes = [];
  List<ActivoGeneracion> _activosGeneracion = [];
  List<ActivoAlmacenamiento> _activosAlmacenamiento = [];
  bool _isLoading = true;
  String? _error;
  double _energiaTotalDisponible = 0.0;

  @override
  void initState() {
    super.initState();
    // Cargar datos después del primer frame para evitar errores de Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar participantes
      await ref.read(participantesProvider.notifier).loadParticipantesByComunidad(widget.idComunidad);
      
      if (!mounted) return;
      final participantesState = ref.read(participantesProvider);
      
      // Cargar activos de generación
      await ref.read(activosGeneracionProvider.notifier).loadActivosGeneracionByComunidad(widget.idComunidad);
      
      if (!mounted) return;
      final activosGenState = ref.read(activosGeneracionProvider);
      
      // Cargar activos de almacenamiento
      final activosAlm = await ActivoAlmacenamientoApiService.getActivosAlmacenamientoByComunidad(widget.idComunidad);
      
      if (!mounted) return;
      
      // Actualizar lista de participantes antes de cargar coeficientes
      _participantes = participantesState.participantes;
      
      // Cargar coeficientes de reparto
      final coeficientes = await _cargarCoeficientes();
      
      // Calcular energía total disponible (solo activos de generación)
      double energiaTotal = 0.0;
      for (final activo in activosGenState.activos) {
        energiaTotal += activo.potenciaNominal_kWp;
      }
      // Los activos de almacenamiento no se incluyen en el reparto de coeficientes

      if (!mounted) return;
      
      setState(() {
        _participantes = participantesState.participantes;
        _activosGeneracion = activosGenState.activos;
        _activosAlmacenamiento = activosAlm;
        _coeficientes = coeficientes;
        _energiaTotalDisponible = energiaTotal;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<CoeficienteReparto>> _cargarCoeficientes() async {
    try {
      // Si no hay participantes cargados todavía, devolver lista vacía
      if (_participantes.isEmpty) {
        return [];
      }
      
      List<CoeficienteReparto> coeficientes = [];
      
      // Cargar coeficiente de cada participante individualmente (relación 1:1)
      for (final participante in _participantes) {
        try {
          final coeficiente = await CoeficienteRepartoApiService.getCoeficienteByParticipante(
            participante.idParticipante
          );
          
          if (coeficiente != null) {
            coeficientes.add(coeficiente);
          }
        } catch (e) {
          // Si hay error para un participante específico, continuar con los demás
          print('Error al cargar coeficiente del participante ${participante.idParticipante}: $e');
        }
      }
      
      return coeficientes;
    } catch (e) {
      print('Error general al cargar coeficientes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con título y botón de repartir
        _buildHeader(context),
        
        // Contenido principal
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _error != null
                  ? _buildErrorState()
                  : _coeficientes.isEmpty
                      ? _buildEmptyState()
                      : _buildCoeficientesResumen(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  'Coeficientes de Reparto',
                  style: AppTextStyles.tabSectionTitle,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.nombreComunidad,
                  style: AppTextStyles.tabDescription,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoRepartir(context),
            icon: const Icon(Icons.pie_chart, color: Colors.white),
            label: Text(
              _coeficientes.isEmpty ? 'Crear Coeficientes' : 'Editar Coeficientes',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'Error al cargar coeficientes',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _error!,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _cargarDatos,
            icon: const Icon(Icons.refresh),
            label: Text('Reintentar', style: AppTextStyles.button.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No se han registrado coeficientes',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Los coeficientes de reparto determinan cómo se distribuye la energía entre los participantes',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoRepartir(context),
              icon: const Icon(Icons.pie_chart),
              label: Text('Repartir Coeficientes', style: AppTextStyles.button.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoeficientesResumen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de energía total
          _buildEnergiaTotalCard(),
          SizedBox(height: 16.h),
          
          // Resumen por participante
          _buildParticipantesResumen(),
        ],
      ),
    );
  }

  Widget _buildEnergiaTotalCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.primary, size: 14.sp),
                SizedBox(width: 2.w),
                Text(
                  'Energía Total Disponible',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '${_energiaTotalDisponible.toStringAsFixed(2)} kW/kWh',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Total de ${_activosGeneracion.length} activos de generación',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantesResumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución por Participante',
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        
        // Grid de participantes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: _participantes.length,
          itemBuilder: (context, index) {
            final participante = _participantes[index];
            return _buildParticipanteCard(participante);
          },
        ),
      ],
    );
  }

  Widget _buildParticipanteCard(Participante participante) {
    // Obtener coeficiente para este participante
    final coeficienteParticipante = _coeficientes.firstWhere(
      (c) => c.idParticipante == participante.idParticipante,
      orElse: () => CoeficienteReparto(
        idCoeficienteReparto: 0,
        tipoReparto: TipoReparto.REPARTO_FIJO,
        parametros: {'valor': 0.0},
        idParticipante: participante.idParticipante,
      ),
    );
    
    double porcentajeTotal = 0.0;
    String tipoDisplay = 'Fijo';
    
    if (coeficienteParticipante.tipoReparto == TipoReparto.REPARTO_FIJO) {
      porcentajeTotal = coeficienteParticipante.parametros['valor'] as double? ?? 0.0;
      tipoDisplay = 'Fijo';
    } else if (coeficienteParticipante.tipoReparto == TipoReparto.REPARTO_PROGRAMADO) {
      // Para programados, calcular promedio de todas las horas
      final parametros = coeficienteParticipante.parametros['parametros'] as List<dynamic>? ?? [];
      if (parametros.isNotEmpty) {
        double suma = 0.0;
        for (final param in parametros) {
          suma += (param['valor'] as double? ?? 0.0);
        }
        porcentajeTotal = suma / parametros.length;
      } else {
        porcentajeTotal = coeficienteParticipante.parametros['valor_default'] as double? ?? 0.0;
      }
      tipoDisplay = 'Programado';
    }
    
    final energiaAsignada = (_energiaTotalDisponible * porcentajeTotal / 100.0);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
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
          // Avatar del participante
          CircleAvatar(
            backgroundColor: porcentajeTotal > 0 ? AppColors.success : AppColors.info,
            radius: 24.r,
            child: Text(
              participante.nombre.isNotEmpty 
                  ? participante.nombre[0].toUpperCase()
                  : 'P',
              style: AppTextStyles.cardTitle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          
          // Nombre del participante
          Text(
            participante.nombre,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          
          // Tipo de reparto
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: tipoDisplay == 'Programado' 
                  ? AppColors.info.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: tipoDisplay == 'Programado' 
                    ? AppColors.info.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              tipoDisplay,
              style: AppTextStyles.caption.copyWith(
                color: tipoDisplay == 'Programado' ? AppColors.info : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          
          // Porcentaje asignado
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: porcentajeTotal > 0 
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: porcentajeTotal > 0 
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              tipoDisplay == 'Programado' 
                  ? '${porcentajeTotal.toStringAsFixed(1)}% (avg)'
                  : '${porcentajeTotal.toStringAsFixed(1)}%',
              style: AppTextStyles.cardSubtitle.copyWith(
                color: porcentajeTotal > 0 ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          
          // Energía asignada
          Text(
            '${energiaAsignada.toStringAsFixed(1)} kW/kWh',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoRepartir(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => RepartirCoeficientesDialog(
        idComunidad: widget.idComunidad,
        participantes: _participantes,
        activosGeneracion: _activosGeneracion,
        energiaTotalDisponible: _energiaTotalDisponible,
      ),
    );
    
    // Si el diálogo retorna true (éxito), recargar los datos
    if (resultado == true) {
      _cargarDatos();
    }
  }
} 