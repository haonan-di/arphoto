/// CameraModule — 相机帧引擎

import 'dart:async';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

import 'camera_config.dart';

/// 帧回调
typedef FrameCallback = void Function(Frame frame);

/// 相机模块核心接口
abstract class ICameraModule {
  /// 启动相机预览
  Future<void> startPreview(CameraConfig config);

  /// 停止相机
  Future<void> stopPreview();

  /// 单帧拍照（返回图片路径）
  Future<String> capturePhoto();

  /// 注册帧回调（用于 DCT 实时解码）
  void onFrame(FrameCallback callback);

  /// 矩形检测（在当前帧中定位照片区域）
  DetectedRect? detectPhotoRegion(Frame frame);

  /// 当前相机状态
  CameraState get state;

  /// 获取可用相机列表
  Future<List<CameraInfo>> getAvailableCameras();

  /// 切换摄像头
  Future<void> switchCamera(CameraLensDirection direction);
}

/// CameraModule 实现
class CameraModule implements ICameraModule {
  CameraState _state = CameraState.initializing;
  FrameCallback? _frameCallback;
  CameraConfig? _currentConfig;
  StreamSubscription? _frameSubscription;

  @override
  CameraState get state => _state;

  @override
  Future<void> startPreview(CameraConfig config) async {
    _currentConfig = config;
    _state = CameraState.initializing;

    try {
      // MVP 阶段：模拟相机启动
      // 后续集成 camera 插件的 CameraController
      await Future.delayed(const Duration(milliseconds: 300));
      _state = CameraState.ready;

      if (config.enableFrameStream) {
        _startFrameStream();
      }
    } catch (e) {
      _state = CameraState.error;
      throw CameraException(
        code: 1003,
        message: 'Failed to start preview: $e',
      );
    }
  }

  @override
  Future<void> stopPreview() async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    _frameCallback = null;
    _state = CameraState.disposed;
  }

  @override
  Future<String> capturePhoto() async {
    if (_state != CameraState.ready && _state != CameraState.streaming) {
      throw CameraException(
        code: 1003,
        message: 'Camera not ready',
      );
    }

    _state = CameraState.capturing;
    try {
      // MVP 阶段：模拟拍照
      // 后续使用 camera 插件的 takePicture()
      await Future.delayed(const Duration(milliseconds: 200));
      _state = CameraState.ready;
      return '/path/to/captured_photo.jpg';
    } catch (e) {
      _state = CameraState.error;
      throw CameraException(
        code: 1003,
        message: 'Capture failed: $e',
      );
    }
  }

  @override
  void onFrame(FrameCallback callback) {
    _frameCallback = callback;
  }

  @override
  DetectedRect? detectPhotoRegion(Frame frame) {
    // MVP 阶段：返回模拟的矩形检测结果
    // 后续实现基于边缘检测或轮廓分析的矩形定位
    // 典型结果：照片区域占画面 60-80%
    if (frame.width == 0 || frame.height == 0) return null;

    final marginX = frame.width * 0.1;
    final marginY = frame.height * 0.15;
    return DetectedRect(
      x: marginX,
      y: marginY,
      width: frame.width - marginX * 2,
      height: frame.height - marginY * 2,
      confidence: 0.85,
    );
  }

  @override
  Future<List<CameraInfo>> getAvailableCameras() async {
    // MVP 阶段：返回模拟的相机列表
    return [
      const CameraInfo(
        cameraId: 'back_camera',
        name: 'Back Camera',
        lensDirection: CameraLensDirection.back,
        hasFlash: true,
        hasFocus: true,
      ),
      const CameraInfo(
        cameraId: 'front_camera',
        name: 'Front Camera',
        lensDirection: CameraLensDirection.front,
        hasFlash: false,
        hasFocus: true,
      ),
    ];
  }

  @override
  Future<void> switchCamera(CameraLensDirection direction) async {
    final config = _currentConfig ?? const CameraConfig();
    await stopPreview();
    await startPreview(CameraConfig(
      resolution: config.resolution,
      lensDirection: direction,
      enableFrameStream: config.enableFrameStream,
    ));
  }

  /// 模拟帧流（MVP 阶段）
  void _startFrameStream() {
    _state = CameraState.streaming;
    // MVP 阶段：模拟帧回调
    // 后续使用 camera 插件的 startImageStream()
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_frameCallback != null && _state == CameraState.streaming) {
        _frameCallback!(Frame(
          bytes: List.filled(640 * 480 * 3, 128),
          width: 640,
          height: 480,
          format: 0,
        ));
        // 递归模拟连续帧流
        _startFrameStream();
      }
    });
  }

  /// 注册 Bridge 处理器
  Map<String, dynamic> registerBridgeHandlers() {
    return {
      'camera.startPreview': (params) async {
        final config = CameraConfig.fromParams(params);
        await startPreview(config);
        return {'state': state.name};
      },
      'camera.stopPreview': (params) async {
        await stopPreview();
        return {'state': state.name};
      },
      'camera.capturePhoto': (params) async {
        final path = await capturePhoto();
        return {'path': path};
      },
      'camera.getCameras': (params) async {
        final cameras = await getAvailableCameras();
        return cameras
            .map((c) => {
                  'cameraId': c.cameraId,
                  'name': c.name,
                  'lensDirection': c.lensDirection.name,
                  'hasFlash': c.hasFlash,
                })
            .toList();
      },
      'camera.switchCamera': (params) async {
        final direction = params['direction'] == 'front'
            ? CameraLensDirection.front
            : CameraLensDirection.back;
        await switchCamera(direction);
        return {'state': state.name};
      },
    };
  }

  void dispose() {
    _frameSubscription?.cancel();
    _frameCallback = null;
    _state = CameraState.disposed;
  }
}