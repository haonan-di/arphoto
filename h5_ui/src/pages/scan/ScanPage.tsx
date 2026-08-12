/// 扫描页面 — 调用原生相机 + DCT 解码

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { CameraAPI, ARAPI, bridge } from '../../bridge/bridge';

const ScanPage: React.FC = () => {
  const navigate = useNavigate();
  const [scanning, setScanning] = useState(false);
  const [decoded, setDecoded] = useState<{ contentId: number } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const startScan = async () => {
    setScanning(true);
    setError(null);
    setDecoded(null);
    try {
      await CameraAPI.startPreview();
      // 监听解码结果
      bridge.on('decodeResult', handleDecodeResult);
    } catch (e) {
      setError('启动相机失败');
      setScanning(false);
    }
  };

  const handleDecodeResult = (data: unknown) => {
    const payload = data as { contentId?: number; isPublic?: boolean } | null;
    if (payload?.contentId) {
      setDecoded({ contentId: payload.contentId });
      setScanning(false);
      CameraAPI.stopPreview();
      bridge.off('decodeResult', handleDecodeResult);
    }
  };

  const viewAR = () => {
    if (decoded) {
      ARAPI.start({
        contentId: String(decoded.contentId),
        videoPath: `/content/${decoded.contentId}`,
      });
      navigate(`/preview/${decoded.contentId}`);
    }
  };

  const stopScan = () => {
    setScanning(false);
    CameraAPI.stopPreview();
  };

  useEffect(() => {
    return () => {
      CameraAPI.stopPreview();
    };
  }, []);

  return (
    <div className="page">
      <div className="scan-header safe-top">
        <button className="header-btn" onClick={() => navigate('/')}>← 首页</button>
        <span className="header-title">扫描</span>
        <div style={{ width: 60 }} />
      </div>

      <div className="scan-viewfinder">
        {scanning ? (
          <div className="scanning">
            <div className="scan-frame">
              <div className="scan-corner tl" />
              <div className="scan-corner tr" />
              <div className="scan-corner bl" />
              <div className="scan-corner br" />
              <div className="scan-line" />
            </div>
            <p className="scan-hint">将照片置于框内</p>
          </div>
        ) : decoded ? (
          <div className="scan-result">
            <span className="result-icon">✅</span>
            <p className="result-text">已解码</p>
            <p className="result-id">Content ID: {decoded.contentId}</p>
          </div>
        ) : (
          <div className="scan-ready">
            <span className="scan-icon">🔍</span>
            <p className="scan-desc">扫描打印照片<br />还原 AR 动态效果</p>
          </div>
        )}
      </div>

      <div className="scan-actions safe-bottom">
        {error && <p className="error-text">{error}</p>}
        {scanning ? (
          <button className="btn btn-secondary" onClick={stopScan}>取消</button>
        ) : decoded ? (
          <>
            <button className="btn btn-secondary" onClick={startScan}>再扫一张</button>
            <button className="btn btn-primary" onClick={viewAR}>查看 AR</button>
          </>
        ) : (
          <button className="btn btn-primary" onClick={startScan}>开始扫描</button>
        )}
      </div>

      <style>{`
        .scan-header {
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
        .scan-viewfinder {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #111;
          margin: 0 16px;
          border-radius: 16px;
          overflow: hidden;
        }
        .scanning {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 24px;
        }
        .scan-frame {
          width: 240px;
          height: 180px;
          position: relative;
        }
        .scan-corner {
          position: absolute;
          width: 24px;
          height: 24px;
          border-color: #6366f1;
          border-style: solid;
        }
        .scan-corner.tl { top: 0; left: 0; border-width: 3px 0 0 3px; }
        .scan-corner.tr { top: 0; right: 0; border-width: 3px 3px 0 0; }
        .scan-corner.bl { bottom: 0; left: 0; border-width: 0 0 3px 3px; }
        .scan-corner.br { bottom: 0; right: 0; border-width: 0 3px 3px 0; }
        .scan-line {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 2px;
          background: #6366f1;
          animation: scanMove 2s ease-in-out infinite;
        }
        @keyframes scanMove {
          0% { top: 0; }
          50% { top: 100%; }
          100% { top: 0; }
        }
        .scan-hint {
          color: rgba(255,255,255,0.6);
          font-size: 14px;
        }
        .scan-ready, .scan-result {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
        }
        .scan-icon, .result-icon {
          font-size: 48px;
        }
        .scan-desc, .result-text {
          color: rgba(255,255,255,0.6);
          font-size: 14px;
          text-align: center;
          line-height: 1.5;
        }
        .result-id {
          color: rgba(255,255,255,0.3);
          font-size: 12px;
        }
        .scan-actions {
          display: flex;
          justify-content: center;
          gap: 12px;
          padding: 16px;
        }
        .error-text {
          color: #ef4444;
          font-size: 13px;
        }
      `}</style>
    </div>
  );
};

export default ScanPage;