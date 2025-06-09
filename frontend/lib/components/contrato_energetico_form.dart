import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/custom_button.dart';
import '../models/contrato_autoconsumo.dart';
import '../models/enums/tipo_contrato.dart';
import '../services/contrato_autoconsumo_api_service.dart';

class ContratoAutoconsumoForm extends ConsumerStatefulWidget {
  final int idParticipante;
  final ContratoAutoconsumo? contratoExistente;
  final Function(ContratoAutoconsumo)? onContratoCreated;

  const ContratoAutoconsumoForm({
    super.key,
    required this.idParticipante,
    this.contratoExistente,
    this.onContratoCreated,
  });

  @override
  ConsumerState<ContratoAutoconsumoForm> createState() => _ContratoAutoconsumoFormState();
}

class _ContratoAutoconsumoFormState extends ConsumerState<ContratoAutoconsumoForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos
  late final TextEditingController _precioEnergiaController;
  late final TextEditingController _precioCompensacionController;
  late final TextEditingController _potenciaContratadaController;
  late final TextEditingController _precioPotenciaController;
  
  TipoContrato _tipoContratoSeleccionado = TipoContrato.PVPC;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  @override
  void dispose() {
    _precioEnergiaController.dispose();
    _precioCompensacionController.dispose();
    _potenciaContratadaController.dispose();
    _precioPotenciaController.dispose();
    super.dispose();
  }

  void _inicializarControladores() {
    final contrato = widget.contratoExistente;
    
    _precioEnergiaController = TextEditingController(
      text: contrato?.precioEnergiaImportacion_eur_kWh.toString() ?? '',
    );
    _precioCompensacionController = TextEditingController(
      text: contrato?.precioCompensacionExcedentes_eur_kWh.toString() ?? '',
    );
    _potenciaContratadaController = TextEditingController(
      text: contrato?.potenciaContratada_kW.toString() ?? '',
    );
    _precioPotenciaController = TextEditingController(
      text: contrato?.precioPotenciaContratado_eur_kWh.toString() ?? '',
    );
    
    if (contrato != null) {
      _tipoContratoSeleccionado = contrato.tipoContrato;
    }
  }

  Future<void> _guardarContrato() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      ContratoAutoconsumo contrato;
      
      if (widget.contratoExistente != null) {
        // Actualizar contrato existente
        contrato = await ContratoAutoconsumoApiService.updateContrato(
          idContrato: widget.contratoExistente!.idContrato,
          tipoContrato: _tipoContratoSeleccionado,
          precioEnergiaImportacion_eur_kWh: double.parse(_precioEnergiaController.text),
          precioCompensacionExcedentes_eur_kWh: double.parse(_precioCompensacionController.text),
          potenciaContratada_kW: double.parse(_potenciaContratadaController.text),
          precioPotenciaContratado_eur_kWh: double.parse(_precioPotenciaController.text),
        );
      } else {
        // Crear nuevo contrato
        contrato = await ContratoAutoconsumoApiService.createContrato(
          idParticipante: widget.idParticipante,
          tipoContrato: _tipoContratoSeleccionado,
          precioEnergiaImportacion_eur_kWh: double.parse(_precioEnergiaController.text),
          precioCompensacionExcedentes_eur_kWh: double.parse(_precioCompensacionController.text),
          potenciaContratada_kW: double.parse(_potenciaContratadaController.text),
          precioPotenciaContratado_eur_kWh: double.parse(_precioPotenciaController.text),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.contratoExistente != null 
                  ? 'Contrato actualizado exitosamente'
                  : 'Contrato creado exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onContratoCreated?.call(contrato);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contratoExistente != null ? 'Editar Contrato' : 'Nuevo Contrato',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeaderCard(),
              SizedBox(height: 16.h),
              _buildTipoContratoCard(),
              SizedBox(height: 16.h),
              _buildPreciosEnergiaCard(),
              SizedBox(height: 16.h),
              _buildPotenciaCard(),
              if (_error != null) ...[
                SizedBox(height: 16.h),
                _buildErrorCard(),
              ],
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[600],
            radius: 30.r,
            child: Icon(
              Icons.description,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contratoExistente != null ? 'Editar Contrato' : 'Nuevo Contrato',
                  style: AppTextStyles.headline3,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Participante ID: ${widget.idParticipante}',
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

  Widget _buildTipoContratoCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de Contrato', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: RadioListTile<TipoContrato>(
                  title: const Text('PVPC'),
                  subtitle: const Text('Precio Voluntario Pequeño Consumidor'),
                  value: TipoContrato.PVPC,
                  groupValue: _tipoContratoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      _tipoContratoSeleccionado = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<TipoContrato>(
                  title: const Text('Mercado Libre'),
                  subtitle: const Text('Tarifa comercializadora'),
                  value: TipoContrato.MERCADO_LIBRE,
                  groupValue: _tipoContratoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      _tipoContratoSeleccionado = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreciosEnergiaCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Precios de Energía', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _precioEnergiaController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Importación',
                    suffixText: '€/kWh',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.input),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Debe ser mayor que 0';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextFormField(
                  controller: _precioCompensacionController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Excedentes',
                    suffixText: '€/kWh',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.output),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    if (double.parse(value) < 0) {
                      return 'No puede ser negativo';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'El precio de importación es lo que pagas por la energía que consumes de la red. El precio de excedentes es lo que recibes por la energía que inyectas.',
                    style: AppTextStyles.caption.copyWith(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotenciaCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Términos de Potencia', style: AppTextStyles.cardTitle),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _potenciaContratadaController,
                  decoration: const InputDecoration(
                    labelText: 'Potencia Contratada',
                    suffixText: 'kW',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.power),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Debe ser mayor que 0';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextFormField(
                  controller: _precioPotenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Potencia',
                    suffixText: '€/kW·mes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    if (double.parse(value) < 0) {
                      return 'No puede ser negativo';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.purple, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'La potencia contratada es la máxima potencia que puedes consumir. El precio de potencia es un coste fijo mensual.',
                    style: AppTextStyles.caption.copyWith(color: Colors.purple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            type: ButtonType.outline,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomButton(
            text: _isLoading ? 'Guardando...' : 'Guardar',
            onPressed: _isLoading ? null : _guardarContrato,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
} 