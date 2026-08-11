/// 底部导航栏

import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const navItems = [
  { path: '/', icon: '🏠', label: '首页' },
  { path: '/camera', icon: '📷', label: '拍摄' },
  { path: '/scan', icon: '🔍', label: '扫描' },
  { path: '/gallery', icon: '🖼️', label: '画廊' },
  { path: '/settings', icon: '⚙️', label: '设置' },
];

const BottomNav: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <nav className="bottom-nav safe-bottom">
      {navItems.map((item) => (
        <button
          key={item.path}
          className={`nav-item ${location.pathname === item.path ? 'active' : ''}`}
          onClick={() => navigate(item.path)}
        >
          <span className="nav-icon">{item.icon}</span>
          <span className="nav-label">{item.label}</span>
        </button>
      ))}
      <style>{`
        .bottom-nav {
          display: flex;
          justify-content: space-around;
          align-items: center;
          height: 64px;
          background: rgba(20, 20, 30, 0.95);
          backdrop-filter: blur(10px);
          border-top: 1px solid rgba(255,255,255,0.08);
          position: fixed;
          bottom: 0;
          left: 0;
          right: 0;
          z-index: 100;
        }
        .nav-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 2px;
          background: none;
          border: none;
          color: rgba(255,255,255,0.5);
          cursor: pointer;
          padding: 4px 12px;
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