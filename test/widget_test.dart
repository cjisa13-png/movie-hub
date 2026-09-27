// Test básico de humo ("smoke test").
//
// Comprueba que la pantalla inicial de configuración de la clave de API
// se construye correctamente sin lanzar errores.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movie_hub/presentation/providers/settings_provider.dart';
import 'package:movie_hub/presentation/screens/api_key_setup_screen.dart';

void main() {
  testWidgets('La pantalla de configuración de clave se muestra',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MaterialApp(home: ApiKeySetupScreen()),
      ),
    );

    // Debe aparecer el botón para empezar.
    expect(find.text('Empezar'), findsOneWidget);
  });
}
