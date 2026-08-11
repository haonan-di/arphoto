/// DCT 解码器 — 从图片中提取水印

import 'dart:typed_data';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

import 'utils/dct_algorithm.dart';
import 'utils/watermark_payload.dart';

/// DCT 解码器
class DCTDecoder {
  /// 从像素数据中解码水印
  ///
  /// [imageBytes] 灰度像素数据
  /// [width] 宽度
  /// [height] 高度
  ///
  /// 返回水印载荷，未检测到时返回 null
  static WatermarkPayload? decode({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) {
    final blockCountX = width ~/ 8;
    final blockCountY = height ~/ 8;

    if (blockCountX == 0 || blockCountY == 0) return null;

    // 从多个块中提取 bit，取多数投票
    final allBits = <List<int>>[];
    final maxBlocks = (blockCountX * blockCountY).clamp(0, 24); // 最多 24 块

    for (int b = 0; b < maxBlocks; b++) {
      final bx = b % blockCountX;
      final by = b ~/ blockCountX;

      // 提取 8×8 块
      final block = List.filled(64, 0.0);
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          block[row * 8 + col] =
              imageBytes[(by * 8 + row) * width + (bx * 8 + col)].toDouble();
        }
      }

      // 电平移位
      final shifted = DCTAlgorithm.levelShift(block);

      // 前向 DCT
      final dctCoeffs = DCTAlgorithm.forwardDCT1D(shifted);

      // 提取 bit
      final bits = WatermarkPayloadCodec.extractBits(
        dctCoeffs,
        bitCount: 64,
      );
      allBits.add(bits);
    }

    if (allBits.isEmpty) return null;

    // 多数投票
    final votedBits = _majorityVote(allBits, 64);

    try {
      // bit → 字节 → payload
      final bytes = WatermarkPayloadCodec.bitsToBytes(votedBits);
      final decoded = WatermarkPayloadCodec.decode(bytes);

      // 校验：contentId 应为正数
      if (decoded.contentId <= 0) return null;

      return WatermarkPayload(
        isPublic: decoded.isPublic,
        contentId: decoded.contentId,
        creatorId: decoded.creatorId,
      );
    } catch (_) {
      return null;
    }
  }

  /// 带重试的解码（针对不同帧）
  static WatermarkPayload? decodeWithRetry({
    required List<Uint8List> frames,
    required int width,
    required int height,
    int maxRetries = 3,
  }) {
    for (int i = 0; i < maxRetries && i < frames.length; i++) {
      final result = decode(
        imageBytes: frames[i],
        width: width,
        height: height,
      );
      if (result != null) return result;
    }
    return null;
  }

  /// 多数投票
  static List<int> _majorityVote(List<List<int>> allBits, int length) {
    final result = List.filled(length, 0);

    for (int i = 0; i < length; i++) {
      int sum = 0;
      for (final bits in allBits) {
        if (i < bits.length) {
          sum += bits[i];
        }
      }
      result[i] = sum > allBits.length ~/ 2 ? 1 : 0;
    }

    return result;
  }

  /// 校验水印完整性（简单校验和）
  static bool verifyChecksum(List<int> bytes) {
    if (bytes.length < 8) return false;
    // 校验：第 0-6 字节的 XOR 应等于第 7 字节
    int checksum = 0;
    for (int i = 0; i < 7; i++) {
      checksum ^= bytes[i];
    }
    return checksum == bytes[7];
  }
}