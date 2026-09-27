import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/theme/app_colors.dart';

/// Reproductor de tráiler de YouTube embebido DENTRO de la app,
/// usando el paquete `youtube_player_flutter`. El usuario no sale de la app
/// para ver el tráiler.
///
/// Recibe la [videoKey] (el id del vídeo de YouTube, ej. "dQw4w9WgXcQ")
/// obtenido del endpoint /videos de TMDB.
class TrailerPlayer extends StatefulWidget {
  final String videoKey;

  const TrailerPlayer({super.key, required this.videoKey});

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
        ),
      ),
    );
  }
}
