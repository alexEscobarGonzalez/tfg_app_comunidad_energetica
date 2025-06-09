import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/views/auth_wrapper.dart';
import 'package:frontend/views/login_view.dart';
import 'package:frontend/views/register_view.dart';
import 'package:frontend/views/auto_login_view.dart';
import 'package:frontend/views/home_view.dart';
import 'package:frontend/views/comunidad_content_view.dart';
import 'package:frontend/views/detalle_comunidad_view.dart';
import 'package:frontend/views/lista_activos_energeticos_view.dart';
import 'package:frontend/views/dashboard_view.dart';
import 'package:frontend/views/gestion_contratos_view.dart';
import 'package:frontend/views/gestion_datos_operativos_view.dart';
import 'package:frontend/views/resultados_simulacion_view.dart';
import 'package:frontend/views/simulacion_view.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit( 
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Comunidad Energética TFG',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginView(),
            '/register': (context) => const RegisterView(),
            '/auto-login': (context) => const AutoLoginView(),
            '/home': (context) => const HomeView(),
            '/dashboard': (context) => const DashboardView(),
            '/comunidades': (context) => const ComunidadContentView(),
          },
          onGenerateRoute: (settings) {
            final routeName = settings.name ?? '';
            final parts = routeName.split('/');
            
            // Ruta resultados simulación (más específica primero)
            if (routeName.contains('/resultados')) {
              if (parts.length >= 5 && parts[1] == 'comunidad' && parts[3] == 'simulacion') {
                final idComunidad = int.tryParse(parts[2]);
                final idSimulacion = int.tryParse(parts[4]);
                if (idComunidad != null && idSimulacion != null) {
                  return MaterialPageRoute(
                    builder: (context) => ResultadosSimulacionView(
                      idComunidad: idComunidad,
                      nombreComunidad: 'Comunidad $idComunidad',
                    ),
                  );
                }
              }
            }
            
            if (routeName.contains('/simulacion/crear')) {
              if (parts.length >= 3 && parts[1] == 'comunidad') {
                final idComunidad = int.tryParse(parts[2]);
                if (idComunidad != null) {
                  return MaterialPageRoute(
                    builder: (context) => const SimulacionView(),
                  );
                }
              }
            }
            
            // Ruta lista simulaciones - SISTEMA REFACTORIZADO
            if (routeName.contains('/simulaciones')) {
              if (parts.length >= 3 && parts[1] == 'comunidad') {
                final idComunidad = int.tryParse(parts[2]);
                if (idComunidad != null) {
                  return MaterialPageRoute(
                    builder: (context) => const SimulacionView(),
                  );
                }
              }
            }
            
            // Ruta lista activos energéticos
            if (routeName.contains('/activos-energeticos')) {
              if (parts.length >= 3 && parts[1] == 'comunidad') {
                final idComunidad = int.tryParse(parts[2]);
                if (idComunidad != null) {
                  return MaterialPageRoute(
                    builder: (context) => ListaActivosEnergeticosView(
                      idComunidad: idComunidad,
                      nombreComunidad: 'Comunidad $idComunidad',
                    ),
                  );
                }
              }
            }
            
            // Ruta lista participantes - redirigir al dashboard
            if (routeName.contains('/participantes')) {
              if (parts.length >= 3 && parts[1] == 'comunidad') {
                final idComunidad = int.tryParse(parts[2]);
                if (idComunidad != null) {
                  return MaterialPageRoute(
                    builder: (context) => const DashboardView(),
                  );
                }
              }
            }
            
            // Ruta gestión de coeficientes de comunidad
            if (routeName.contains('/coeficientes')) {
              if (parts.length >= 3 && parts[1] == 'comunidad') {
                final idComunidad = int.tryParse(parts[2]);
                if (idComunidad != null) {
                  return MaterialPageRoute(
                    builder: (context) => const DashboardView(),
                  );
                }
              }
            }
            
            // Ruta gestión de contratos de participante
            if (routeName.contains('/contratos')) {
              if (parts.length >= 3 && parts[1] == 'participante') {
                final idParticipante = int.tryParse(parts[2]);
                if (idParticipante != null) {
                  return MaterialPageRoute(
                    builder: (context) => GestionContratosView(
                      idParticipante: idParticipante,
                    ),
                  );
                }
              }
            }
            
            // Ruta gestión de datos de consumo por participante
            if (routeName.contains('/datos_consumo')) {
              if (parts.length >= 3 && parts[1] == 'participante') {
                final idParticipante = int.tryParse(parts[2]);
                if (idParticipante != null) {
                  return MaterialPageRoute(
                    builder: (context) => GestionDatosOperativosView(
                      idParticipanteInicial: idParticipante,
                    ),
                  );
                }
              }
            }
            
            // Ruta crear participante - redirigir al dashboard
            if (routeName == '/participante/crear') {
              return MaterialPageRoute(
                builder: (context) => const DashboardView(),
              );
            }
            
            // Ruta gestión de datos operativos
            if (routeName == '/gestion-datos-operativos') {
              return MaterialPageRoute(
                builder: (context) => GestionDatosOperativosView(),
              );
            }
            
            // Ruta detalle comunidad (debe ir al final para evitar conflictos)
            if (routeName.startsWith('/comunidad/') && parts.length == 3 && parts[2].isNotEmpty) {
              final idComunidad = int.tryParse(parts[2]);
              
              if (idComunidad != null) {
                return MaterialPageRoute(
                  builder: (context) => DetalleComunidadView(idComunidad: idComunidad),
                );
              }
            }
            
            return null;
          },
        );
      },
    );
  }
}
