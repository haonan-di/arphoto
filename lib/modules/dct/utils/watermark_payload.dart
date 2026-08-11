/// 水印载荷编解码

import 'dct_algorithm.dart';

/// 水印载荷（64bit = 8 字节）
///
/// 布局：
/// | 权限标记(1) | 内容 ID(31) | 创建者 ID(32) |
///
/// 总 64bit，嵌入 DCT 中频系数
class WatermarkPayloadCodec {
  /// 将元数据编码为 64bit 水印字节
  static List<int> encode({
    required bool isPublic,
    required int contentId,
    required int creatorId,
  }) {
    final bytes = List.filled(8, 0);

    // 权限标记位（第 1 bit）
    bytes[0] = isPublic ? 0x80 : 0x00;

    // 内容 ID（31 bit，占第 1-3 字节 + 第 4 字节的 7 bit）
    final maskedContentId = contentId & 0x7FFFFFFF; // 31 bit
    bytes[0] |= (maskedContentId >> 24) & 0x7F; // 高 7 bit
    bytes[1] = (maskedContentId >> 16) & 0xFF;
    bytes[2] = (maskedContentId >> 8) & 0xFF;
    bytes[3] = maskedContentId & 0xFF;

    // 创建者 ID（32 bit，占第 4-7 字节）
    bytes[4] = (creatorId >> 24) & 0xFF;
    bytes[5] = (creatorId >> 16) & 0xFF;
    bytes[6] = (creatorId >> 8) & 0xFF;
    bytes[7] = creatorId & 0xFF;

    return bytes;
  }

  /// 从 64bit 字节解码水印
  static ({bool isPublic, int contentId, int creatorId}) decode(
      List<int> bytes) {
    if (bytes.length < 8) {
      throw ArgumentError('Watermark payload must be at least 8 bytes');
    }

    // 权限标记
    final isPublic = (bytes[0] & 0x80) != 0;

    // 内容 ID（31 bit）
    final contentId = ((bytes[0] & 0x7F) << 24) |
        (bytes[1] << 16) |
        (bytes[2] << 8) |
        bytes[3];

    // 创建者 ID（32 bit）
    final creatorId = (bytes[4] << 24) |
        (bytes[5] << 16) |
        (bytes[6] << 8) |
        bytes[7];

    return (
      isPublic: isPublic,
      contentId: contentId,
      creatorId: creatorId,
    );
  }

  /// 将 bit 序列嵌入到 DCT 中频系数中
  ///
  /// 使用差分编码：通过调整两个相邻中频系数的差值来编码 1 bit
  /// 0: 系数[a] < 系数[b]
  /// 1: 系数[a] > 系数[b]
  static List<double> embedBits(
    List<double> dctCoefficients,
    List<int> bits, {
    double strength = 8.0,
  }) {
    final result = List<double>.from(dctCoefficients);
    final indices = DCTAlgorithm.midFreqIndices;

    for (int i = 0; i < bits.length && i * 2 + 1 < indices.length; i++) {
      final idxA = indices[i * 2];
      final idxB = indices[i * 2 + 1];
      final avg = (result[idxA] + result[idxB]) / 2;

      if (bits[i] == 1) {
        // 编码 1: 系数[a] > 系数[b]
        result[idxA] = avg + strength;
        result[idxB] = avg - strength;
      } else {
        // 编码 0: 系数[a] < 系数[b]
        result[idxA] = avg - strength;
        result[idxB] = avg + strength;
      }
    }

    return result;
  }

  /// 从 DCT 中频系数提取 bit 序列
  static List<int> extractBits(
    List<double> dctCoefficients, {
    int bitCount = 64,
  }) {
    final bits = <int>[];
    final indices = DCTAlgorithm.midFreqIndices;

    for (int i = 0; i < bitCount && i * 2 + 1 < indices.length; i++) {
      final idxA = indices[i * 2];
      final idxB = indices[i * 2 + 1];
      bits.add(dctCoefficients[idxA] > dctCoefficients[idxB] ? 1 : 0);
    }

    return bits;
  }

  /// 将 bit 序列转为字节（每 8 bit 一组）
  static List<int> bitsToBytes(List<int> bits) {
    final bytes = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      int byte = 0;
      for (int j = 0; j < 8 && i + j < bits.length; j++) {
        if (bits[i + j] == 1) {
          byte |= (0x80 >> j);
        }
      }
      bytes.add(byte);
    }
    return bytes;
  }

  /// 将字节转为 bit 序列
  static List<int> bytesToBits(List<int> bytes) {
    final bits = <int>[];
    for (final byte in bytes) {
      for (int j = 0; j < 8; j++) {
        bits.add((byte >> (7 - j)) & 1);
      }
    }
    return bits;
  }
}