/// 帧处理器 — 帧数据转换与前期处理

import 'dart:typed_data';

import 'package:arphoto/shared/types.dart';

/// 帧处理结果
class ProcessedFrame {
  final Frame original;
  final Uint8List grayscale;
  final int stride;

  const ProcessedFrame({
    required this.original,
    required this.grayscale,
    required this.stride,
  });
}

/// 帧处理器
class FrameProcessor {
  /// YUV420 → 灰度图
  static Uint8List toGrayscale(Frame frame) {
    final bytes = Uint8List.fromList(frame.bytes);

    if (frame.format == 0) {
      // YUV420: Y 平面就是灰度图
      final ySize = frame.width * frame.height;
      return bytes.sublist(0, ySize);
    }

    // NV21: 提取 Y 分量
    if (frame.format == 1) {
      final ySize = frame.width * frame.height;
      return bytes.sublist(0, ySize);
    }

    // BGRA8888: 转灰度
    if (frame.format == 2) {
      final gray = Uint8List(frame.width * frame.height);
      for (int i = 0; i < gray.length; i++) {
        final b = bytes[i * 4];
        final g = bytes[i * 4 + 1];
        final r = bytes[i * 4 + 2];
        // 标准 luminosity 公式
        gray[i] = ((0.299 * r + 0.587 * g + 0.114 * b)).round().clamp(0, 255);
      }
      return gray;
    }

    throw ArgumentError('Unsupported frame format: ${frame.format}');
  }

  /// 预处理帧：去噪 + 增强对比度
  static Uint8List preprocess(Uint8List grayscale, int width, int height) {
    // MVP 阶段：简单直方图均衡化
    return _histogramEqualize(grayscale);
  }

  /// 直方图均衡化
  static Uint8List _histogramEqualize(Uint8List input) {
    if (input.isEmpty) return input;

    // 计算直方图
    final hist = List.filled(256, 0);
    for (final pixel in input) {
      hist[pixel]++;
    }

    // 计算累积分布
    final total = input.length;
    final cdf = List.filled(256, 0.0);
    cdf[0] = hist[0] / total;
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + hist[i] / total;
    }

    // 映射
    final output = Uint8List(input.length);
    for (int i = 0; i < input.length; i++) {
      output[i] = (cdf[input[i]] * 255).round().clamp(0, 255);
    }

    return output;
  }

  /// 透视校正（四点变换）
  static Uint8List perspectiveCorrect({
    required Uint8List input,
    required int width,
    required int height,
    required DetectedRect rect,
  }) {
    // MVP 阶段：简单裁剪
    final x = rect.x.round();
    final y = rect.y.round();
    final w = rect.width.round();
    final h = rect.height.round();

    if (x < 0 || y < 0 || x + w > width || y + h > height) {
      return input;
    }

    final output = Uint8List(w * h);
    for (int row = 0; row < h; row++) {
      for (int col = 0; col < w; col++) {
        output[row * w + col] = input[(y + row) * width + (x + col)];
      }
    }

    return output;
  }

  /// 提取帧中用于 DCT 解码的 8×8 块
  static List<Uint8List> extract8x8Blocks(
    Uint8List grayscale,
    int width,
    int height,
  ) {
    final blocks = <Uint8List>[];
    final blockCountX = width ~/ 8;
    final blockCountY = height ~/ 8;

    for (int by = 0; by < blockCountY; by++) {
      for (int bx = 0; bx < blockCountX; bx++) {
        final block = Uint8List(64);
        for (int row = 0; row < 8; row++) {
          for (int col = 0; col < 8; col++) {
            block[row * 8 + col] =
                grayscale[(by * 8 + row) * width + (bx * 8 + col)];
          }
        }
        blocks.add(block);
      }
    }

    return blocks;
  }
}