import 'package:flutter/material.dart';
import 'package:frontend/views/create_user_view.dart';
import 'package:frontend/views/home_view.dart';
import 'package:frontend/views/crear_comunidad_view.dart';
import 'package:frontend/views/lista_comunidades_view.dart';
import 'package:frontend/views/detalle_comunidad_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comunidad Energética',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),      initialRoute: '/',
      routes: {
        '/': (context) => const CreateUserView(),
        '/home': (context) => const HomeView(),
        '/crear-comunidad': (context) => const CrearComunidadView(),
        '/comunidades': (context) => const ListaComunidadesView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/comunidad/') ?? false) {
          // Extraer el ID de la comunidad de la ruta
          final idComunidad = int.tryParse(
            settings.name!.replaceAll('/comunidad/', '')
          );
          
          if (idComunidad != null) {
            return MaterialPageRoute(
              builder: (context) => DetalleComunidadView(idComunidad: idComunidad),
            );
          }
        }
        return null;
      },
    );  }
}
