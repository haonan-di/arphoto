/// 设置页面 — 个人中心子页

import React from 'react';
import { useNavigate } from 'react-router-dom';
import { bridge } from '../../bridge/bridge';

const SettingsPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="page safe-top">
      <div className="settings-header">
        <button className="header-btn" onClick={() => navigate('/profile')}>← 返回</button>
        <span className="header-title">设置</span>
        <div style={{ width: 60 }} />
      </div>

      <div className="page-content">
        <div className="settings-section">
          <p className="section-title">权限</p>
          <div className="setting-item">
            <span>相机权限</span>
            <span className="setting-status">已授权 ✓</span>
          </div>
          <div className="setting-item">
            <span>存储权限</span>
            <span className="setting-status">已授权 ✓</span>
          </div>
        </div>

        <div className="settings-section">
          <p className="section-title">水印</p>
          <div className="setting-item">
            <span>默认权限</span>
            <span className="setting-status">私密</span>
          </div>
          <div className="setting-item">
            <span>嵌入强度</span>
            <span className="setting-status">中</span>
          </div>
        </div>

        <div className="settings-section">
          <p className="section-title">存储</p>
          <div className="setting-item">
            <span>本地内容</span>
            <span className="setting-status">0 个</span>
          </div>
          <div className="setting-item">
            <span>缓存大小</span>
            <span className="setting-status">0 MB</span>
          </div>
        </div>

        <div className="settings-section">
          <p className="section-title">关于</p>
          <div className="setting-item">
            <span>版本</span>
            <span className="setting-status">0.1.0</span>
          </div>
          <div className="setting-item">
            <span>运行环境</span>
            <span className="setting-status">{bridge.isInShell ? '壳工程' : '浏览器'}</span>
          </div>
        </div>
      </div>

      <style>{`
        .settings-header {
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
        .settings-section {
          margin-bottom: 24px;
        }
        .section-title {
          font-size: 13px;
          font-weight: 600;
          color: rgba(255,255,255,0.4);
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin-bottom: 8px;
          padding: 0 4px;
        }
        .setting-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 14px 12px;
          background: rgba(255,255,255,0.03);
          border-radius: 10px;
          margin-bottom: 4px;
          font-size: 15px;
        }
        .setting-status {
          color: rgba(255,255,255,0.4);
          font-size: 14px;
        }
      `}</style>
    </div>
  );
};

export default SettingsPage;