import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/participante.dart';
import '../models/activo_generacion.dart';
import '../models/enums/tipo_reparto.dart';
import '../services/coeficiente_reparto_api_service.dart';

class RepartirCoeficientesDialog extends ConsumerStatefulWidget {
  final int idComunidad;
  final List<Participante> participantes;
  final List<ActivoGeneracion> activosGeneracion;
  final double energiaTotalDisponible;

  const RepartirCoeficientesDialog({
    super.key,
    required this.idComunidad,
    required this.participantes,
    required this.activosGeneracion,
    required this.energiaTotalDisponible,
  });

  @override
  ConsumerState<RepartirCoeficientesDialog> createState() => _RepartirCoeficientesDialogState();
}

class _RepartirCoeficientesDialogState extends ConsumerState<RepartirCoeficientesDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controladores = {};
  
  TipoReparto _tipoRepartoSeleccionado = TipoReparto.REPARTO_FIJO;
  bool _isLoading = false;
  bool _isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    _cargarCoeficientesExistentes();
  }

  @override
  void dispose() {
    for (final controller in _controladores.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _inicializarControladores() {
    for (final participante in widget.participantes) {
      _controladores[participante.idParticipante] = TextEditingController(text: '0.0');
    }
  }

  Future<void> _cargarCoeficientesExistentes() async {
    try {
      setState(() {
        _isLoadingInitial = true;
      });

      for (final participante in widget.participantes) {
        final coeficienteExistente = await CoeficienteRepartoApiService.getCoeficienteByParticipante(
          participante.idParticipante
        );
        
        if (coeficienteExistente != null) {
          final valor = coeficienteExistente.parametros['valor'] as double? ?? 0.0;
          _controladores[participante.idParticipante]?.text = valor.toStringAsFixed(1);
        }
      }
    } catch (e) {
      print('Error al cargar coeficientes existentes: $e');
      // No mostrar error al usuario, simplemente usar valores por defecto
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  void _repartirUniforme() {
    if (widget.participantes.isEmpty) return;
    
    final porcentajeUniforme = (100.0 / widget.participantes.length);
    for (final participante in widget.participantes) {
      _controladores[participante.idParticipante]?.text = porcentajeUniforme.toStringAsFixed(1);
    }
    setState(() {});
  }

  void _limpiarTodo() {
    for (final participante in widget.participantes) {
      _controladores[participante.idParticipante]?.text = '0.0';
    }
    setState(() {});
  }

  double _calcularSumaActual() {
    double suma = 0.0;
    for (final participante in widget.participantes) {
      final valor = double.tryParse(_controladores[participante.idParticipante]?.text ?? '0') ?? 0.0;
      suma += valor;
    }
    return suma;
  }

  Color _getColorSuma() {
    final suma = _calcularSumaActual();
    if ((suma - 100.0).abs() < 0.1) {
      return AppColors.success;
    } else if (suma < 100.0) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  Future<void> _guardarCoeficientes() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final suma = _calcularSumaActual();
        if ((suma - 100.0).abs() > 0.1) {
          throw Exception('La suma de porcentajes debe ser exactamente 100%. Actual: ${suma.toStringAsFixed(1)}%');
        }

        List<String> errores = [];
        int exitosos = 0;

        for (final participante in widget.participantes) {
          final porcentaje = double.tryParse(_controladores[participante.idParticipante]?.text ?? '0') ?? 0.0;
          
          try {
            if (porcentaje > 0) {
              // Crear o actualizar coeficiente usando la nueva API 1:1
              await CoeficienteRepartoApiService.createOrUpdateCoeficienteFijo(
                idParticipante: participante.idParticipante,
                valor: porcentaje,
              );
              exitosos++;
            } else {
              // Si el porcentaje es 0, eliminar el coeficiente si existe
              await CoeficienteRepartoApiService.deleteCoeficienteByParticipante(
                participante.idParticipante
              );
              exitosos++;
            }
          } catch (e) {
            errores.add('${participante.nombre}: ${e.toString()}');
          }
        }

        if (!mounted) return;
        
        if (errores.isEmpty) {
          // Éxito total
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coeficientes guardados exitosamente ($exitosos participantes)'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (exitosos > 0) {
          // Éxito parcial
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$exitosos guardados, ${errores.length} errores. Revisa los detalles.'),
              backgroundColor: AppColors.warning,
            ),
          );
          
          // Mostrar detalles de errores
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Errores al guardar'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: errores.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $error', style: const TextStyle(fontSize: 12)),
                  )).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        } else {
          // Todos fallaron
          throw Exception('No se pudo guardar ningún coeficiente. Errores: ${errores.join(', ')}');
        }
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
    if (_isLoadingInitial) {
      return AlertDialog(
        content: SizedBox(
          width: 200,
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Cargando coeficientes...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final suma = _calcularSumaActual();
    
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.pie_chart, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Repartir Coeficientes'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información de la energía total
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Energía Total a Repartir:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.energiaTotalDisponible.toStringAsFixed(2)} kW/kWh',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Botones de acción rápida
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _repartirUniforme,
                      icon: const Icon(Icons.equalizer, size: 16),
                      label: const Text('Reparto Uniforme'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _limpiarTodo,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpiar Todo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Indicador de suma
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _getColorSuma().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: _getColorSuma().withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total asignado:',
                      style: TextStyle(
                        color: _getColorSuma(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${suma.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getColorSuma(),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Lista de participantes
              Expanded(
                child: ListView.builder(
                  itemCount: widget.participantes.length,
                  itemBuilder: (context, index) {
                    final participante = widget.participantes[index];
                    return _buildParticipanteField(participante);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardarCoeficientes,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Guardar Coeficientes'),
        ),
      ],
    );
  }

  Widget _buildParticipanteField(Participante participante) {
    final porcentaje = double.tryParse(_controladores[participante.idParticipante]?.text ?? '0') ?? 0.0;
    final energiaAsignada = (widget.energiaTotalDisponible * porcentaje / 100.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.info,
              radius: 16,
              child: Text(
                participante.nombre.isNotEmpty 
                    ? participante.nombre[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participante.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'ID: ${participante.idParticipante}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _controladores[participante.idParticipante],
                decoration: const InputDecoration(
                  labelText: '%',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0 || val > 100) {
                    return 'Entre 0-100';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${energiaAsignada.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'kW/kWh',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
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
} 