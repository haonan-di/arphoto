/// DCTModule — 水印编解码核心

import 'dart:async';
import 'dart:typed_data';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

import 'dct_encoder.dart';
import 'dct_decoder.dart';

/// DCT 模块接口
abstract class IDCTModule {
  /// 编码：传入图片路径 + 元数据，返回带水印图片路径
  Future<String> encode({
    required String imagePath,
    required int contentId,
    required int creatorId,
    required bool isPublic,
  });

  /// 解码：传入帧像素数据，返回水印载荷
  Future<WatermarkPayload?> decode(Frame frame);

  /// 解码（图片文件模式）
  Future<WatermarkPayload?> decodeFromImage(String imagePath);
}

/// DCT 模块实现
class DCTModule implements IDCTModule {
  bool _isProcessing = false;

  /// 当前是否正在处理
  bool get isProcessing => _isProcessing;

  @override
  Future<String> encode({
    required String imagePath,
    required int contentId,
    required int creatorId,
    required bool isPublic,
  }) async {
    _isProcessing = true;

    try {
      // MVP 阶段：模拟编码
      // 后续使用 image 库读取图片 + DCT 编码
      await Future.delayed(const Duration(milliseconds: 200));

      _isProcessing = false;
      return imagePath.replaceAll('.jpg', '_watermarked.jpg');
    } catch (e) {
      _isProcessing = false;
      throw DCTException(
        code: 2001,
        message: 'Encode failed: $e',
      );
    }
  }

  @override
  Future<WatermarkPayload?> decode(Frame frame) async {
    _isProcessing = true;

    try {
      // 1. 帧预处理（灰度化）
      final gray = _frameToGrayscale(frame);

      // 2. DCT 解码
      final payload = await _runDecode(
        DCTDecoder.decode,
        _DecodeArgs(gray, frame.width, frame.height),
      );

      _isProcessing = false;
      return payload;
    } catch (e) {
      _isProcessing = false;
      throw DCTException(
        code: 2002,
        message: 'Decode failed: $e',
      );
    }
  }

  @override
  Future<WatermarkPayload?> decodeFromImage(String imagePath) async {
    _isProcessing = true;

    try {
      // MVP 阶段：模拟解码
      // 后续使用 image 库读取图片 + DCT 解码
      await Future.delayed(const Duration(milliseconds: 150));

      _isProcessing = false;
      return null;
    } catch (e) {
      _isProcessing = false;
      throw DCTException(
        code: 2002,
        message: 'Decode from image failed: $e',
      );
    }
  }

  /// 帧转灰度图
  Uint8List _frameToGrayscale(Frame frame) {
    // 简单 YUV → 灰度
    final ySize = frame.width * frame.height;
    if (frame.bytes.length >= ySize) {
      return Uint8List.fromList(frame.bytes.sublist(0, ySize));
    }
    return Uint8List.fromList(frame.bytes);
  }

  /// 注册 Bridge 处理器
  Map<String, dynamic> registerBridgeHandlers() {
    return {
      'dct.encode': (params) async {
        final path = await encode(
          imagePath: params['imagePath'] as String,
          contentId: params['contentId'] as int,
          creatorId: params['creatorId'] as int,
          isPublic: params['isPublic'] as bool? ?? true,
        );
        return {'path': path};
      },
      'dct.decode': (params) async {
        // 帧数据通过 Bridge 传参（base64 编码）
        // 实际实现中应使用共享内存或文件路径
        return {'payload': null};
      },
      'dct.status': (params) async {
        return {'isProcessing': _isProcessing};
      },
    };
  }

  void dispose() {
    _isProcessing = false;
  }
}

/// 用于 compute 的解码参数
class _DecodeArgs {
  final Uint8List imageBytes;
  final int width;
  final int height;

  const _DecodeArgs(this.imageBytes, this.width, this.height);
}

/// 在 isolate 中执行解码
WatermarkPayload? _runDecode(
  WatermarkPayload? Function({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) fn,
  _DecodeArgs args,
) {
  // MVP 阶段：同步执行（不启动 isolate）
  // 后续使用 Flutter 的 compute() 或自定义 isolate
  return fn(
    imageBytes: args.imageBytes,
    width: args.width,
    height: args.height,
  );
}