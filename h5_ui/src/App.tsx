import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import HomePage from './pages/home/HomePage';
import CameraPage from './pages/camera/CameraPage';
import GalleryPage from './pages/gallery/GalleryPage';
import ScanPage from './pages/scan/ScanPage';
import PreviewPage from './pages/preview/PreviewPage';
import SettingsPage from './pages/settings/SettingsPage';
import BottomNav from './components/BottomNav';

const App: React.FC = () => {
  return (
    <div className="app">
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/camera" element={<CameraPage />} />
        <Route path="/gallery" element={<GalleryPage />} />
        <Route path="/scan" element={<ScanPage />} />
        <Route path="/preview" element={<PreviewPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      <BottomNav />
    </div>
  );
};

export default App;