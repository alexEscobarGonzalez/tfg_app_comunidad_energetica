import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
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

class _RepartirCoeficientesDialogState extends ConsumerState<RepartirCoeficientesDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controladores = {};
  
  // Controladores para coeficientes programados (participante_id -> hora -> controller)
  final Map<int, Map<String, TextEditingController>> _controladoresProgramados = {};
  
  bool _isLoading = false;
  bool _isLoadingInitial = true;
  
  late TabController _tabController;
  
  // Lista de horas del día
  final List<String> _horasDelDia = List.generate(24, (index) => "${index.toString().padLeft(2, '0')}:00");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _inicializarControladores();
    _cargarCoeficientesExistentes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controladores.values) {
      controller.dispose();
    }
    for (final participanteControllers in _controladoresProgramados.values) {
      for (final controller in participanteControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _inicializarControladores() {
    for (final participante in widget.participantes) {
      // Controladores para coeficientes fijos
      _controladores[participante.idParticipante] = TextEditingController(text: '0.0');
      
      // Controladores para coeficientes programados (una entrada por cada hora)
      _controladoresProgramados[participante.idParticipante] = {};
      for (final hora in _horasDelDia) {
        _controladoresProgramados[participante.idParticipante]![hora] = 
            TextEditingController(text: '0.0');
      }
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
          if (coeficienteExistente.tipoReparto == TipoReparto.REPARTO_FIJO) {
            final valor = coeficienteExistente.parametros['valor'] as double? ?? 0.0;
            _controladores[participante.idParticipante]?.text = valor.toStringAsFixed(1);
          } else if (coeficienteExistente.tipoReparto == TipoReparto.REPARTO_PROGRAMADO) {
            // Cargar coeficientes programados
            final parametros = coeficienteExistente.parametros['parametros'] as List<dynamic>? ?? [];
            final valorDefault = coeficienteExistente.parametros['valor_default'] as double? ?? 0.0;
            
            // Inicializar todas las horas con el valor por defecto
            for (final hora in _horasDelDia) {
              _controladoresProgramados[participante.idParticipante]![hora]?.text = 
                  valorDefault.toStringAsFixed(1);
            }
            
            // Actualizar con valores específicos por hora
            for (final franja in parametros) {
              final horaFranja = franja['franja'] as String?;
              final valorFranja = franja['valor'] as double?;
              
              if (horaFranja != null && valorFranja != null && 
                  _controladoresProgramados[participante.idParticipante]!.containsKey(horaFranja)) {
                _controladoresProgramados[participante.idParticipante]![horaFranja]?.text = 
                    valorFranja.toStringAsFixed(1);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error al cargar coeficientes existentes: $e');
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
    
    if (_tabController.index == 0) {
      // Reparto fijo uniforme
      for (final participante in widget.participantes) {
        _controladores[participante.idParticipante]?.text = porcentajeUniforme.toStringAsFixed(1);
      }
    } else {
      // Reparto programado uniforme (mismo valor para todas las horas)
      for (final participante in widget.participantes) {
        for (final hora in _horasDelDia) {
          _controladoresProgramados[participante.idParticipante]![hora]?.text = 
              porcentajeUniforme.toStringAsFixed(1);
        }
      }
    }
    setState(() {});
  }

  void _limpiarTodo() {
    if (_tabController.index == 0) {
      // Limpiar coeficientes fijos
      for (final participante in widget.participantes) {
        _controladores[participante.idParticipante]?.text = '0.0';
      }
    } else {
      // Limpiar coeficientes programados
      for (final participante in widget.participantes) {
        for (final hora in _horasDelDia) {
          _controladoresProgramados[participante.idParticipante]![hora]?.text = '0.0';
        }
      }
    }
    setState(() {});
  }

  double _calcularSumaActual() {
    if (_tabController.index == 0) {
      // Suma de coeficientes fijos
      double suma = 0.0;
      for (final participante in widget.participantes) {
        final valor = double.tryParse(_controladores[participante.idParticipante]?.text ?? '0') ?? 0.0;
        suma += valor;
      }
      return suma;
    } else {
      // Para programados, calcular la suma promedio de todas las horas
      double sumaTotal = 0.0;
      int contadorHoras = 0;
      
      for (final hora in _horasDelDia) {
        double sumaHora = 0.0;
        for (final participante in widget.participantes) {
          final valor = double.tryParse(
            _controladoresProgramados[participante.idParticipante]![hora]?.text ?? '0'
          ) ?? 0.0;
          sumaHora += valor;
        }
        sumaTotal += sumaHora;
        contadorHoras++;
      }
      
      return contadorHoras > 0 ? sumaTotal / contadorHoras : 0.0;
    }
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
        List<String> errores = [];
        int exitosos = 0;

        if (_tabController.index == 0) {
          // Guardar coeficientes fijos
          final suma = _calcularSumaActual();
          if ((suma - 100.0).abs() > 0.1) {
            throw Exception('La suma de porcentajes debe ser exactamente 100%. Actual: ${suma.toStringAsFixed(1)}%');
          }

          for (final participante in widget.participantes) {
            final porcentaje = double.tryParse(_controladores[participante.idParticipante]?.text ?? '0') ?? 0.0;
            
            try {
              if (porcentaje > 0) {
                await CoeficienteRepartoApiService.createOrUpdateCoeficienteFijo(
                  idParticipante: participante.idParticipante,
                  valor: porcentaje,
                );
                exitosos++;
              } else {
                await CoeficienteRepartoApiService.deleteCoeficienteByParticipante(
                  participante.idParticipante
                );
                exitosos++;
              }
            } catch (e) {
              errores.add('${participante.nombre}: ${e.toString()}');
            }
          }
        } else {
          // Guardar coeficientes programados
          for (final participante in widget.participantes) {
            try {
              // Construir mapa de coeficientes por hora
              Map<String, double> coeficientesProgramados = {};
              bool tieneValores = false;
              
              for (final hora in _horasDelDia) {
                final valor = double.tryParse(
                  _controladoresProgramados[participante.idParticipante]![hora]?.text ?? '0'
                ) ?? 0.0;
                
                if (valor > 0) {
                  tieneValores = true;
                }
                coeficientesProgramados[hora] = valor;
              }
              
              if (tieneValores) {
                await CoeficienteRepartoApiService.createOrUpdateCoeficienteProgramado(
                  idParticipante: participante.idParticipante,
                  coeficientesProgramados: coeficientesProgramados,
                );
                exitosos++;
              } else {
                await CoeficienteRepartoApiService.deleteCoeficienteByParticipante(
                  participante.idParticipante
                );
                exitosos++;
              }
            } catch (e) {
              errores.add('${participante.nombre}: ${e.toString()}');
            }
          }
        }

        if (!mounted) return;
        
        if (errores.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coeficientes guardados exitosamente ($exitosos participantes)'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (exitosos > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$exitosos guardados, ${errores.length} errores. Revisa los detalles.'),
              backgroundColor: AppColors.warning,
            ),
          );
          
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
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
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
              
              // Tabs para tipo de reparto
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: AppColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.equalizer, size: 20),
                      text: 'Reparto Fijo',
                    ),
                    Tab(
                      icon: Icon(Icons.schedule, size: 20),
                      text: 'Reparto Programado',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Contenido de tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRepartoFijo(),
                    _buildRepartoProgramado(),
                  ],
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

  Widget _buildRepartoFijo() {
    final suma = _calcularSumaActual();
    
    return Column(
      children: [
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
              return _buildParticipanteFieldFijo(participante);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRepartoProgramado() {
    return Column(
      children: [
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
        
        // Info sobre coeficientes programados
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Configure diferentes porcentajes para cada hora del día. El total por hora debe sumar 100%.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tabla de coeficientes programados
        Expanded(
          child: _buildTablaProgramada(),
        ),
      ],
    );
  }

  Widget _buildTablaProgramada() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // Header de la tabla
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Hora',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...widget.participantes.map((participante) => Expanded(
                  child: Text(
                    participante.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Total',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Contenido scrolleable de la tabla
          Expanded(
            child: ListView.builder(
              itemCount: _horasDelDia.length,
              itemBuilder: (context, index) {
                final hora = _horasDelDia[index];
                return _buildFilaHoraria(hora, index % 2 == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaHoraria(String hora, bool isEven) {
    // Calcular total para esta hora
    double totalHora = 0.0;
    for (final participante in widget.participantes) {
      final valor = double.tryParse(
        _controladoresProgramados[participante.idParticipante]![hora]?.text ?? '0'
      ) ?? 0.0;
      totalHora += valor;
    }
    
    // Color según si suma 100%
    Color totalColor = AppColors.textSecondary;
    if ((totalHora - 100.0).abs() < 0.1) {
      totalColor = AppColors.success;
    } else if (totalHora > 100.0) {
      totalColor = AppColors.error;
    } else if (totalHora > 0) {
      totalColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[50] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Hora
          SizedBox(
            width: 60,
            child: Text(
              hora,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          // Campos para cada participante
          ...widget.participantes.map((participante) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: TextFormField(
                controller: _controladoresProgramados[participante.idParticipante]![hora],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 10),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {}),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0 || val > 100) {
                    return 'Error';
                  }
                  return null;
                },
              ),
            ),
          )),
          // Total de la hora
          SizedBox(
            width: 60,
            child: Text(
              '${totalHora.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: totalColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipanteFieldFijo(Participante participante) {
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