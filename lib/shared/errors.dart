/// 错误类型定义

class ModuleException implements Exception {
  final String module;
  final int code;
  final String message;

  const ModuleException({
    required this.module,
    required this.code,
    required this.message,
  });

  @override
  String toString() => '[$module] Error #$code: $message';

  Map<String, dynamic> toJson() => {
        'module': module,
        'code': code,
        'message': message,
      };
}

class CameraException extends ModuleException {
  const CameraException({
    required int code,
    required String message,
  }) : super(module: 'Camera', code: code, message: message);

  static const permissionDenied = CameraException(
    code: 1001,
    message: 'Camera permission denied',
  );
  static const noCamera = CameraException(
    code: 1002,
    message: 'No camera available',
  );
  static const captureFailed = CameraException(
    code: 1003,
    message: 'Capture failed',
  );
  static const frameStreamError = CameraException(
    code: 1004,
    message: 'Frame stream error',
  );
}

class DCTException extends ModuleException {
  const DCTException({
    required int code,
    required String message,
  }) : super(module: 'DCT', code: code, message: message);

  static const encodeFailed = DCTException(
    code: 2001,
    message: 'Watermark encode failed',
  );
  static const decodeFailed = DCTException(
    code: 2002,
    message: 'Watermark decode failed',
  );
  static const noWatermark = DCTException(
    code: 2003,
    message: 'No watermark found',
  );
  static const invalidPayload = DCTException(
    code: 2004,
    message: 'Invalid watermark payload',
  );
}

class StorageException extends ModuleException {
  const StorageException({
    required int code,
    required String message,
  }) : super(module: 'Storage', code: code, message: message);

  static const notFound = StorageException(
    code: 3001,
    message: 'Content not found',
  );
  static const saveFailed = StorageException(
    code: 3002,
    message: 'Save failed',
  );
  static const deleteFailed = StorageException(
    code: 3003,
    message: 'Delete failed',
  );
  static const providerNotFound = StorageException(
    code: 3004,
    message: 'Storage provider not found',
  );
}

class ARException extends ModuleException {
  const ARException({
    required int code,
    required String message,
  }) : super(module: 'AR', code: code, message: message);

  static const videoNotFound = ARException(
    code: 4001,
    message: 'Video file not found',
  );
  static const renderFailed = ARException(
    code: 4002,
    message: 'AR render failed',
  );
  static const playFailed = ARException(
    code: 4003,
    message: 'Video play failed',
  );
}

class BridgeException extends ModuleException {
  const BridgeException({
    required int code,
    required String message,
  }) : super(module: 'Bridge', code: code, message: message);

  static const unknownAction = BridgeException(
    code: 5001,
    message: 'Unknown action',
  );
  static const invalidParams = BridgeException(
    code: 5002,
    message: 'Invalid parameters',
  );
  static const timeout = BridgeException(
    code: 5003,
    message: 'Bridge call timeout',
  );
}