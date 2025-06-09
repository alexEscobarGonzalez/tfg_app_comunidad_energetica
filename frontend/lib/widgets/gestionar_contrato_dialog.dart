import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/participante.dart';
import '../models/contrato_autoconsumo.dart';
import '../models/enums/tipo_contrato.dart';
import '../services/contrato_autoconsumo_api_service.dart';

class GestionarContratoDialog extends ConsumerStatefulWidget {
  final Participante participante;

  const GestionarContratoDialog({
    super.key,
    required this.participante,
  });

  @override
  ConsumerState<GestionarContratoDialog> createState() => _GestionarContratoDialogState();
}

class _GestionarContratoDialogState extends ConsumerState<GestionarContratoDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos
  final _precioEnergiaController = TextEditingController();
  final _precioCompensacionController = TextEditingController();
  final _potenciaContratadaController = TextEditingController();
  final _precioPotenciaController = TextEditingController();
  
  TipoContrato _tipoContratoSeleccionado = TipoContrato.PVPC;
  bool _isLoading = false;
  bool _isLoadingData = true;
  ContratoAutoconsumo? _contratoExistente;

  @override
  void initState() {
    super.initState();
    _cargarContratoExistente();
  }

  @override
  void dispose() {
    _precioEnergiaController.dispose();
    _precioCompensacionController.dispose();
    _potenciaContratadaController.dispose();
    _precioPotenciaController.dispose();
    super.dispose();
  }

  Future<void> _cargarContratoExistente() async {
    try {
      final contrato = await ContratoAutoconsumoApiService.getContratoByParticipante(
        widget.participante.idParticipante,
      );
      
      if (mounted && contrato != null) {
        setState(() {
          _contratoExistente = contrato;
          _tipoContratoSeleccionado = contrato.tipoContrato;
          _precioEnergiaController.text = contrato.precioEnergiaImportacion_eur_kWh.toString();
          _precioCompensacionController.text = contrato.precioCompensacionExcedentes_eur_kWh.toString();
          _potenciaContratadaController.text = contrato.potenciaContratada_kW.toString();
          _precioPotenciaController.text = contrato.precioPotenciaContratado_eur_kWh.toString();
          _isLoadingData = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _guardarContrato() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Usar los valores indicados por el usuario tanto para PVPC como para Mercado Libre
        final precioEnergia = double.parse(_precioEnergiaController.text);
        final precioCompensacion = double.parse(_precioCompensacionController.text);
        
        if (_contratoExistente != null) {
          // Actualizar contrato existente
          await ContratoAutoconsumoApiService.updateContrato(
            idContrato: _contratoExistente!.idContrato,
            tipoContrato: _tipoContratoSeleccionado,
            precioEnergiaImportacion_eur_kWh: precioEnergia,
            precioCompensacionExcedentes_eur_kWh: precioCompensacion,
            potenciaContratada_kW: double.parse(_potenciaContratadaController.text),
            precioPotenciaContratado_eur_kWh: double.parse(_precioPotenciaController.text),
          );
        } else {
          // Crear nuevo contrato
          await ContratoAutoconsumoApiService.createContrato(
            idParticipante: widget.participante.idParticipante,
            tipoContrato: _tipoContratoSeleccionado,
            precioEnergiaImportacion_eur_kWh: precioEnergia,
            precioCompensacionExcedentes_eur_kWh: precioCompensacion,
            potenciaContratada_kW: double.parse(_potenciaContratadaController.text),
            precioPotenciaContratado_eur_kWh: double.parse(_precioPotenciaController.text),
          );
        }
        
        if (!mounted) return;
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _contratoExistente != null 
                  ? 'Contrato actualizado con éxito' 
                  : 'Contrato creado con éxito',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Cerrar el dialog
        Navigator.of(context).pop(true);
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    _contratoExistente != null ? 'Editar Contrato' : 'Crear Contrato',
                    style: AppTextStyles.headline2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 5.w,
                ),
              ],
            ),
            
            Divider(height: 16.h),
            
            // Contenido
            Expanded(
              child: _isLoadingData 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Información del participante
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    radius: 16.r,
                                    child: Text(
                                      widget.participante.nombre.isNotEmpty 
                                          ? widget.participante.nombre[0].toUpperCase()
                                          : 'P',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Participante:',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          widget.participante.nombre,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${widget.participante.idParticipante}',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            
                            // Tipo de contrato
                            DropdownButtonFormField<TipoContrato>(
                              value: _tipoContratoSeleccionado,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                labelText: 'Tipo de contrato',
                                labelStyle: AppTextStyles.bodyMedium,
                                prefixIcon: Icon(
                                  Icons.receipt_long,
                                  size: 8.sp,
                                  color: AppColors.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              ),
                              items: TipoContrato.values.map((tipo) {
                                return DropdownMenuItem<TipoContrato>(
                                  value: tipo,
                                  child: Text(
                                    tipo == TipoContrato.PVPC ? 'PVPC' : 'Mercado Libre',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _tipoContratoSeleccionado = value;
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 16.h),
                            
                            // Información sobre PVPC
                            if (_tipoContratoSeleccionado == TipoContrato.PVPC) ...[
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_outlined,
                                      color: AppColors.warning,
                                      size: 8.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Limitaciones del PVPC:',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'El PVPC reduce el período útil de simulación de 19 años (2005-2023) a solo 9 años (2014-2023). Si la simulación difiere de esos datos se utilizarán los valores indicados en precio importación y exportación.',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                            
                            // Campos de precio (para ambos tipos de contrato)
                            if (_tipoContratoSeleccionado == TipoContrato.MERCADO_LIBRE || _tipoContratoSeleccionado == TipoContrato.PVPC) ...[
                              // Precio energía importación
                              _buildFormField(
                                controller: _precioEnergiaController,
                                label: _tipoContratoSeleccionado == TipoContrato.PVPC 
                                    ? 'Precio energía importación - Fallback (€/kWh)'
                                    : 'Precio energía importación (€/kWh)',
                                icon: Icons.euro,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa el precio de energía';
                                  }
                                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                                    return 'Ingresa un precio válido';
                                  }
                                  return null;
                                },
                                helpText: _tipoContratoSeleccionado == TipoContrato.PVPC 
                                    ? 'Usado cuando no hay datos PVPC disponibles'
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                              
                              // Precio compensación excedentes
                              _buildFormField(
                                controller: _precioCompensacionController,
                                label: _tipoContratoSeleccionado == TipoContrato.PVPC 
                                    ? 'Precio compensación excedentes - Fallback (€/kWh)'
                                    : 'Precio compensación excedentes (€/kWh)',
                                icon: Icons.euro,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa el precio de compensación';
                                  }
                                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                                    return 'Ingresa un precio válido';
                                  }
                                  return null;
                                },
                                helpText: _tipoContratoSeleccionado == TipoContrato.PVPC 
                                    ? 'Usado cuando no hay datos PVPC disponibles'
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                            ],
                            
                            // Potencia contratada (siempre visible)
                            _buildFormField(
                              controller: _potenciaContratadaController,
                              label: 'Potencia contratada (kW)',
                              icon: Icons.electrical_services,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la potencia contratada';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Ingresa una potencia válida';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            
                            // Precio potencia contratada (siempre visible)
                            _buildFormField(
                              controller: _precioPotenciaController,
                              label: 'Precio potencia contratada (€/kW)',
                              icon: Icons.euro,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el precio de potencia';
                                }
                                if (double.tryParse(value) == null || double.parse(value) < 0) {
                                  return 'Ingresa un precio válido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            Divider(height: 16.h),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancelar', style: AppTextStyles.button),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarContrato,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _contratoExistente != null ? 'Actualizar' : 'Crear',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.bodyMedium,
            prefixIcon: Icon(
              icon,
              size: 8.sp,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
        if (helpText != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              helpText,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
} 