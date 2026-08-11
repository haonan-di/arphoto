/// 相机配置

import 'package:arphoto/shared/types.dart';

/// 相机配置（扩展自 shared 的 CameraConfig）
class CameraConfig {
  final CameraResolution resolution;
  final CameraLensDirection lensDirection;
  final bool enableFrameStream;
  final bool enableFlash;
  final double zoom;
  final double focusMode; // 0=auto, 1=macro, 2=infinity

  const CameraConfig({
    this.resolution = CameraResolution.medium,
    this.lensDirection = CameraLensDirection.back,
    this.enableFrameStream = true,
    this.enableFlash = false,
    this.zoom = 1.0,
    this.focusMode = 0,
  });

  /// 从 Bridge 参数解析
  factory CameraConfig.fromParams(Map<String, dynamic> params) {
    return CameraConfig(
      resolution: _parseResolution(params['resolution']),
      lensDirection: _parseLensDirection(params['lensDirection']),
      enableFrameStream: params['enableFrameStream'] as bool? ?? true,
      enableFlash: params['enableFlash'] as bool? ?? false,
      zoom: (params['zoom'] as num?)?.toDouble() ?? 1.0,
      focusMode: (params['focusMode'] as num?)?.toDouble() ?? 0,
    );
  }

  static CameraResolution _parseResolution(dynamic value) {
    if (value == null) return CameraResolution.medium;
    switch (value.toString()) {
      case 'low':
        return CameraResolution.low;
      case 'high':
        return CameraResolution.high;
      case 'ultraHigh':
        return CameraResolution.ultraHigh;
      default:
        return CameraResolution.medium;
    }
  }

  static CameraLensDirection _parseLensDirection(dynamic value) {
    if (value == null) return CameraLensDirection.back;
    switch (value.toString()) {
      case 'front':
        return CameraLensDirection.front;
      default:
        return CameraLensDirection.back;
    }
  }
}

/// 相机状态
enum CameraState {
  initializing,
  ready,
  capturing,
  streaming,
  error,
  disposed,
}

/// 相机能力查询结果
class CameraInfo {
  final String cameraId;
  final String name;
  final CameraLensDirection lensDirection;
  final List<CameraResolution> supportedResolutions;
  final bool hasFlash;
  final bool hasFocus;

  const CameraInfo({
    required this.cameraId,
    required this.name,
    required this.lensDirection,
    this.supportedResolutions = const [],
    this.hasFlash = false,
    this.hasFocus = true,
  });
}