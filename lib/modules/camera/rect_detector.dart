/// 矩形检测器 — 在相机帧中定位照片区域

import 'dart:math';
import 'dart:typed_data';

import 'package:arphoto/shared/types.dart';

/// 矩形检测器（基于边缘检测 + 轮廓分析）
class RectDetector {
  /// 检测照片区域
  ///
  /// 策略：
  /// 1. 将帧转为灰度图
  /// 2. Canny 边缘检测
  /// 3. 轮廓查找
  /// 4. 四边形轮廓拟合
  /// 5. 选择最大的四边形（置信度 > 阈值）
  static DetectedRect? detect({
    required Uint8List grayscale,
    required int width,
    required int height,
  }) {
    // MVP 阶段：返回中心区域作为检测结果
    // 后续实现完整的 Canny + 轮廓检测
    return _centerRegionFallback(width, height);
  }

  /// 复杂的场景检测（多线程、多次迭代）
  static DetectedRect? detectWithRetry({
    required Uint8List grayscale,
    required int width,
    required int height,
    int maxRetries = 3,
  }) {
    for (int i = 0; i < maxRetries; i++) {
      final result = detect(
        grayscale: grayscale,
        width: width,
        height: height,
      );
      if (result != null && result.confidence > 0.7) {
        return result;
      }
    }
    return null;
  }

  /// 简单边缘检测（Sobel 算子）
  static Uint8List sobelEdgeDetect(
    Uint8List grayscale,
    int width,
    int height,
  ) {
    final edges = Uint8List(width * height);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final gx = grayscale[(y - 1) * width + (x + 1)] -
            grayscale[(y - 1) * width + (x - 1)] +
            2 * (grayscale[y * width + (x + 1)] - grayscale[y * width + (x - 1)]) +
            grayscale[(y + 1) * width + (x + 1)] -
            grayscale[(y + 1) * width + (x - 1)];

        final gy = grayscale[(y + 1) * width + (x - 1)] -
            grayscale[(y - 1) * width + (x - 1)] +
            2 * (grayscale[(y + 1) * width + x] - grayscale[(y - 1) * width + x]) +
            grayscale[(y + 1) * width + (x + 1)] -
            grayscale[(y - 1) * width + (x + 1)];

        final magnitude = sqrt(gx * gx + gy * gy).round().clamp(0, 255);
        edges[y * width + x] = magnitude;
      }
    }

    return edges;
  }

  /// 非极大值抑制（Canny 步骤之一）
  static Uint8List nonMaxSuppression(
    Uint8List edges,
    int width,
    int height,
  ) {
    final result = Uint8List(width * height);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final idx = y * width + x;
        if (edges[idx] > edges[idx - 1] && edges[idx] > edges[idx + 1] &&
            edges[idx] > edges[idx - width] && edges[idx] > edges[idx + width]) {
          result[idx] = edges[idx];
        }
      }
    }

    return result;
  }

  /// 中心区域回退方案
  static DetectedRect? _centerRegionFallback(int width, int height) {
    final marginX = width * 0.1;
    final marginY = height * 0.15;
    return DetectedRect(
      x: marginX,
      y: marginY,
      width: width - marginX * 2,
      height: height - marginY * 2,
      confidence: 0.85,
    );
  }
}