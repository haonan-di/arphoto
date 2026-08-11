/// 路由协调 — H5 路由 ↔ 原生页面映射

/// 路由映射条目
class RouteMapping {
  final String pattern;
  final String target;
  final bool requiresNative;

  const RouteMapping({
    required this.pattern,
    required this.target,
    this.requiresNative = false,
  });
}

/// 路由协调器
class RouteMapper {
  final List<RouteMapping> _mappings = [];

  RouteMapper() {
    _registerDefaultMappings();
  }

  void _registerDefaultMappings() {
    _mappings.addAll([
      const RouteMapping(
        pattern: '/',
        target: 'home',
        requiresNative: false,
      ),
      const RouteMapping(
        pattern: '/camera',
        target: 'camera',
        requiresNative: true,
      ),
      const RouteMapping(
        pattern: '/scan',
        target: 'scan',
        requiresNative: true,
      ),
      const RouteMapping(
        pattern: '/gallery',
        target: 'gallery',
        requiresNative: false,
      ),
      const RouteMapping(
        pattern: '/preview',
        target: 'preview',
        requiresNative: true,
      ),
      const RouteMapping(
        pattern: '/settings',
        target: 'settings',
        requiresNative: false,
      ),
    ]);
  }

  /// 注册自定义映射
  void register(RouteMapping mapping) {
    _mappings.add(mapping);
  }

  /// 解析 H5 路由
  RouteMapping? resolve(String path) {
    for (final mapping in _mappings) {
      if (path == mapping.pattern) {
        return mapping;
      }
    }
    return null;
  }

  /// 是否需要唤起原生页面
  bool requiresNative(String path) {
    final mapping = resolve(path);
    return mapping?.requiresNative ?? false;
  }

  /// 获取原生页面目标
  String? getNativeTarget(String path) {
    final mapping = resolve(path);
    return mapping?.target;
  }
}