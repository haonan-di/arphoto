/// StorageModule — 存储抽象层

import 'dart:async';

import 'package:arphoto/shared/errors.dart';
import 'package:arphoto/shared/types.dart';

import 'database/database_helper.dart';
import 'database/models/content.dart';
import 'file_manager.dart';
import 'providers/storage_provider.dart';

/// 存储模块接口
abstract class IStorageModule {
  /// 保存内容
  Future<String> saveContent(ContentSaveRequest request);

  /// 查询内容
  Future<ContentMeta?> getContent(String contentId);

  /// 获取所有内容列表
  Future<List<ContentMeta>> listContents({int page, int pageSize});

  /// 删除内容
  Future<void> deleteContent(String contentId);

  /// 注册额外的 Provider
  Future<void> registerProvider(StorageProvider provider);
}

/// 存储模块实现
class StorageModule implements IStorageModule {
  late final DatabaseHelper _db;
  late final FileManager _fileManager;
  LocalStorageProvider? _localProvider;
  final List<StorageProvider> _extraProviders = [];

  bool _initialized = false;

  /// 初始化
  Future<void> init(String basePath) async {
    _db = DatabaseHelper();
    _fileManager = FileManager();

    await _db.init();
    await _fileManager.init(basePath);
    _localProvider = LocalStorageProvider(basePath: basePath);

    _initialized = true;
  }

  @override
  Future<String> saveContent(ContentSaveRequest request) async {
    _requireInit();

    try {
      // 1. 保存文件
      // 实际实现中，request.filePath 指向临时文件，需要复制到 App 沙盒
      final savedPath = request.filePath;

      // 2. 写入数据库
      final content = ContentModel(
        id: request.contentId,
        creatorId: request.creatorId,
        title: request.title,
        fileType: request.fileType,
        filePath: savedPath,
        thumbnailPath: request.thumbnailPath,
        permissions: request.permissions,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db.insertContent(content);

      return request.contentId;
    } catch (e) {
      throw StorageException(
        code: 3002,
        message: 'Save content failed: $e',
      );
    }
  }

  @override
  Future<ContentMeta?> getContent(String contentId) async {
    _requireInit();

    try {
      final content = await _db.getContent(contentId);
      if (content == null) return null;

      return ContentMeta(
        contentId: content.id,
        creatorId: content.creatorId,
        title: content.title,
        fileType: content.fileType,
        filePath: content.filePath,
        thumbnailPath: content.thumbnailPath,
        permissions: content.permissions,
        createdAt: content.createdAt,
        updatedAt: content.updatedAt,
      );
    } catch (e) {
      throw StorageException(
        code: 3001,
        message: 'Get content failed: $e',
      );
    }
  }

  @override
  Future<List<ContentMeta>> listContents({
    int page = 0,
    int pageSize = 20,
  }) async {
    _requireInit();

    try {
      final contents = await _db.listContents(page: page, pageSize: pageSize);
      return contents
          .map((c) => ContentMeta(
                contentId: c.id,
                creatorId: c.creatorId,
                title: c.title,
                fileType: c.fileType,
                filePath: c.filePath,
                thumbnailPath: c.thumbnailPath,
                permissions: c.permissions,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              ))
          .toList();
    } catch (e) {
      throw StorageException(
        code: 3001,
        message: 'List contents failed: $e',
      );
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    _requireInit();

    try {
      // 1. 删除文件
      final content = await _db.getContent(contentId);
      if (content?.filePath != null) {
        await _fileManager.delete(content!.filePath!);
      }

      // 2. 删除数据库记录
      await _db.deleteContent(contentId);

      // 3. 通知所有 Provider
      for (final provider in _extraProviders) {
        await provider.delete(contentId);
      }
    } catch (e) {
      throw StorageException(
        code: 3003,
        message: 'Delete content failed: $e',
      );
    }
  }

  @override
  Future<void> registerProvider(StorageProvider provider) async {
    _extraProviders.add(provider);
  }

  /// 消费路径：解码后获取内容
  Future<String?> resolveContentPath(String contentId) async {
    _requireInit();

    // 1. 查本地数据库
    final content = await _db.getContent(contentId);
    if (content?.filePath != null) {
      return content!.filePath;
    }

    // 2. 遍历所有 Provider
    for (final provider in _extraProviders) {
      if (await provider.exists(contentId)) {
        final bytes = await provider.pullContent(contentId);
        if (bytes.isNotEmpty) {
          // 保存到缓存
          final cachePath = await _fileManager.saveCache(contentId, bytes);
          return cachePath;
        }
      }
    }

    return null;
  }

  /// 注册 Bridge 处理器
  Map<String, dynamic> registerBridgeHandlers() {
    return {
      'storage.saveContent': (params) async {
        final request = ContentSaveRequest(
          contentId: params['contentId'] as String,
          creatorId: params['creatorId'] as String,
          title: params['title'] as String? ?? '',
          fileType: params['fileType'] as String? ?? 'live_photo',
          filePath: params['filePath'] as String,
          thumbnailPath: params['thumbnailPath'] as String?,
          permissions: params['permissions'] as String? ?? 'private',
        );
        final id = await saveContent(request);
        return {'contentId': id};
      },
      'storage.getContent': (params) async {
        final content = await getContent(params['contentId'] as String);
        return content?.toJson();
      },
      'storage.listContents': (params) async {
        final contents = await listContents(
          page: params['page'] as int? ?? 0,
          pageSize: params['pageSize'] as int? ?? 20,
        );
        return contents.map((c) => c.toJson()).toList();
      },
      'storage.deleteContent': (params) async {
        await deleteContent(params['contentId'] as String);
        return {'success': true};
      },
    };
  }

  void _requireInit() {
    if (!_initialized) {
      throw StorageException(
        code: 3002,
        message: 'StorageModule not initialized',
      );
    }
  }

  void dispose() {
    _db.close();
    _extraProviders.clear();
    _initialized = false;
  }
}