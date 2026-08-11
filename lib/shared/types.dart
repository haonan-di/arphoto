/// 原生能力组件共享类型定义

/// 相机配置
class CameraConfig {
  final CameraResolution resolution;
  final CameraLensDirection lensDirection;
  final bool enableFrameStream;

  const CameraConfig({
    this.resolution = CameraResolution.medium,
    this.lensDirection = CameraLensDirection.back,
    this.enableFrameStream = true,
  });
}

enum CameraResolution { low, medium, high, ultraHigh }

enum CameraLensDirection { back, front }

/// 相机帧数据
class Frame {
  final List<int> bytes;
  final int width;
  final int height;
  final int format; // 0=YUV420, 1=NV21, 2=BGRA8888

  const Frame({
    required this.bytes,
    required this.width,
    required this.height,
    this.format = 0,
  });
}

/// 矩形区域（用于照片检测结果）
class DetectedRect {
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;

  const DetectedRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.confidence = 1.0,
  });
}

/// 水印载荷
class WatermarkPayload {
  final bool isPublic;
  final int contentId;
  final int creatorId;

  const WatermarkPayload({
    required this.isPublic,
    required this.contentId,
    required this.creatorId,
  });

  Map<String, dynamic> toJson() => {
        'isPublic': isPublic,
        'contentId': contentId,
        'creatorId': creatorId,
      };

  factory WatermarkPayload.fromJson(Map<String, dynamic> json) =>
      WatermarkPayload(
        isPublic: json['isPublic'] as bool,
        contentId: json['contentId'] as int,
        creatorId: json['creatorId'] as int,
      );
}

/// 内容元数据
class ContentMeta {
  final String contentId;
  final String creatorId;
  final String title;
  final String fileType;
  final String? filePath;
  final String? thumbnailPath;
  final String permissions;
  final int createdAt;
  final int updatedAt;

  const ContentMeta({
    required this.contentId,
    required this.creatorId,
    this.title = '',
    this.fileType = 'live_photo',
    this.filePath,
    this.thumbnailPath,
    this.permissions = 'private',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'creatorId': creatorId,
        'title': title,
        'fileType': fileType,
        'filePath': filePath,
        'thumbnailPath': thumbnailPath,
        'permissions': permissions,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

/// AR 配置
class ARConfig {
  final String contentId;
  final String videoPath;
  final List<EmojiConfig> emojis;
  final bool autoPlay;

  const ARConfig({
    required this.contentId,
    required this.videoPath,
    this.emojis = const [],
    this.autoPlay = true,
  });
}

/// Emoji 配置
class EmojiConfig {
  final String emoji;
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final double opacity;

  const EmojiConfig({
    required this.emoji,
    this.x = 0.0,
    this.y = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });
}

/// 内容保存请求
class ContentSaveRequest {
  final String contentId;
  final String creatorId;
  final String title;
  final String fileType;
  final String filePath;
  final String? thumbnailPath;
  final String permissions;

  const ContentSaveRequest({
    required this.contentId,
    required this.creatorId,
    this.title = '',
    this.fileType = 'live_photo',
    required this.filePath,
    this.thumbnailPath,
    this.permissions = 'private',
  });
}

/// 存储 Provider 抽象接口
abstract class StorageProvider {
  Future<List<int>> pullContent(String contentId);
  Future<void> pushContent(String contentId, List<int> bytes);
  Future<bool> exists(String contentId);
  Future<void> delete(String contentId);
}