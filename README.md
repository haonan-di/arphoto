# AR Photo 📸✨

手机 App — 拍 Live Photo 嵌入暗水印打印，扫描复现 AR 动态效果。

## 概念

```
拍 Live Photo → 嵌入暗水印 → 打印照片 → 手机一扫 → AR 复活 ✨
```

## 架构（三层）

```
┌──────────────────┐
│    H5 UI 层       │  ← React/Vue，热更新，可移植到小程序
├──────────────────┤
│    壳工程          │  ← Flutter 宿主，WebView + JS Bridge
├──────────────────┤
│ 原生能力组件       │  ← CameraModule / DCTModule / ARModule / StorageModule
└──────────────────┘
```

详见 [设计文档](docs/superpowers/specs/2026-07-17-ar-photo-app-design.md)

## 技术栈

- **壳工程**: Flutter (Dart)
- **UI 层**: React / Vue (H5 WebView)
- **水印**: 自研 DCT 频域水印算法
- **存储**: SQLite + 本地优先，预留云存储接口

## 项目结构

```
arphoto/
├── lib/               # 壳工程 + 原生 Module
│   ├── main.dart
│   ├── shell/         # 壳工程核心（WebView / Bridge / 路由）
│   └── modules/       # 原生能力组件
│       ├── camera/    # CameraModule
│       ├── dct/       # DCTModule
│       ├── ar/        # ARModule
│       └── storage/   # StorageModule
├── h5_ui/             # H5 UI 层（独立项目）
├── docs/              # 设计文档
└── test/              # 测试
```

## 快速开始

```bash
# 需要 Flutter SDK，安装后：
flutter pub get
flutter run
```
