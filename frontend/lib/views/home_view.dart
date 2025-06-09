import 'package:flutter/material.dart';
import 'package:frontend/models/usuario.dart';

class HomeView extends StatelessWidget {
  final Usuario? usuario;
  
  const HomeView({
    super.key,
    this.usuario,
  });
  @override
  Widget build(BuildContext context) {
    // If no user was passed, try to get it from the route arguments
    final user = usuario ?? (ModalRoute.of(context)?.settings.arguments as Usuario?);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad Energética'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¡Bienvenido a la Comunidad Energética!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (user != null)
              Text(
                'Hola, ${user.nombre}',
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40),
            
            // Dashboard Principal
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.green, size: 32),
                title: const Text(
                  'Dashboard Principal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                subtitle: const Text('Accede al panel completo de gestión'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección de Comunidades Energéticas
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Tarjeta para Crear Comunidad
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_business),
                title: const Text('Crear Comunidad Energética'),
                subtitle: const Text('Registrar una nueva comunidad energética'),
                onTap: () {
                  Navigator.pushNamed(context, '/crear-comunidad');
                },
              ),
            ),
            
            const SizedBox(height: 8),
              // Tarjeta para Ver Comunidades
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Mis Comunidades'),
                subtitle: const Text('Ver y gestionar mis comunidades'),
                onTap: () {
                  Navigator.pushNamed(context, '/comunidades');
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Otras funciones (por implementar)
            const Text(
              'Gestión de Participantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Participantes'),
                subtitle: const Text('Gestionar participantes (próximamente)'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función disponible próximamente')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
