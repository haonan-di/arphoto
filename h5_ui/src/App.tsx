import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import TabLayout from './components/TabLayout';
import HomePage from './pages/home/HomePage';
import MyContentPage from './pages/my-content/MyContentPage';
import ProfilePage from './pages/profile/ProfilePage';
import CameraPage from './pages/camera/CameraPage';
import ScanPage from './pages/scan/ScanPage';
import PreviewPage from './pages/preview/PreviewPage';
import SettingsPage from './pages/settings/SettingsPage';

const App: React.FC = () => {
  return (
    <div className="app">
      <Routes>
        {/* Tab 页面 — 带底部导航 */}
        <Route element={<TabLayout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/my-content" element={<MyContentPage />} />
          <Route path="/profile" element={<ProfilePage />} />
        </Route>

        {/* 全屏功能页 — 无底部导航 */}
        <Route path="/camera" element={<CameraPage />} />
        <Route path="/scan" element={<ScanPage />} />
        <Route path="/preview/:contentId" element={<PreviewPage />} />

        {/* 个人中心子页 */}
        <Route path="/profile/settings" element={<SettingsPage />} />
        <Route path="/profile/about" element={<div className="page safe-top" style={{padding:20}}><h2>关于 AR Photo</h2><p style={{color:'rgba(255,255,255,0.5)',marginTop:12}}>版本 0.1.0</p></div>} />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  );
};

export default App;