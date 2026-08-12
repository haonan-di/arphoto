/// 个人中心 — Tab 页

import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StorageAPI, bridge } from '../../bridge/bridge';

const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const [contentCount, setContentCount] = useState(0);
  const [inShell, setInShell] = useState(false);

  useEffect(() => {
    setInShell(bridge.isInShell);
    StorageAPI.listContents(0, 1).then((res: unknown) => {
      const data = res as { data?: unknown[] };
      if (data?.data) setContentCount(data.data.length);
    }).catch(() => {});
  }, []);

  const menuItems = [
    { icon: '⚙️', label: '设置', sub: '权限、水印、存储', onClick: () => navigate('/profile/settings') },
    { icon: '📊', label: '使用统计', sub: '拍摄 ${contentCount} 次 · 扫描 0 次', onClick: () => {} },
    { icon: '☁️', label: '云存储', sub: '未开通', onClick: () => {} },
    { icon: '💬', label: '帮助与反馈', sub: '常见问题、联系作者', onClick: () => {} },
    { icon: 'ℹ️', label: '关于', sub: '版本 0.1.0', onClick: () => navigate('/profile/about') },
  ];

  return (
    <div className="page safe-top">
      {/* 个人信息头部 */}
      <div className="profile-header">
        <div className="profile-avatar">
          <span className="avatar-text">👤</span>
        </div>
        <div className="profile-info">
          <h1 className="profile-name">用户</h1>
          <p className="profile-env">{inShell ? '📱 App 端' : '🌐 浏览器'}</p>
        </div>
      </div>

      {/* 统计卡片 */}
      <div className="profile-stats">
        <div className="stat-card">
          <span className="stat-num">{contentCount}</span>
          <span className="stat-label">内容</span>
        </div>
        <div className="stat-card">
          <span className="stat-num">0</span>
          <span className="stat-label">扫描</span>
        </div>
        <div className="stat-card">
          <span className="stat-num">0 MB</span>
          <span className="stat-label">存储</span>
        </div>
      </div>

      {/* 菜单列表 */}
      <div className="profile-menu">
        {menuItems.map((item, i) => (
          <button key={i} className="menu-item" onClick={item.onClick}>
            <span className="menu-icon">{item.icon}</span>
            <div className="menu-info">
              <span className="menu-label">{item.label}</span>
              <span className="menu-sub">{item.sub}</span>
            </div>
            <span className="menu-arrow">›</span>
          </button>
        ))}
      </div>

      <style>{`
        .profile-header {
          display: flex;
          align-items: center;
          gap: 16px;
          padding: 24px 20px 16px;
        }
        .profile-avatar {
          width: 64px;
          height: 64px;
          border-radius: 50%;
          background: linear-gradient(135deg, #6366f1, #a855f7);
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .avatar-text {
          font-size: 32px;
        }
        .profile-info {
          flex: 1;
        }
        .profile-name {
          font-size: 22px;
          font-weight: 700;
          margin: 0 0 4px;
        }
        .profile-env {
          font-size: 13px;
          color: rgba(255,255,255,0.4);
          margin: 0;
        }
        .profile-stats {
          display: flex;
          gap: 8px;
          padding: 8px 20px 20px;
        }
        .stat-card {
          flex: 1;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 4px;
          padding: 14px 8px;
          background: rgba(255,255,255,0.03);
          border-radius: 12px;
        }
        .stat-num {
          font-size: 20px;
          font-weight: 700;
          color: #fff;
        }
        .stat-label {
          font-size: 12px;
          color: rgba(255,255,255,0.4);
        }
        .profile-menu {
          padding: 0 20px;
          display: flex;
          flex-direction: column;
          gap: 4px;
        }
        .menu-item {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px 12px;
          background: none;
          border: none;
          border-radius: 12px;
          cursor: pointer;
          text-align: left;
          color: #fff;
          transition: background 0.15s;
        }
        .menu-item:active {
          background: rgba(255,255,255,0.05);
        }
        .menu-icon {
          font-size: 20px;
          flex-shrink: 0;
        }
        .menu-info {
          flex: 1;
          display: flex;
          flex-direction: column;
          gap: 2px;
        }
        .menu-label {
          font-size: 15px;
          font-weight: 500;
        }
        .menu-sub {
          font-size: 12px;
          color: rgba(255,255,255,0.35);
        }
        .menu-arrow {
          font-size: 22px;
          color: rgba(255,255,255,0.2);
        }
      `}</style>
    </div>
  );
};

export default ProfilePage;