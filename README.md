# AR Photo 📸✨

手机 App — 拍 Live Photo 嵌入暗水印打印，扫描复现 AR 动态效果。

## 概念

```
拍 Live Photo → 嵌入暗水印 → 打印照片 → 手机一扫 → AR 复活 ✨
```

## 技术栈

- **框架**: Flutter (Dart)
- **水印**: 自研 DCT 频域水印算法
- **存储**: SQLite + 本地优先，预留云存储接口

## 快速开始

```bash
# 需要 Flutter SDK，安装后：
flutter pub get
flutter run
```

## 设计文档

见 [docs/design.md](docs/design.md)

## 项目结构

```
lib/
├── main.dart              # 入口
├── screens/               # 页面
│   ├── camera_screen.dart  # 拍照/扫描
│   ├── preview_screen.dart # AR 预览
│   └── gallery_screen.dart # 内容管理
├── widgets/               # 组件
├── services/              # 服务
│   ├── watermark_service.dart   # 水印编解码
│   ├── storage_service.dart     # 存储抽象层
│   └── ar_render_service.dart   # AR 渲染
├── models/                # 数据模型
│   └── content.dart
└── utils/                 # 工具
    ├── dct.dart           # DCT 算法
    └── image_utils.dart   # 图像处理
```
