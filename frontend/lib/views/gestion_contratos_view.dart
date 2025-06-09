import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/loading_widget.dart';
import '../core/widgets/custom_button.dart';
import '../models/contrato_autoconsumo.dart';
import '../models/participante.dart';
import '../models/enums/tipo_contrato.dart';
import '../services/contrato_autoconsumo_api_service.dart';
import '../providers/participante_provider.dart';
import '../components/contrato_energetico_form.dart';

class GestionContratosView extends ConsumerStatefulWidget {
  final int idParticipante;

  const GestionContratosView({
    super.key,
    required this.idParticipante,
  });

  @override
  ConsumerState<GestionContratosView> createState() => _GestionContratosViewState();
}

class _GestionContratosViewState extends ConsumerState<GestionContratosView> {
  ContratoAutoconsumo? _contratoActual;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarContrato();
  }

  Future<void> _cargarContrato() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contrato = await ContratoAutoconsumoApiService.getContratoByParticipante(
        widget.idParticipante,
      );
      setState(() {
        _contratoActual = contrato;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarContrato() async {
    if (_contratoActual == null) return;

    setState(() => _isLoading = true);

    try {
      await ContratoAutoconsumoApiService.deleteContrato(_contratoActual!.idContrato);
      setState(() {
        _contratoActual = null;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrato eliminado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar contrato: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarFormularioContrato({ContratoAutoconsumo? contratoExistente}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: ContratoAutoconsumoForm(
          idParticipante: widget.idParticipante,
          contratoExistente: contratoExistente,
          onContratoCreated: (contrato) {
            setState(() {
              _contratoActual = contrato;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participanteAsyncValue = ref.watch(participanteByIdProvider(widget.idParticipante));

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Contratos', style: AppTextStyles.appBarTitle),
        backgroundColor: Colors.green[600],
      ),
      body: participanteAsyncValue.when(
        loading: () => const LoadingCardWidget(),
        error: (error, stackTrace) => _buildErrorWidget(error.toString()),
        data: (participante) => participante == null
            ? _buildNotFoundWidget()
            : _buildContent(participante),
      ),
    );
  }

  Widget _buildContent(Participante participante) {
    if (_isLoading) {
      return const LoadingCardWidget();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildHeaderCard(participante),
          SizedBox(height: 16.h),
          if (_contratoActual != null) ...[
            _buildContratoCard(_contratoActual!),
            SizedBox(height: 16.h),
            _buildAccionesCard(),
          ] else ...[
            _buildSinContratoCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Participante participante) {
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[600],
            radius: 30.r,
            child: Text(
              participante.nombre.isNotEmpty 
                  ? participante.nombre[0].toUpperCase()
                  : 'P',
              style: AppTextStyles.headline4.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participante.nombre,
                  style: AppTextStyles.headline3,
                ),
                SizedBox(height: 4.h),
                Text(
                  'ID: ${participante.idParticipante}',
                  style: AppTextStyles.bodySmall.copyWith(
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

  Widget _buildContratoCard(ContratoAutoconsumo contrato) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.green[600], size: 24.sp),
              SizedBox(width: 8.w),
              Text('Contrato Activo', style: AppTextStyles.cardTitle),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getTipoContratoLabel(contrato.tipoContrato),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildContratoInfo(contrato),
        ],
      ),
    );
  }

  Widget _buildContratoInfo(ContratoAutoconsumo contrato) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Precio Importación',
                '${contrato.precioEnergiaImportacion_eur_kWh.toStringAsFixed(4)} €/kWh',
                Icons.input,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoItem(
                'Precio Excedentes',
                '${contrato.precioCompensacionExcedentes_eur_kWh.toStringAsFixed(4)} €/kWh',
                Icons.output,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Potencia Contratada',
                '${contrato.potenciaContratada_kW.toStringAsFixed(2)} kW',
                Icons.power,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoItem(
                'Precio Potencia',
                '${contrato.precioPotenciaContratado_eur_kWh.toStringAsFixed(4)} €/kWh',
                Icons.euro,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesCard() {
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
                  onPressed: () => _mostrarFormularioContrato(
                    contratoExistente: _contratoActual,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: 'Eliminar',
                  icon: Icons.delete,
                  type: ButtonType.outline,
                  onPressed: () => _mostrarDialogoEliminar(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSinContratoCard() {
    return CustomCard(
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 64.sp,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16.h),
          Text(
            'Sin Contrato de Autoconsumo',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Este participante aún no tiene un contrato de autoconsumo asignado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          CustomButton(
            text: 'Crear Contrato',
            icon: Icons.add,
            fullWidth: true,
            onPressed: () => _mostrarFormularioContrato(),
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
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Contrato'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este contrato de autoconsumo? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarContrato();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _getTipoContratoLabel(TipoContrato tipo) {
    switch (tipo) {
      case TipoContrato.PVPC:
        return 'PVPC';
      case TipoContrato.MERCADO_LIBRE:
        return 'Mercado Libre';
    }
  }
} 