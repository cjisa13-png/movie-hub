/// Vídeo asociado a una película (tráiler, teaser, clip...).
/// Solo nos interesan los alojados en YouTube para el reproductor embebido.
class Video {
  final String id;
  final String key; // ID del vídeo de YouTube
  final String name;
  final String type; // "Trailer", "Teaser", "Clip"...
  final String site; // "YouTube", "Vimeo"...

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.type,
    required this.site,
  });

  bool get isYoutube => site.toLowerCase() == 'youtube';
  bool get isTrailer => type.toLowerCase() == 'trailer';
}
