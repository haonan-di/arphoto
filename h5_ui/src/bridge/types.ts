/// Bridge 协议类型定义

/// Bridge 请求（H5 → 原生）
export interface BridgeRequest {
  action: string;
  requestId: string;
  params: Record<string, unknown>;
}

/// Bridge 响应（原生 → H5）
export interface BridgeResponse {
  requestId: string;
  code: number;
  data?: unknown;
  error?: string;
}

/// Bridge 主动事件（原生 → H5）
export interface BridgeEvent {
  type: string;
  data: unknown;
}

/// 帧信息（缩略图，非像素数据）
export interface FrameInfo {
  width: number;
  height: number;
  thumbnail?: string;
}

/// 水印载荷
export interface WatermarkPayload {
  isPublic: boolean;
  contentId: number;
  creatorId: number;
}

/// AR 状态
export interface ARState {
  state: 'idle' | 'loading' | 'playing' | 'paused' | 'error';
  hasVideo: boolean;
  emojiCount: number;
}

/// 内容元数据
export interface ContentMeta {
  contentId: string;
  creatorId: string;
  title: string;
  fileType: string;
  filePath?: string;
  thumbnailPath?: string;
  permissions: string;
  createdAt: number;
  updatedAt: number;
}

/// Emoji 配置
export interface EmojiConfig {
  emoji: string;
  x: number;
  y: number;
  scale: number;
  rotation: number;
  opacity: number;
}