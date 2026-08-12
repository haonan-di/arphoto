/// 底部导航栏 — 3 个 Tab

import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const tabs = [
  { path: '/', icon: '🏠', label: '首页' },
  { path: '/my-content', icon: '📦', label: '我的内容' },
  { path: '/profile', icon: '👤', label: '个人中心' },
];

const BottomNav: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <nav className="bottom-nav safe-bottom">
      {tabs.map((tab) => (
        <button
          key={tab.path}
          className={`nav-item ${location.pathname === tab.path ? 'active' : ''}`}
          onClick={() => navigate(tab.path)}
        >
          <span className="nav-icon">{tab.icon}</span>
          <span className="nav-label">{tab.label}</span>
        </button>
      ))}

      <style>{`
        .tab-layout {
          display: flex;
          flex-direction: column;
          height: 100%;
        }
        .tab-content {
          flex: 1;
          overflow-y: auto;
          padding-bottom: 64px;
        }
        .bottom-nav {
          position: fixed;
          bottom: 0;
          left: 0;
          right: 0;
          display: flex;
          justify-content: space-around;
          align-items: center;
          height: 64px;
          background: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(10px);
          border-top: 1px solid rgba(255,255,255,0.08);
          z-index: 100;
        }
        .nav-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 2px;
          background: none;
          border: none;
          color: rgba(255,255,255,0.4);
          cursor: pointer;
          padding: 4px 20px;
          transition: color 0.2s;
        }
        .nav-item.active {
          color: #6366f1;
        }
        .nav-icon {
          font-size: 22px;
        }
        .nav-label {
          font-size: 10px;
        }
      `}</style>
    </nav>
  );
};

export default BottomNav;