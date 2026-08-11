/// Content 数据模型

class ContentModel {
  final String id;
  final String creatorId;
  final String title;
  final String fileType;
  final String? filePath;
  final String? thumbnailPath;
  final String permissions;
  final String? whitelist;
  final int createdAt;
  final int updatedAt;

  const ContentModel({
    required this.id,
    required this.creatorId,
    this.title = '',
    this.fileType = 'live_photo',
    this.filePath,
    this.thumbnailPath,
    this.permissions = 'private',
    this.whitelist,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'creator_id': creatorId,
        'title': title,
        'file_type': fileType,
        'file_path': filePath,
        'thumbnail_path': thumbnailPath,
        'permissions': permissions,
        'whitelist': whitelist,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory ContentModel.fromMap(Map<String, dynamic> map) => ContentModel(
        id: map['id'] as String,
        creatorId: map['creator_id'] as String,
        title: map['title'] as String? ?? '',
        fileType: map['file_type'] as String? ?? 'live_photo',
        filePath: map['file_path'] as String?,
        thumbnailPath: map['thumbnail_path'] as String?,
        permissions: map['permissions'] as String? ?? 'private',
        whitelist: map['whitelist'] as String?,
        createdAt: map['created_at'] as int,
        updatedAt: map['updated_at'] as int,
      );

  ContentModel copyWith({
    String? id,
    String? creatorId,
    String? title,
    String? fileType,
    String? filePath,
    String? thumbnailPath,
    String? permissions,
    String? whitelist,
    int? createdAt,
    int? updatedAt,
  }) =>
      ContentModel(
        id: id ?? this.id,
        creatorId: creatorId ?? this.creatorId,
        title: title ?? this.title,
        fileType: fileType ?? this.fileType,
        filePath: filePath ?? this.filePath,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
        permissions: permissions ?? this.permissions,
        whitelist: whitelist ?? this.whitelist,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// AR 配置数据模型
class ARConfigModel {
  final String id;
  final String contentId;
  final String configJson;
  final String creatorId;
  final int version;

  const ARConfigModel({
    required this.id,
    required this.contentId,
    this.configJson = '{}',
    required this.creatorId,
    this.version = 1,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content_id': contentId,
        'config_json': configJson,
        'creator_id': creatorId,
        'version': version,
      };

  factory ARConfigModel.fromMap(Map<String, dynamic> map) => ARConfigModel(
        id: map['id'] as String,
        contentId: map['content_id'] as String,
        configJson: map['config_json'] as String? ?? '{}',
        creatorId: map['creator_id'] as String,
        version: map['version'] as int? ?? 1,
      );

  ARConfigModel copyWith({
    String? id,
    String? contentId,
    String? configJson,
    String? creatorId,
    int? version,
  }) =>
      ARConfigModel(
        id: id ?? this.id,
        contentId: contentId ?? this.contentId,
        configJson: configJson ?? this.configJson,
        creatorId: creatorId ?? this.creatorId,
        version: version ?? this.version,
      );
}