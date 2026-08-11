/// JS Bridge 封装 — H5 端调用原生能力

import type { BridgeResponse, BridgeEvent } from './types';

class Bridge {
  private requestIdCounter = 0;
  private pendingRequests = new Map<string, {
    resolve: (value: BridgeResponse) => void;
    reject: (reason: unknown) => void;
    timer: ReturnType<typeof setTimeout>;
  }>();

  private eventListeners = new Map<string, Array<(data: unknown) => void>>();

  constructor() {
    // 注册原生回调
    this.setupNativeCallback();
  }

  /// 检测是否在壳工程 WebView 中
  get isInShell(): boolean {
    return typeof (window as unknown as Record<string, unknown>).ARPhotoBridge !== 'undefined';
  }

  /// 调用原生能力
  async call(action: string, params: Record<string, unknown> = {}): Promise<unknown> {
    const requestId = `req_${++this.requestIdCounter}_${Date.now()}`;

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pendingRequests.delete(requestId);
        reject(new Error(`Bridge call timeout: ${action}`));
      }, 10000);

      this.pendingRequests.set(requestId, { resolve, reject, timer });

      const request = { action, requestId, params };

      if (this.isInShell) {
        // 壳工程环境中：通过 JS Bridge 调用原生
        (window as unknown as Record<string, (msg: string) => void>).ARPhotoBridge(
          JSON.stringify(request)
        );
      } else {
        // 开发环境：模拟响应
        console.log('[Bridge] Mock call:', action, params);
        setTimeout(() => {
          this.handleResponse({
            requestId,
            code: 0,
            data: { mock: true },
          });
        }, 300);
      }
    });
  }

  /// 处理原生响应
  handleResponse(response: BridgeResponse): void {
    const pending = this.pendingRequests.get(response.requestId);
    if (!pending) return;

    clearTimeout(pending.timer);
    this.pendingRequests.delete(response.requestId);

    if (response.code === 0) {
      pending.resolve(response);
    } else {
      pending.reject(new Error(response.error || `Error #${response.code}`));
    }
  }

  /// 监听原生事件
  on(eventType: string, callback: (data: unknown) => void): void {
    if (!this.eventListeners.has(eventType)) {
      this.eventListeners.set(eventType, []);
    }
    this.eventListeners.get(eventType)!.push(callback);
  }

  /// 移除监听
  off(eventType: string, callback: (data: unknown) => void): void {
    const listeners = this.eventListeners.get(eventType);
    if (!listeners) return;
    const idx = listeners.indexOf(callback);
    if (idx >= 0) listeners.splice(idx, 1);
  }

  /// 处理原生主动事件
  handleEvent(event: BridgeEvent): void {
    const listeners = this.eventListeners.get(event.type);
    if (!listeners) return;
    for (const cb of listeners) {
      cb(event.data);
    }
  }

  /// 设置原生回调函数
  private setupNativeCallback(): void {
    // 原生端会调用此函数
    (window as unknown as Record<string, (json: string) => void>).__onBridgeResponse = (json: string) => {
      const response = JSON.parse(json) as BridgeResponse;
      this.handleResponse(response);
    };

    (window as unknown as Record<string, (json: string) => void>).__onBridgeEvent = (json: string) => {
      const event = JSON.parse(json) as BridgeEvent;
      this.handleEvent(event);
    };
  }
}

/// 全局单例
export const bridge = new Bridge();

/// 便捷 API
export const CameraAPI = {
  startPreview: (params = {}) => bridge.call('camera.startPreview', params),
  stopPreview: () => bridge.call('camera.stopPreview'),
  capturePhoto: () => bridge.call('camera.capturePhoto'),
  getCameras: () => bridge.call('camera.getCameras'),
  switchCamera: (direction: 'front' | 'back') =>
    bridge.call('camera.switchCamera', { direction }),
};

export const DCTAPI = {
  encode: (params: { imagePath: string; contentId: number; creatorId: number; isPublic: boolean }) =>
    bridge.call('dct.encode', params as unknown as Record<string, unknown>),
  decode: (params: { imageData: string }) => bridge.call('dct.decode', params),
};

export const ARAPI = {
  start: (params: { contentId: string; videoPath: string; emojis?: unknown[] }) =>
    bridge.call('ar.start', params as unknown as Record<string, unknown>),
  stop: () => bridge.call('ar.stop'),
  pause: () => bridge.call('ar.pause'),
  resume: () => bridge.call('ar.resume'),
  updateEmoji: (emojis: unknown[]) => bridge.call('ar.updateEmoji', { emojis }),
};

export const StorageAPI = {
  saveContent: (params: Record<string, unknown>) => bridge.call('storage.saveContent', params),
  getContent: (contentId: string) => bridge.call('storage.getContent', { contentId }),
  listContents: (page = 0, pageSize = 20) =>
    bridge.call('storage.listContents', { page, pageSize }),
  deleteContent: (contentId: string) => bridge.call('storage.deleteContent', { contentId }),
};