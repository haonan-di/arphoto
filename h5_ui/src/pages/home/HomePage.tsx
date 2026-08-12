/// 首页 — 核心操作入口 + 最近内容

import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StorageAPI, bridge } from '../../bridge/bridge';

const tutorialSteps = [
  { icon: '📷', text: '拍摄 Live Photo 嵌入暗水印' },
  { icon: '🖨️', text: '打印照片（家用/打印店/在线冲印）' },
  { icon: '🔍', text: '手机扫描照片，解码水印' },
  { icon: '✨', text: 'AR 动态效果复活' },
];

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const [recentItems, setRecentItems] = useState<{ contentId: string; title: string }[]>([]);
  const [showTutorial, setShowTutorial] = useState(false);

  useEffect(() => {
    StorageAPI.listContents(0, 5).then((res: unknown) => {
      const data = res as { data?: { contentId: string; title: string }[] };
      if (data?.data) setRecentItems(data.data);
    }).catch(() => {});
  }, []);

  return (
    <div className="page safe-top">
      <div className="home-header">
        <h1 className="home-logo">AR Photo</h1>
        <span className="home-badge">{bridge.isInShell ? '📱' : '🌐'}</span>
      </div>

      {/* 主操作区 */}
      <div className="home-actions">
        <button className="action-btn primary" onClick={() => navigate('/camera')}>
          <span className="action-btn-icon">📷</span>
          <span className="action-btn-label">拍摄新内容</span>
          <span className="action-btn-desc">拍 Live Photo 嵌入暗水印，导出打印</span>
        </button>

        <button className="action-btn secondary" onClick={() => navigate('/scan')}>
          <span className="action-btn-icon">🔍</span>
          <span className="action-btn-label">扫描一张照片</span>
          <span className="action-btn-desc">手机扫打印照片，AR 复活动态效果</span>
        </button>
      </div>

      {/* 最近内容 */}
      <div className="home-section">
        <div className="section-header">
          <h2 className="section-title">最近内容</h2>
          <button className="section-more" onClick={() => navigate('/my-content')}>查看全部 →</button>
        </div>
        {recentItems.length > 0 ? (
          <div className="recent-scroll">
            {recentItems.map((item) => (
              <div
                key={item.contentId}
                className="recent-card"
                onClick={() => navigate(`/preview/${item.contentId}`)}
              >
                <div className="recent-thumb">🎬</div>
                <span className="recent-title">{item.title || '未命名'}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className="recent-empty">
            <span>还没有内容，去拍摄或扫描一张吧</span>
          </div>
        )}
      </div>

      {/* 快速教程（可折叠） */}
      <div className="home-section">
        <button className="section-header" onClick={() => setShowTutorial(!showTutorial)}>
          <h2 className="section-title">快速教程</h2>
          <span className="section-more">{showTutorial ? '收起 ▲' : '展开 ▼'}</span>
        </button>
        {showTutorial && (
          <div className="tutorial-steps">
            {tutorialSteps.map((step, i) => (
              <div key={i} className="tutorial-step">
                <span className="step-num">{i + 1}</span>
                <span className="step-icon">{step.icon}</span>
                <span className="step-text">{step.text}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      <style>{`
        .home-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 20px 20px 8px;
        }
        .home-logo {
          font-size: 28px;
          font-weight: 800;
          background: linear-gradient(135deg, #6366f1, #a855f7);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          margin: 0;
        }
        .home-badge {
          font-size: 20px;
        }
        .home-actions {
          padding: 16px 20px 8px;
          display: flex;
          flex-direction: column;
          gap: 12px;
        }
        .action-btn {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          gap: 4px;
          padding: 20px;
          border: none;
          border-radius: 16px;
          cursor: pointer;
          text-align: left;
          transition: transform 0.1s, opacity 0.2s;
        }
        .action-btn:active {
          transform: scale(0.98);
        }
        .action-btn.primary {
          background: linear-gradient(135deg, #6366f1, #4f46e5);
          color: #fff;
        }
        .action-btn.secondary {
          background: rgba(255,255,255,0.06);
          border: 1px solid rgba(255,255,255,0.1);
          color: #fff;
        }
        .action-btn-icon {
          font-size: 28px;
          margin-bottom: 4px;
        }
        .action-btn-label {
          font-size: 17px;
          font-weight: 600;
        }
        .action-btn-desc {
          font-size: 13px;
          opacity: 0.7;
        }
        .home-section {
          padding: 12px 20px;
        }
        .section-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 12px;
          background: none;
          border: none;
          color: #fff;
          width: 100%;
          cursor: pointer;
          padding: 0;
        }
        .section-title {
          font-size: 16px;
          font-weight: 600;
          margin: 0;
        }
        .section-more {
          font-size: 13px;
          color: #6366f1;
          background: none;
          border: none;
          cursor: pointer;
        }
        .recent-scroll {
          display: flex;
          gap: 10px;
          overflow-x: auto;
          padding-bottom: 4px;
          scrollbar-width: none;
        }
        .recent-scroll::-webkit-scrollbar {
          display: none;
        }
        .recent-card {
          flex-shrink: 0;
          width: 100px;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 6px;
          cursor: pointer;
        }
        .recent-thumb {
          width: 100px;
          height: 100px;
          border-radius: 12px;
          background: rgba(255,255,255,0.05);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 32px;
        }
        .recent-title {
          font-size: 12px;
          color: rgba(255,255,255,0.6);
          text-align: center;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
          width: 100%;
        }
        .recent-empty {
          padding: 20px;
          text-align: center;
          color: rgba(255,255,255,0.3);
          font-size: 14px;
          background: rgba(255,255,255,0.02);
          border-radius: 12px;
        }
        .tutorial-steps {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }
        .tutorial-step {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px;
          background: rgba(255,255,255,0.03);
          border-radius: 10px;
        }
        .step-num {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          background: #6366f1;
          color: #fff;
          font-size: 12px;
          font-weight: 700;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }
        .step-icon {
          font-size: 20px;
          flex-shrink: 0;
        }
        .step-text {
          font-size: 14px;
          color: rgba(255,255,255,0.7);
        }
      `}</style>
    </div>
  );
};

export default HomePage;