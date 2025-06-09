import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/participante.dart';
import '../providers/participante_provider.dart';

class EditarParticipanteDialog extends ConsumerStatefulWidget {
  final Participante participante;

  const EditarParticipanteDialog({
    super.key,
    required this.participante,
  });

  @override
  ConsumerState<EditarParticipanteDialog> createState() => _EditarParticipanteDialogState();
}

class _EditarParticipanteDialogState extends ConsumerState<EditarParticipanteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar con los datos actuales del participante
    _nombreController.text = widget.participante.nombre;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _updateParticipante() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Verificar si realmente hay cambios
        final nuevoNombre = _nombreController.text.trim();
        if (nuevoNombre == widget.participante.nombre) {
          // No hay cambios, cerrar sin hacer nada
          Navigator.of(context).pop(false);
          return;
        }

        // Actualizar participante usando el provider
        final success = await ref.read(participantesProvider.notifier).updateParticipante(
          idParticipante: widget.participante.idParticipante,
          nombre: nuevoNombre,
        );
        
        if (!mounted) return;
        
        if (success) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Participante actualizado con éxito'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Cerrar el dialog
          Navigator.of(context).pop(true); // Retornar true para indicar éxito
        } else {
          throw Exception('No se pudo actualizar el participante');
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
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit, color: AppColors.warning),
          SizedBox(width: 8),
          Text('Editar Participante'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Información del participante actual
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.warning,
                        radius: 16,
                        child: Text(
                          widget.participante.nombre.isNotEmpty 
                              ? widget.participante.nombre[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editando:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.participante.nombre,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${widget.participante.idParticipante}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.warning.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del participante',
                    hintText: 'Ejemplo: Juan Pérez García',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    if (value.trim().length > 100) {
                      return 'El nombre no puede exceder 100 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Información adicional
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Por ahora solo puedes editar el nombre del participante. Información adicional se podrá modificar desde la vista de detalle.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateParticipante,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
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
              : const Text('Actualizar'),
        ),
      ],
    );
  }
} 