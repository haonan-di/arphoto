/// 首页

import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StorageAPI, bridge } from '../../bridge/bridge';

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const [contentCount, setContentCount] = useState(0);
  const [inShell, setInShell] = useState(false);

  useEffect(() => {
    setInShell(bridge.isInShell);
    StorageAPI.listContents(0, 1).then((res: unknown) => {
      const data = res as { data?: { length?: number } };
      if (data?.data && Array.isArray(data.data)) {
        setContentCount(data.data.length);
      }
    }).catch(() => {});
  }, []);

  return (
    <div className="page safe-top">
      <div className="page-content">
        <div className="hero">
          <h1 className="hero-title">AR Photo</h1>
          <p className="hero-subtitle">
            拍 Live Photo → 嵌入暗水印 → 打印照片<br />
            手机一扫 → AR 复活 ✨
          </p>
        </div>

        <div className="action-grid">
          <button className="action-card" onClick={() => navigate('/camera')}>
            <span className="action-icon">📷</span>
            <span className="action-title">拍摄</span>
            <span className="action-desc">拍 Live Photo 嵌入水印</span>
          </button>

          <button className="action-card" onClick={() => navigate('/scan')}>
            <span className="action-icon">🔍</span>
            <span className="action-title">扫描</span>
            <span className="action-desc">扫描照片还原 AR</span>
          </button>

          <button className="action-card" onClick={() => navigate('/gallery')}>
            <span className="action-icon">🖼️</span>
            <span className="action-title">画廊</span>
            <span className="action-desc">管理你的 AR 内容</span>
          </button>
        </div>

        <div className="status-bar">
          <span>内容: {contentCount} 个</span>
          <span>{inShell ? '📱 App' : '🌐 Web'}</span>
        </div>
      </div>

      <style>{`
        .hero {
          text-align: center;
          padding: 48px 16px 32px;
        }
        .hero-title {
          font-size: 36px;
          font-weight: 800;
          background: linear-gradient(135deg, #6366f1, #a855f7);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          margin-bottom: 12px;
        }
        .hero-subtitle {
          font-size: 14px;
          color: rgba(255,255,255,0.6);
          line-height: 1.6;
        }
        .action-grid {
          display: flex;
          flex-direction: column;
          gap: 12px;
          padding: 16px;
        }
        .action-card {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          gap: 4px;
          padding: 20px;
          background: rgba(255,255,255,0.05);
          border: 1px solid rgba(255,255,255,0.08);
          border-radius: 16px;
          cursor: pointer;
          transition: background 0.2s, transform 0.1s;
          text-align: left;
        }
        .action-card:active {
          background: rgba(255,255,255,0.1);
          transform: scale(0.98);
        }
        .action-icon {
          font-size: 32px;
          margin-bottom: 4px;
        }
        .action-title {
          font-size: 18px;
          font-weight: 600;
          color: #fff;
        }
        .action-desc {
          font-size: 13px;
          color: rgba(255,255,255,0.5);
        }
        .status-bar {
          display: flex;
          justify-content: space-between;
          padding: 16px;
          font-size: 12px;
          color: rgba(255,255,255,0.3);
        }
      `}</style>
    </div>
  );
};

export default HomePage;