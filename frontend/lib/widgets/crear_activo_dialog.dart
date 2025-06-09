import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/loading_indicators.dart';
import '../models/enums/tipo_activo_generacion.dart';
import '../providers/activo_generacion_provider.dart';
import '../providers/activo_almacenamiento_provider.dart';
import '../models/activo_generacion.dart';
import '../models/activo_almacenamiento.dart';

class CrearActivoDialog extends ConsumerStatefulWidget {
  final int idComunidad;
  final ActivoGeneracion? activoGeneracionEditar;
  final ActivoAlmacenamiento? activoAlmacenamientoEditar;

  const CrearActivoDialog({
    super.key,
    required this.idComunidad,
    this.activoGeneracionEditar,
    this.activoAlmacenamientoEditar,
  });

  @override
  ConsumerState<CrearActivoDialog> createState() => _CrearActivoDialogState();
}

class _CrearActivoDialogState extends ConsumerState<CrearActivoDialog> {
  String? _tipoSeleccionado;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para activos de generación
  final _nombreGeneracionController = TextEditingController();
  final _potenciaController = TextEditingController();
  final _costeController = TextEditingController();
  final _vidaUtilController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _curvaPotenciaController = TextEditingController();
  
  // Controladores para campos específicos de fotovoltaicas
  final _inclinacionController = TextEditingController(text: '30');
  final _azimutController = TextEditingController(text: '180');
  final _perdidaSistemaController = TextEditingController(text: '14');
  
  // Controladores para activos de almacenamiento
  final _nombreAlmacenamientoController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _eficienciaController = TextEditingController();
  final _potenciaCargaController = TextEditingController();
  final _potenciaDescargaController = TextEditingController();
  final _profundidadDescargaController = TextEditingController();

  TipoActivoGeneracion _tipoGeneracion = TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA;
  Map<String, dynamic>? _curvaPotenciaParsed;
  
  // Variables para dropdowns
  String _tecnologiaPanel = 'crystSi';
  String _posicionMontaje = 'fijo';

  // Variables para detectar modo edición
  bool get _esEdicion => widget.activoGeneracionEditar != null || widget.activoAlmacenamientoEditar != null;
  bool get _esEdicionGeneracion => widget.activoGeneracionEditar != null;
  bool get _esEdicionAlmacenamiento => widget.activoAlmacenamientoEditar != null;

  @override
  void initState() {
    super.initState();
    _inicializarCampos();
  }

  void _inicializarCampos() {
    if (_esEdicionGeneracion) {
      final activo = widget.activoGeneracionEditar!;
      _tipoSeleccionado = activo.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
          ? 'Instalación Fotovoltaica' 
          : 'Aerogenerador';
      _tipoGeneracion = activo.tipo_activo;
      
      // Prellenar campos de generación
      _nombreGeneracionController.text = activo.nombreDescriptivo;
      _potenciaController.text = activo.potenciaNominal_kWp.toString();
      _costeController.text = activo.costeInstalacion_eur.toString();
      _vidaUtilController.text = activo.vidaUtil_anios.toString();
      _latitudController.text = activo.latitud.toString();
      _longitudController.text = activo.longitud.toString();
      
      // Campos específicos según tipo
      if (activo.tipo_activo == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA) {
        _inclinacionController.text = activo.inclinacionGrados ?? '30';
        _azimutController.text = activo.azimutGrados ?? '180';
        _perdidaSistemaController.text = activo.perdidaSistema ?? '14';
        _tecnologiaPanel = activo.tecnologiaPanel ?? 'crystSi';
        _posicionMontaje = activo.posicionMontaje ?? 'fijo';
      } else if (activo.tipo_activo == TipoActivoGeneracion.AEROGENERADOR) {
        if (activo.curvaPotencia != null) {
          _curvaPotenciaController.text = jsonEncode(activo.curvaPotencia);
          _curvaPotenciaParsed = activo.curvaPotencia;
        }
      }
    } else if (_esEdicionAlmacenamiento) {
      final activo = widget.activoAlmacenamientoEditar!;
      _tipoSeleccionado = 'Sistema de Almacenamiento';
      
      // Prellenar campos de almacenamiento
      _nombreAlmacenamientoController.text = activo.nombreDescriptivo ?? '';
      _capacidadController.text = activo.capacidadNominal_kWh.toString();
      _eficienciaController.text = activo.eficienciaCicloCompleto_pct?.toString() ?? '';
      _potenciaCargaController.text = activo.potenciaMaximaCarga_kW?.toString() ?? '';
      _potenciaDescargaController.text = activo.potenciaMaximaDescarga_kW?.toString() ?? '';
      _profundidadDescargaController.text = activo.profundidadDescargaMax_pct?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreGeneracionController.dispose();
    _potenciaController.dispose();
    _costeController.dispose();
    _vidaUtilController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _curvaPotenciaController.dispose();
    _inclinacionController.dispose();
    _azimutController.dispose();
    _perdidaSistemaController.dispose();
    _nombreAlmacenamientoController.dispose();
    _capacidadController.dispose();
    _eficienciaController.dispose();
    _potenciaCargaController.dispose();
    _potenciaDescargaController.dispose();
    _profundidadDescargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 500.w,
        constraints: BoxConstraints(maxHeight: 700.h),
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    _esEdicion
                        ? (_tipoSeleccionado == null ? 'Editar Activo' : 'Editar $_tipoSeleccionado')
                        : (_tipoSeleccionado == null ? 'Crear Activo' : 'Crear $_tipoSeleccionado'),
                    style: AppTextStyles.headline2,
                  ),
                ),
                if (_tipoSeleccionado != null)
                  IconButton(
                    onPressed: () => setState(() => _tipoSeleccionado = null),
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 5.w,
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
              child: _esEdicion || _tipoSeleccionado != null
                  ? _buildFormulario()
                  : _buildSeleccionTipo(),
            ),
            
            // Botones (solo si hay formulario)
            if (_esEdicion || _tipoSeleccionado != null) ...[
              Divider(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar', style: AppTextStyles.button),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarActivo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading 
                          ? const ButtonLoadingSpinner()
                          : Text(_esEdicion ? 'Actualizar' : 'Crear', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionTipo() {
    return Column(
      children: [
        Text(
          'Selecciona el tipo de activo:',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: 16.h),
        
        Row(
          children: [
            Expanded(
              child: _buildTipoOption(
                icon: Icons.solar_power,
                color: AppColors.solar,
                title: 'Fotovoltaica',
                onTap: () {
                  setState(() {
                    _tipoSeleccionado = 'Instalación Fotovoltaica';
                    _tipoGeneracion = TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA;
                  });
                },
              ),
            ),
            
            SizedBox(width: 8.w),
            
            Expanded(
              child: _buildTipoOption(
                icon: Icons.air,
                color: AppColors.wind,
                title: 'Aerogenerador',
                onTap: () {
                  setState(() {
                    _tipoSeleccionado = 'Aerogenerador';
                    _tipoGeneracion = TipoActivoGeneracion.AEROGENERADOR;
                  });
                },
              ),
            ),
            
            SizedBox(width: 8.w),
            
            Expanded(
              child: _buildTipoOption(
                icon: Icons.battery_charging_full,
                color: AppColors.battery,
                title: 'Almacenamiento',
                onTap: () {
                  setState(() {
                    _tipoSeleccionado = 'Sistema de Almacenamiento';
                    // Para almacenamiento no necesitamos cambiar _tipoGeneracion
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipoOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(icon, color: Colors.white, size: 10.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_tipoSeleccionado == 'Instalación Fotovoltaica' || _tipoSeleccionado == 'Aerogenerador')
              _buildFormularioGeneracion()
            else if (_tipoSeleccionado == 'Sistema de Almacenamiento')
              _buildFormularioAlmacenamiento(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioGeneracion() {
    return Column(
      children: [
        // Tipo de activo de generación (solo lectura, ya seleccionado)
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<TipoActivoGeneracion>(
            value: _tipoGeneracion,
            decoration: InputDecoration(
              labelText: 'Tipo (seleccionado)',
              labelStyle: TextStyle(fontSize: 3.5.sp, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              enabled: false,
            ),
            items: [
              DropdownMenuItem(
                value: _tipoGeneracion,
                child: Row(
                  children: [
                    Icon(
                      _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                          ? Icons.solar_power 
                          : Icons.air,
                      size: 4.sp,
                      color: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                          ? AppColors.solar 
                          : AppColors.wind,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                          ? 'Instalación Fotovoltaica' 
                          : 'Aerogenerador',
                      style: TextStyle(fontSize: 3.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: null, // Deshabilitado
            disabledHint: Row(
              children: [
                Icon(
                  _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                      ? Icons.solar_power 
                      : Icons.air,
                  size: 4.sp,
                  color: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                      ? AppColors.solar 
                      : AppColors.wind,
                ),
                SizedBox(width: 8.w),
                Text(
                  _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
                      ? 'Instalación Fotovoltaica' 
                      : 'Aerogenerador',
                  style: TextStyle(fontSize: 3.5.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Nombre
        TextFormField(
          controller: _nombreGeneracionController,
          decoration: InputDecoration(
            labelText: 'Nombre descriptivo',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          style: TextStyle(fontSize: 3.5.sp),
          validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),
        
        SizedBox(height: 12.h),
        
        // Potencia y Coste en fila
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _potenciaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Potencia (kWp)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _costeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Coste (€)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        // Vida útil
        TextFormField(
          controller: _vidaUtilController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Vida útil (años)',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          style: TextStyle(fontSize: 3.5.sp),
          validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),
        
        SizedBox(height: 12.h),
        
        // Ubicación
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latitudController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Latitud',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _longitudController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Longitud',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ),
          ],
        ),
        
        // Curva de potencia (solo para aerogeneradores)
        if (_tipoGeneracion == TipoActivoGeneracion.AEROGENERADOR) ...[
          SizedBox(height: 12.h),
          _buildCurvaPotenciaSection(),
        ],

        // Campos específicos para instalaciones fotovoltaicas
        if (_tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA) ...[
          SizedBox(height: 12.h),
          _buildCamposFotovoltaicos(),
        ],
      ],
    );
  }

  Widget _buildCurvaPotenciaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.show_chart, size: 4.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              'Curva de Potencia',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          'Ingresa la curva de potencia como JSON (velocidad viento : factor potencia)',
          style: AppTextStyles.caption.copyWith(
            fontSize: 3.sp,
            color: AppColors.textSecondary,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        TextFormField(
          controller: _curvaPotenciaController,
          decoration: InputDecoration(
            labelText: 'Curva de Potencia (JSON)',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            hintText: '{"0": 0.0, "3": 0.1, "4": 0.25, "10": 1.0, "25": 0.0}',
            hintStyle: TextStyle(fontSize: 3.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _mostrarEjemploCurva,
                  icon: Icon(Icons.help_outline, size: 4.sp),
                  tooltip: 'Ver ejemplo',
                ),
                IconButton(
                  onPressed: _validarCurvaPotencia,
                  icon: Icon(Icons.check_circle_outline, size: 4.sp),
                  tooltip: 'Validar JSON',
                ),
              ],
            ),
          ),
          style: TextStyle(fontSize: 3.sp),
          maxLines: 4,
          validator: (value) {
            if (_tipoGeneracion == TipoActivoGeneracion.AEROGENERADOR) {
              if (value?.isEmpty ?? true) {
                return 'La curva de potencia es requerida para aerogeneradores';
              }
              try {
                final parsed = jsonDecode(value!);
                if (parsed is! Map) {
                  return 'Debe ser un objeto JSON válido';
                }
                return null;
              } catch (e) {
                return 'JSON inválido: $e';
              }
            }
            return null;
          },
          onChanged: (value) {
            try {
              if (value.isNotEmpty) {
                _curvaPotenciaParsed = jsonDecode(value);
              }
            } catch (e) {
              _curvaPotenciaParsed = null;
            }
          },
        ),
        
        if (_curvaPotenciaParsed != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 4.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'JSON válido: ${_curvaPotenciaParsed!.length} puntos de velocidad',
                    style: TextStyle(
                      fontSize: 3.sp,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _mostrarEjemploCurva() {
    const ejemplo = '''{
  "0": 0.0,
  "1": 0.0,
  "2": 0.0,
  "3": 0.1,
  "4": 0.25,
  "5": 0.4,
  "6": 0.6,
  "7": 0.75,
  "8": 0.85,
  "9": 0.95,
  "10": 1.0,
  "11": 1.0,
  "12": 1.0,
  "13": 1.0,
  "14": 0.95,
  "15": 0.8,
  "20": 0.5,
  "25": 0.0
}''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ejemplo de Curva de Potencia',
          style: TextStyle(fontSize: 4.sp),
        ),
        content: Container(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formato: "velocidad_viento": factor_potencia\n\n'
                '• Velocidad en m/s (como string)\n'
                '• Factor de 0.0 a 1.0 (0% a 100% de potencia nominal)',
                style: TextStyle(fontSize: 3.5.sp),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: SelectableText(
                  ejemplo,
                  style: TextStyle(
                    fontSize: 3.sp,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(fontSize: 3.5.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              _curvaPotenciaController.text = ejemplo;
              _curvaPotenciaParsed = jsonDecode(ejemplo);
              Navigator.pop(context);
            },
            child: Text('Usar Ejemplo', style: TextStyle(fontSize: 3.5.sp)),
          ),
        ],
      ),
    );
  }

  void _validarCurvaPotencia() {
    if (_curvaPotenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingresa primero la curva de potencia'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final parsed = jsonDecode(_curvaPotenciaController.text);
      if (parsed is! Map) {
        throw Exception('Debe ser un objeto JSON');
      }
      
      int puntos = parsed.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ JSON válido con $puntos puntos de velocidad'),
          backgroundColor: AppColors.success,
        ),
      );
      
      setState(() {
        _curvaPotenciaParsed = Map<String, dynamic>.from(parsed);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON inválido: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _curvaPotenciaParsed = null;
      });
    }
  }

  Widget _buildCamposFotovoltaicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.solar_power, size: 4.sp, color: AppColors.solar),
            SizedBox(width: 8.w),
            Text(
              'Configuración Fotovoltaica',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Inclinación y Azimut
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _inclinacionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Inclinación (°)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  hintText: '30',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  final num? val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 90) {
                    return 'Debe estar entre 0 y 90°';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _azimutController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Azimut (°)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  hintText: '180',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  final num? val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 360) {
                    return 'Debe estar entre 0 y 360°';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Tecnología del panel
        DropdownButtonFormField<String>(
          value: _tecnologiaPanel,
          decoration: InputDecoration(
            labelText: 'Tecnología del Panel',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          items: const [
            DropdownMenuItem(value: 'crystSi', child: Text('Silicio cristalino')),
            DropdownMenuItem(value: 'CIS', child: Text('CIS')),
            DropdownMenuItem(value: 'CdTe', child: Text('CdTe')),
            DropdownMenuItem(value: 'Unknown', child: Text('Desconocida')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _tecnologiaPanel = value);
            }
          },
        ),

        SizedBox(height: 12.h),

        // Pérdidas del sistema y posición de montaje
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _perdidaSistemaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Pérdidas (%)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  hintText: '14',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  final num? val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 50) {
                    return 'Debe estar entre 0 y 50%';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _posicionMontaje,
                decoration: InputDecoration(
                  labelText: 'Tipo de Montaje',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                items: const [
                  DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                  DropdownMenuItem(value: 'tracking', child: Text('Seguimiento')),
                  DropdownMenuItem(value: 'building', child: Text('Integrado')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _posicionMontaje = value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormularioAlmacenamiento() {
    return Column(
      children: [
        // Nombre descriptivo (OPCIONAL)
        TextFormField(
          controller: _nombreAlmacenamientoController,
          decoration: InputDecoration(
            labelText: 'Nombre descriptivo (opcional)',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            helperText: 'Máximo 255 caracteres',
          ),
          style: TextStyle(fontSize: 3.5.sp),
          maxLength: 255,
          // Campo opcional - sin validator
        ),
        
        SizedBox(height: 12.h),
        
        // Capacidad nominal (REQUERIDO)
        TextFormField(
          controller: _capacidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Capacidad nominal (kWh) *',
            labelStyle: TextStyle(fontSize: 3.5.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            helperText: 'Capacidad de almacenamiento en kWh',
          ),
          style: TextStyle(fontSize: 3.5.sp),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Campo requerido';
            final num? val = double.tryParse(value!);
            if (val == null || val <= 0) {
              return 'Debe ser un número positivo';
            }
            return null;
          },
        ),
        
        SizedBox(height: 12.h),
        
        // Potencias de carga y descarga (OPCIONALES)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _potenciaCargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Pot. Carga (kW)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  helperText: 'Opcional',
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num? val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Debe ser positivo';
                    }
                  }
                  return null; // Opcional - puede estar vacío
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _potenciaDescargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Pot. Descarga (kW)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  helperText: 'Opcional',
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num? val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Debe ser positivo';
                    }
                  }
                  return null; // Opcional - puede estar vacío
                },
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12.h),
        
        // Eficiencia y profundidad de descarga (OPCIONALES)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _eficienciaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Eficiencia (%)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  helperText: 'Ej: 85 (opcional)',
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num? val = double.tryParse(value);
                    if (val == null || val <= 0 || val > 100) {
                      return 'Entre 0 y 100%';
                    }
                  }
                  return null; // Opcional - puede estar vacío
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _profundidadDescargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prof. Descarga (%)',
                  labelStyle: TextStyle(fontSize: 3.5.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  helperText: 'Ej: 90 (opcional)',
                ),
                style: TextStyle(fontSize: 3.5.sp),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num? val = double.tryParse(value);
                    if (val == null || val <= 0 || val > 100) {
                      return 'Entre 0 y 100%';
                    }
                  }
                  return null; // Opcional - puede estar vacío
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),
        
        // Texto informativo
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 4.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '* Campo requerido. Los demás campos son opcionales.',
                  style: TextStyle(
                    fontSize: 2.8.sp,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _guardarActivo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_tipoSeleccionado == 'Instalación Fotovoltaica' || _tipoSeleccionado == 'Aerogenerador') {
        await _guardarActivoGeneracion();
      } else if (_tipoSeleccionado == 'Sistema de Almacenamiento') {
        await _guardarActivoAlmacenamiento();
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_tipoSeleccionado ${_esEdicion ? 'actualizado' : 'creado'} correctamente',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al ${_esEdicion ? 'actualizar' : 'crear'} el activo: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _guardarActivoGeneracion() async {
    // Para aerogeneradores, validar que la curva de potencia esté presente
    Map<String, dynamic>? curvaPotenciaMap;
    if (_tipoGeneracion == TipoActivoGeneracion.AEROGENERADOR) {
      if (_curvaPotenciaController.text.isEmpty) {
        throw Exception('La curva de potencia es requerida para aerogeneradores');
      }
      try {
        // Validar que sea JSON válido y obtener el Map
        curvaPotenciaMap = jsonDecode(_curvaPotenciaController.text);
      } catch (e) {
        throw Exception('La curva de potencia debe ser un JSON válido');
      }
    }

    if (_esEdicionGeneracion) {
      // Modo actualización
      await ref.read(activosGeneracionProvider.notifier).updateActivoGeneracion(
        idActivoGeneracion: widget.activoGeneracionEditar!.idActivoGeneracion,
        nombreDescriptivo: _nombreGeneracionController.text,
        fechaInstalacion: widget.activoGeneracionEditar!.fechaInstalacion, // Mantener fecha original
        costeInstalacion_eur: double.parse(_costeController.text),
        vidaUtil_anios: int.parse(_vidaUtilController.text),
        latitud: double.parse(_latitudController.text),
        longitud: double.parse(_longitudController.text),
        potenciaNominal_kWp: double.parse(_potenciaController.text),
        tipo_activo: _tipoGeneracion,
        // Campos específicos para instalaciones fotovoltaicas
        inclinacionGrados: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _inclinacionController.text 
            : null,
        azimutGrados: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _azimutController.text 
            : null,
        tecnologiaPanel: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _tecnologiaPanel 
            : null,
        perdidaSistema: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _perdidaSistemaController.text 
            : null,
        posicionMontaje: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _posicionMontaje 
            : null,
        // Curva de potencia solo para aerogeneradores
        curvaPotencia: curvaPotenciaMap,
      );
    } else {
      // Modo creación
      await ref.read(activosGeneracionProvider.notifier).createActivoGeneracion(
        nombreDescriptivo: _nombreGeneracionController.text,
        fechaInstalacion: DateTime.now(),
        costeInstalacion_eur: double.parse(_costeController.text),
        vidaUtil_anios: int.parse(_vidaUtilController.text),
        latitud: double.parse(_latitudController.text),
        longitud: double.parse(_longitudController.text),
        potenciaNominal_kWp: double.parse(_potenciaController.text),
        idComunidadEnergetica: widget.idComunidad,
        tipo_activo: _tipoGeneracion,
        // Campos específicos para instalaciones fotovoltaicas
        inclinacionGrados: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _inclinacionController.text 
            : null,
        azimutGrados: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _azimutController.text 
            : null,
        tecnologiaPanel: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _tecnologiaPanel 
            : null,
        perdidaSistema: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _perdidaSistemaController.text 
            : null,
        posicionMontaje: _tipoGeneracion == TipoActivoGeneracion.INSTALACION_FOTOVOLTAICA 
            ? _posicionMontaje 
            : null,
        // Curva de potencia solo para aerogeneradores
        curvaPotencia: curvaPotenciaMap,
      );
    }
  }

  Future<void> _guardarActivoAlmacenamiento() async {
    if (_esEdicionAlmacenamiento) {
      // Modo actualización
      await ref.read(activosAlmacenamientoProvider.notifier).updateActivoAlmacenamiento(
        idActivoAlmacenamiento: widget.activoAlmacenamientoEditar!.idActivoAlmacenamiento,
        nombreDescriptivo: _nombreAlmacenamientoController.text.isNotEmpty 
            ? _nombreAlmacenamientoController.text 
            : null,
        capacidadNominal_kWh: double.parse(_capacidadController.text),
        eficienciaCicloCompleto_pct: _eficienciaController.text.isNotEmpty 
            ? double.parse(_eficienciaController.text) 
            : null,
        potenciaMaximaCarga_kW: _potenciaCargaController.text.isNotEmpty 
            ? double.parse(_potenciaCargaController.text) 
            : null,
        potenciaMaximaDescarga_kW: _potenciaDescargaController.text.isNotEmpty 
            ? double.parse(_potenciaDescargaController.text) 
            : null,
        profundidadDescargaMax_pct: _profundidadDescargaController.text.isNotEmpty 
            ? double.parse(_profundidadDescargaController.text) 
            : null,
      );
    } else {
      // Modo creación
      await ref.read(activosAlmacenamientoProvider.notifier).createActivoAlmacenamiento(
        nombreDescriptivo: _nombreAlmacenamientoController.text.isNotEmpty 
            ? _nombreAlmacenamientoController.text 
            : null,
        capacidadNominal_kWh: double.parse(_capacidadController.text),
        eficienciaCicloCompleto_pct: _eficienciaController.text.isNotEmpty 
            ? double.parse(_eficienciaController.text) 
            : null,
        potenciaMaximaCarga_kW: _potenciaCargaController.text.isNotEmpty 
            ? double.parse(_potenciaCargaController.text) 
            : null,
        potenciaMaximaDescarga_kW: _potenciaDescargaController.text.isNotEmpty 
            ? double.parse(_potenciaDescargaController.text) 
            : null,
        profundidadDescargaMax_pct: _profundidadDescargaController.text.isNotEmpty 
            ? double.parse(_profundidadDescargaController.text) 
            : null,
        idComunidadEnergetica: widget.idComunidad,
      );
    }
  }
} 