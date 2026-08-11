/// AR 预览页面 — 展示 AR 效果控制

import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { ARAPI, bridge } from '../../bridge/bridge';

const PreviewPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state as { contentId?: number; imagePath?: string } | null;
  const [arState, setArState] = useState<'playing' | 'paused'>('playing');

  useEffect(() => {
    // 监听 AR 状态变更
    bridge.on('arStateChange', (data: unknown) => {
      const d = data as { state?: string };
      if (d?.state === 'paused' || d?.state === 'playing') {
        setArState(d.state);
      }
    });

    return () => {
      ARAPI.stop();
    };
  }, []);

  const togglePlay = () => {
    if (arState === 'playing') {
      ARAPI.pause();
      setArState('paused');
    } else {
      ARAPI.resume();
      setArState('playing');
    }
  };

  return (
    <div className="page">
      <div className="preview-header safe-top">
        <button className="header-btn" onClick={() => navigate('/')}>← 首页</button>
        <span className="header-title">AR 预览</span>
        <div style={{ width: 60 }} />
      </div>

      <div className="preview-viewfinder">
        <div className="ar-overlay">
          <div className="ar-placeholder">
            <span className="ar-icon">✨</span>
            <span className="ar-text">AR 效果（原生层渲染）</span>
            <span className="ar-id">
              {state?.contentId ? `Content #${state.contentId}` : '新内容'}
            </span>
          </div>
        </div>
      </div>

      <div className="preview-controls">
        <button className="ctrl-btn" onClick={togglePlay}>
          {arState === 'playing' ? '⏸️ 暂停' : '▶️ 播放'}
        </button>
        <button className="ctrl-btn" onClick={() => ARAPI.stop().then(() => navigate('/'))}>
          ⏹️ 停止
        </button>
      </div>

      <div className="preview-emoji-tools safe-bottom">
        <p className="emoji-title">Emoji 装饰</p>
        <div className="emoji-grid">
          {['✨', '🌟', '💫', '⭐', '🎉', '❤️'].map((emoji) => (
            <button
              key={emoji}
              className="emoji-btn"
              onClick={() => {
                ARAPI.updateEmoji([
                  { emoji, x: 0.2 + Math.random() * 0.6, y: 0.2 + Math.random() * 0.6, scale: 1.5, rotation: 0, opacity: 0.9 },
                ]);
              }}
            >
              {emoji}
            </button>
          ))}
        </div>
      </div>

      <style>{`
        .preview-header {
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
        .preview-viewfinder {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #111;
          margin: 0 16px;
          border-radius: 16px;
          overflow: hidden;
        }
        .ar-overlay {
          width: 100%;
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .ar-placeholder {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 8px;
          color: rgba(255,255,255,0.4);
        }
        .ar-icon {
          font-size: 48px;
        }
        .ar-text {
          font-size: 14px;
        }
        .ar-id {
          font-size: 12px;
          color: rgba(255,255,255,0.2);
        }
        .preview-controls {
          display: flex;
          justify-content: center;
          gap: 12px;
          padding: 12px 16px;
        }
        .ctrl-btn {
          padding: 10px 20px;
          background: rgba(255,255,255,0.1);
          border: 1px solid rgba(255,255,255,0.15);
          border-radius: 10px;
          color: #fff;
          font-size: 14px;
          cursor: pointer;
        }
        .ctrl-btn:active {
          background: rgba(255,255,255,0.2);
        }
        .preview-emoji-tools {
          padding: 12px 16px 24px;
        }
        .emoji-title {
          font-size: 13px;
          color: rgba(255,255,255,0.5);
          margin-bottom: 8px;
        }
        .emoji-grid {
          display: flex;
          gap: 8px;
          flex-wrap: wrap;
        }
        .emoji-btn {
          width: 48px;
          height: 48px;
          font-size: 24px;
          background: rgba(255,255,255,0.05);
          border: 1px solid rgba(255,255,255,0.1);
          border-radius: 12px;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .emoji-btn:active {
          background: rgba(255,255,255,0.15);
        }
      `}</style>
    </div>
  );
};

export default PreviewPage;