/// 拍摄页面 — 调用原生相机

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CameraAPI, DCTAPI } from '../../bridge/bridge';

const CameraPage: React.FC = () => {
  const navigate = useNavigate();
  const [cameraActive, setCameraActive] = useState(false);
  const [capturedPath, setCapturedPath] = useState<string | null>(null);
  const [encoding, setEncoding] = useState(false);

  const startCamera = async () => {
    try {
      await CameraAPI.startPreview();
      setCameraActive(true);
    } catch (e) {
      console.error('Failed to start camera:', e);
    }
  };

  const capture = async () => {
    try {
      const result = await CameraAPI.capturePhoto() as { data?: { path: string } };
      const path = result?.data?.path || '/tmp/photo.jpg';
      setCapturedPath(path);
      setCameraActive(false);
      await CameraAPI.stopPreview();
    } catch (e) {
      console.error('Capture failed:', e);
    }
  };

  const encodeAndExport = async () => {
    if (!capturedPath) return;
    setEncoding(true);
    try {
      const contentId = Math.floor(Math.random() * 2147483647);
      await DCTAPI.encode({
        imagePath: capturedPath,
        contentId,
        creatorId: 1,
        isPublic: true,
      });
      navigate(`/preview/${contentId}`);
    } catch (e) {
      console.error('Encode failed:', e);
    } finally {
      setEncoding(false);
    }
  };

  return (
    <div className="page">
      <div className="camera-header safe-top">
        <button className="header-btn" onClick={() => navigate('/')}>← 首页</button>
        <span className="header-title">拍摄</span>
        <div style={{ width: 60 }} />
      </div>

      <div className="camera-viewfinder">
        {cameraActive ? (
          <div className="camera-preview">
            <div className="preview-placeholder">
              <span className="preview-icon">📷</span>
              <span className="preview-text">相机预览（原生层）</span>
            </div>
          </div>
        ) : (
          <div className="camera-ready">
            {capturedPath ? (
              <div className="captured-preview">
                <span className="preview-icon">🖼️</span>
                <span className="preview-text">已拍摄</span>
              </div>
            ) : (
              <button className="btn btn-primary start-btn" onClick={startCamera}>
                启动相机
              </button>
            )}
          </div>
        )}
      </div>

      <div className="camera-actions safe-bottom">
        {cameraActive && (
          <button className="btn btn-primary capture-btn" onClick={capture}>
            ⭕ 拍摄
          </button>
        )}
        {capturedPath && !cameraActive && (
          <>
            <button className="btn btn-secondary" onClick={startCamera}>
              重拍
            </button>
            <button
              className="btn btn-primary"
              onClick={encodeAndExport}
              disabled={encoding}
            >
              {encoding ? '嵌入水印中...' : '嵌入水印并导出'}
            </button>
          </>
        )}
      </div>

      <style>{`
        .camera-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 8px 16px;
          height: 56px;
        }
        .header-btn {
          background: none;
          border: none;
          color: #fff;
          font-size: 16px;
          cursor: pointer;
        }
        .header-title {
          font-size: 17px;
          font-weight: 600;
        }
        .camera-viewfinder {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #111;
          margin: 0 16px;
          border-radius: 16px;
          overflow: hidden;
        }
        .camera-preview, .camera-ready, .captured-preview {
          width: 100%;
          height: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 12px;
        }
        .preview-placeholder {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
          color: rgba(255,255,255,0.4);
        }
        .preview-icon {
          font-size: 48px;
        }
        .preview-text {
          font-size: 14px;
        }
        .start-btn {
          padding: 16px 32px;
          font-size: 18px;
        }
        .camera-actions {
          display: flex;
          justify-content: center;
          gap: 12px;
          padding: 16px;
        }
        .capture-btn {
          width: 72px;
          height: 72px;
          border-radius: 50%;
          font-size: 28px;
          padding: 0;
        }
      `}</style>
    </div>
  );
};

export default CameraPage;