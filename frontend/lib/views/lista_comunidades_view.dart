import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comunidad_energetica.dart';
import 'package:frontend/models/enums/tipo_estrategia_excedentes.dart';
import 'package:frontend/providers/comunidad_energetica_provider.dart';
import 'package:frontend/providers/user_provider.dart';

class ListaComunidadesView extends ConsumerStatefulWidget {
  const ListaComunidadesView({super.key});

  @override
  ConsumerState<ListaComunidadesView> createState() => _ListaComunidadesViewState();
}

class _ListaComunidadesViewState extends ConsumerState<ListaComunidadesView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarComunidades();
  }

  Future<void> _cargarComunidades() async {
    final usuario = ref.read(userProvider);
    if (usuario != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Usar el notifier para cargar las comunidades
        final comunidadesNotifier = ref.read(comunidadesNotifierProvider.notifier);
        await comunidadesNotifier.loadComunidadesUsuario(usuario.idUsuario);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar comunidades: ${e.toString()}')),
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
    // Escuchar los cambios en la lista de comunidades
    final comunidades = ref.watch(comunidadesNotifierProvider);
    final usuario = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Comunidades Energéticas'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : comunidades.isEmpty 
          ? _buildEmptyState()
          : _buildComunidadesList(comunidades),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/crear-comunidad');
          if (result != null && mounted) {
            // Recargar las comunidades cuando volvamos
            _cargarComunidades();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [          Icon(
            Icons.business,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes comunidades energéticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primera comunidad tocando el botón +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComunidadesList(List<ComunidadEnergetica> comunidades) {
    return RefreshIndicator(
      onRefresh: _cargarComunidades,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: comunidades.length,
        itemBuilder: (context, index) {
          final comunidad = comunidades[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                comunidad.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Lat: ${comunidad.latitud.toStringAsFixed(6)}, Long: ${comunidad.longitud.toStringAsFixed(6)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flash_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getEstrategiaExcedentesString(comunidad.tipoEstrategiaExcedentes),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),              onTap: () {
                // Navegar a la vista de detalles de la comunidad
                Navigator.of(context).pushNamed(
                  '/comunidad/${comunidad.idComunidadEnergetica}',
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  String _getEstrategiaExcedentesString(TipoEstrategiaExcedentes estrategia) {
    switch (estrategia) {
      case TipoEstrategiaExcedentes.INDIVIDUAL_SIN_EXCEDENTES:
        return 'Individual sin excedentes';
      case TipoEstrategiaExcedentes.COLECTIVO_SIN_EXCEDENTES:
        return 'Colectivo sin excedentes';
      case TipoEstrategiaExcedentes.INDIVIDUAL_EXCEDENTES_COMPENSACION:
        return 'Individual con excedentes y compensación';
      case TipoEstrategiaExcedentes.COLECTIVO_EXCEDENTES_COMPENSACION_RED_EXTERNA:
        return 'Colectivo con excedentes y compensación externa';
    }
  }
}
