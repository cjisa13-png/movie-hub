import '../../domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.key,
    required super.name,
    required super.type,
    required super.site,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json['id'] ?? '') as String,
      key: (json['key'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      site: (json['site'] ?? '') as String,
    );
  }
}
