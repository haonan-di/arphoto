/// 存储 Provider 抽象层

import 'dart:async';

import 'package:arphoto/shared/types.dart';

/// 本地存储 Provider
class LocalStorageProvider extends StorageProvider {
  final String basePath;

  LocalStorageProvider({required this.basePath});

  @override
  Future<void> delete(String contentId) async {
    // MVP 阶段：模拟删除
    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<bool> exists(String contentId) async {
    // MVP 阶段：返回 false
    return false;
  }

  @override
  Future<List<int>> pullContent(String contentId) async {
    // MVP 阶段：返回空
    await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }

  @override
  Future<void> pushContent(String contentId, List<int> bytes) async {
    // MVP 阶段：模拟保存
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

/// WebDAV 存储 Provider（预留）
class WebDAVStorageProvider extends StorageProvider {
  final String baseUrl;
  final String username;
  final String password;

  WebDAVStorageProvider({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  @override
  Future<void> delete(String contentId) async {
    throw UnimplementedError('WebDAV provider not implemented yet');
  }

  @override
  Future<bool> exists(String contentId) async {
    throw UnimplementedError('WebDAV provider not implemented yet');
  }

  @override
  Future<List<int>> pullContent(String contentId) async {
    throw UnimplementedError('WebDAV provider not implemented yet');
  }

  @override
  Future<void> pushContent(String contentId, List<int> bytes) async {
    throw UnimplementedError('WebDAV provider not implemented yet');
  }
}

/// S3 存储 Provider（预留）
class S3StorageProvider extends StorageProvider {
  final String bucket;
  final String region;
  final String accessKey;
  final String secretKey;

  S3StorageProvider({
    required this.bucket,
    required this.region,
    required this.accessKey,
    required this.secretKey,
  });

  @override
  Future<void> delete(String contentId) async {
    throw UnimplementedError('S3 provider not implemented yet');
  }

  @override
  Future<bool> exists(String contentId) async {
    throw UnimplementedError('S3 provider not implemented yet');
  }

  @override
  Future<List<int>> pullContent(String contentId) async {
    throw UnimplementedError('S3 provider not implemented yet');
  }

  @override
  Future<void> pushContent(String contentId, List<int> bytes) async {
    throw UnimplementedError('S3 provider not implemented yet');
  }
}