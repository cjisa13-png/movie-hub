import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

/// Pantalla donde el usuario introduce su clave de API de TMDB directamente
/// dentro de la app. Se muestra al arrancar si todavía no hay clave guardada.
///
/// Así el mismo .apk sirve para cualquiera: cada persona pega su clave aquí.
class ApiKeySetupScreen extends StatefulWidget {
  /// Si es true, se muestra un botón para volver atrás (modo "editar clave").
  final bool canGoBack;

  const ApiKeySetupScreen({super.key, this.canGoBack = false});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    setState(() => _saving = true);
    await context.read<SettingsProvider>().saveApiKey(key);
    // El árbol raíz reacciona al cambio y muestra la app automáticamente.
    if (widget.canGoBack && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: widget.canGoBack
          ? AppBar(
              title: const Text('Cambiar clave'),
              backgroundColor: AppColors.darkBackground,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                      children: [
                        TextSpan(
                            text: 'MOVIE',
                            style: TextStyle(color: AppColors.primary)),
                        TextSpan(
                            text: ' HUB',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Para funcionar, la app necesita una clave gratuita de TMDB '
                '(la base de datos de películas). Solo tienes que hacerlo una vez.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 28),

              _step('1', 'Entra en esta web y crea una cuenta gratis:'),
              const SizedBox(height: 6),
              _selectableUrl('https://www.themoviedb.org/signup'),
              const SizedBox(height: 20),

              _step('2',
                  'Ve a: Ajustes (tu avatar) → Settings → API y solicita una clave. '
                  'Elige la opción "Developer".'),
              const SizedBox(height: 6),
              _selectableUrl('https://www.themoviedb.org/settings/api'),
              const SizedBox(height: 20),

              _step('3',
                  'Copia tu "API Key (v3 auth)" y pégala aquí abajo:'),
              const SizedBox(height: 14),

              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pega aquí tu clave de TMDB',
                  prefixIcon: const Icon(Icons.vpn_key_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Pegar del portapapeles',
                    icon: const Icon(Icons.paste_rounded),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _controller.text = data!.text!.trim();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Empezar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.primary,
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }

  /// Muestra una URL seleccionable (para copiar y pegar en el navegador).
  Widget _selectableUrl(String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 38),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                url,
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 13.5),
              ),
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text('Enlace copiado')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded,
                    size: 18, color: AppColors.darkTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
