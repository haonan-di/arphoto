/// DCT 编码器 — 将水印嵌入图片

import 'dart:typed_data';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

import 'utils/dct_algorithm.dart';
import 'utils/watermark_payload.dart';

/// DCT 编码器
class DCTEncoder {
  /// 编码水印到图片
  ///
  /// [imageBytes] 图片像素数据（灰度图，每个像素 0-255）
  /// [width] 图片宽度
  /// [height] 图片高度
  /// [payload] 水印载荷
  /// [strength] 嵌入强度（越大越鲁棒，但视觉影响也越大）
  ///
  /// 返回带水印的像素数据
  static Uint8List encode({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required WatermarkPayload payload,
    double strength = 8.0,
  }) {
    // 1. 将元数据编码为 64bit 字节
    final watermarkBytes = WatermarkPayloadCodec.encode(
      isPublic: payload.isPublic,
      contentId: payload.contentId,
      creatorId: payload.creatorId,
    );
    final bits = WatermarkPayloadCodec.bytesToBits(watermarkBytes);

    // 2. 分块处理（8×8 块）
    final output = Uint8List.fromList(imageBytes);
    final blockCountX = width ~/ 8;
    final blockCountY = height ~/ 8;

    // 需要嵌入的块数（每块嵌入 2 bit 至中频系数对）
    final blocksNeeded = (bits.length / 2).ceil();

    if (blockCountX * blockCountY < blocksNeeded) {
      throw DCTException(
        code: 2001,
        message: 'Image too small to embed watermark',
      );
    }

    for (int b = 0; b < blocksNeeded; b++) {
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

      // 3. 电平移位 [-128, 127]
      final shifted = DCTAlgorithm.levelShift(block);

      // 4. 前向 DCT
      final dctCoeffs = DCTAlgorithm.forwardDCT1D(shifted);

      // 5. 嵌入 bit 到中频系数
      final bitPair = (b * 2 < bits.length)
          ? bits.sublist(b * 2, (b * 2 + 2).clamp(0, bits.length))
          : [0, 0];
      final embedded = WatermarkPayloadCodec.embedBits(
        dctCoeffs,
        bitPair,
        strength: strength,
      );

      // 6. 逆 DCT
      final inverseCoeffs = DCTAlgorithm.inverseDCT1D(embedded);

      // 7. 电平移位回 [0, 255]
      final pixelBlock = DCTAlgorithm.unlevelShift(inverseCoeffs);

      // 8. 写回
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          output[(by * 8 + row) * width + (bx * 8 + col)] =
              pixelBlock[row * 8 + col].round().clamp(0, 255);
        }
      }
    }

    return output;
  }

  /// 从图片文件路径编码
  static Future<Uint8List> encodeFromFile({
    required String imagePath,
    required int contentId,
    required int creatorId,
    required bool isPublic,
    double strength = 8.0,
  }) async {
    // MVP 阶段：读取文件 + 编码
    // 后续使用 image 库的 decodeImage()
    final payload = WatermarkPayload(
      isPublic: isPublic,
      contentId: contentId,
      creatorId: creatorId,
    );

    // 模拟编码
    await Future.delayed(const Duration(milliseconds: 100));
    return Uint8List(0); // 替换为实际实现
  }
}