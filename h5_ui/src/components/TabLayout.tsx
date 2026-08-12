/// Tab 布局 — 为 Tab 页面提供底部导航

import React from 'react';
import { Outlet } from 'react-router-dom';
import BottomNav from './BottomNav';

const TabLayout: React.FC = () => {
  return (
    <div className="tab-layout">
      <div className="tab-content">
        <Outlet />
      </div>
      <BottomNav />
    </div>
  );
};

export default TabLayout;