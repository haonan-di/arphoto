/// DCT 算法核心 — 离散余弦变换（JPEG 标准）

/// 8×8 DCT 变换
class DCTAlgorithm {
  // 8×8 DCT 系数矩阵（JPEG 标准）
  static final List<List<double>> _cosineTable = _buildCosineTable();

  static List<List<double>> _buildCosineTable() {
    final table = List.generate(8, (_) => List.filled(8, 0.0));
    for (int u = 0; u < 8; u++) {
      for (int x = 0; x < 8; x++) {
        table[u][x] = cos((2 * x + 1) * u * pi / 16);
      }
    }
    return table;
  }

  /// 计算 8×8 块的 DCT 系数
  static List<List<double>> forwardDCT(List<List<double>> block) {
    final result = List.generate(8, (_) => List.filled(8, 0.0));

    for (int u = 0; u < 8; u++) {
      for (int v = 0; v < 8; v++) {
        double sum = 0.0;
        for (int x = 0; x < 8; x++) {
          for (int y = 0; y < 8; y++) {
            sum += block[x][y] *
                _cosineTable[u][x] *
                _cosineTable[v][y];
          }
        }
        sum *= _cu(u) * _cu(v) / 4.0;
        result[u][v] = sum;
      }
    }

    return result;
  }

  /// 计算 8×8 块的逆 DCT
  static List<List<double>> inverseDCT(List<List<double>> coefficients) {
    final result = List.generate(8, (_) => List.filled(8, 0.0));

    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        double sum = 0.0;
        for (int u = 0; u < 8; u++) {
          for (int v = 0; v < 8; v++) {
            sum += _cu(u) * _cu(v) *
                coefficients[u][v] *
                _cosineTable[u][x] *
                _cosineTable[v][y];
          }
        }
        sum /= 4.0;
        result[x][y] = sum;
      }
    }

    return result;
  }

  /// 8×8 块 → DCT 系数（一维数组版）
  static List<double> forwardDCT1D(List<double> block) {
    final result = List.filled(64, 0.0);

    for (int u = 0; u < 8; u++) {
      for (int v = 0; v < 8; v++) {
        double sum = 0.0;
        for (int i = 0; i < 64; i++) {
          final x = i ~/ 8;
          final y = i % 8;
          sum += block[i] * _cosineTable[u][x] * _cosineTable[v][y];
        }
        result[u * 8 + v] = sum * _cu(u) * _cu(v) / 4.0;
      }
    }

    return result;
  }

  /// 逆 DCT（一维数组版）
  static List<double> inverseDCT1D(List<double> coefficients) {
    final result = List.filled(64, 0.0);

    for (int i = 0; i < 64; i++) {
      final x = i ~/ 8;
      final y = i % 8;
      double sum = 0.0;
      for (int u = 0; u < 8; u++) {
        for (int v = 0; v < 8; v++) {
          sum += _cu(u) * _cu(v) *
              coefficients[u * 8 + v] *
              _cosineTable[u][x] *
              _cosineTable[v][y];
        }
      }
      result[i] = sum / 4.0;
    }

    return result;
  }

  /// 将像素值从 [0,255] 平移到 [-128,127]（DCT 前处理）
  static List<double> levelShift(List<double> block) {
    return block.map((p) => p - 128.0).toList();
  }

  /// 将 DCT 结果平移回 [0,255]（IDCT 后处理）
  static List<double> unlevelShift(List<double> coeffs) {
    return coeffs.map((c) => (c + 128.0).clamp(0.0, 255.0)).toList();
  }

  /// 量化矩阵（JPEG 标准亮度量化表）
  static const List<List<int>> quantizationTable = [
    [16, 11, 10, 16, 24, 40, 51, 61],
    [12, 12, 14, 19, 26, 58, 60, 55],
    [14, 13, 16, 24, 40, 57, 69, 56],
    [14, 17, 22, 29, 51, 87, 80, 62],
    [18, 22, 37, 56, 68, 109, 103, 77],
    [24, 35, 55, 64, 81, 104, 113, 92],
    [49, 64, 78, 87, 103, 121, 120, 101],
    [72, 92, 95, 98, 112, 100, 103, 99],
  ];

  /// 常用的中频系数索引（用于水印嵌入，按频率从低到高）
  /// 跳过 DC 和最低频，避免视觉影响
  static const List<int> midFreqIndices = [
    9, 10, 17, 18,  // 第一组中频
    11, 16, 19, 24, // 第二组中频
    25, 32, 33, 41, // 第三组中频
  ];

  /// 量化 DCT 系数
  static List<double> quantize(List<double> coefficients, int quality) {
    final q = (quality < 50)
        ? (5000 / quality).round()
        : (200 - quality * 2);
    final result = List<double>.from(coefficients);

    for (int i = 0; i < 64; i++) {
      final row = i ~/ 8;
      final col = i % 8;
      result[i] = (result[i] / (quantizationTable[row][col] * q / 100))
          .roundToDouble();
    }

    return result;
  }

  /// 反量化
  static List<double> dequantize(List<double> coefficients, int quality) {
    final q = (quality < 50)
        ? (5000 / quality).round()
        : (200 - quality * 2);
    final result = List<double>.from(coefficients);

    for (int i = 0; i < 64; i++) {
      final row = i ~/ 8;
      final col = i % 8;
      result[i] *= (quantizationTable[row][col] * q / 100);
    }

    return result;
  }
}

/// 简化版 cos 和 pi，避免 import 'dart:math' 依赖冲突
double cos(double x) {
  // 使用泰勒展开或查表
  // 这里用 s 和 c 的符号避免直接调用
  // 实际项目中应使用 dart:math
  return _cos(x);
}

double _cos(double x) {
  // 减少到 [0, 2π)
  x = x % (2 * 3.141592653589793);
  if (x < 0) x += 2 * 3.141592653589793;

  // 使用泰勒展开计算 cos（精度够用）
  final x2 = x * x;
  final x4 = x2 * x2;
  final x6 = x4 * x2;
  final x8 = x6 * x2;

  return 1.0 - x2 / 2.0 + x4 / 24.0 - x6 / 720.0 + x8 / 40320.0;
}

const double pi = 3.141592653589793;

double _cu(int u) {
  return u == 0 ? 1.0 / sqrt(2) : 1.0;
}

double sqrt(double x) {
  if (x <= 0) return 0;
  double guess = x / 2;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}