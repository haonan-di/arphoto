/// 我的内容 — 内容库管理（Tab 页）

import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StorageAPI, ARAPI } from '../../bridge/bridge';
import type { ContentMeta } from '../../bridge/types';

const MyContentPage: React.FC = () => {
  const navigate = useNavigate();
  const [contents, setContents] = useState<ContentMeta[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  const loadContents = async () => {
    setLoading(true);
    try {
      const result = await StorageAPI.listContents(0, 100) as { data?: ContentMeta[] };
      setContents(result?.data || []);
    } catch {
      setContents([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadContents();
  }, []);

  const filtered = contents.filter((c) =>
    c.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const viewAR = (content: ContentMeta) => {
    ARAPI.start({ contentId: content.contentId, videoPath: content.filePath || '' });
    navigate(`/preview/${content.contentId}`);
  };

  const deleteContent = async (contentId: string) => {
    try {
      await StorageAPI.deleteContent(contentId);
      setContents((prev) => prev.filter((c) => c.contentId !== contentId));
    } catch (e) {
      console.error('Delete failed:', e);
    }
  };

  return (
    <div className="page safe-top">
      <div className="mc-header">
        <h1 className="mc-title">我的内容</h1>
        <span className="mc-count">{contents.length} 个</span>
      </div>

      {/* 搜索栏 */}
      <div className="mc-search">
        <span className="search-icon">🔍</span>
        <input
          className="search-input"
          type="text"
          placeholder="搜索内容..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        {searchQuery && (
          <button className="search-clear" onClick={() => setSearchQuery('')}>✕</button>
        )}
      </div>

      {/* 内容列表 */}
      <div className="page-content">
        {loading ? (
          <div className="mc-loading">加载中...</div>
        ) : filtered.length === 0 ? (
          <div className="mc-empty">
            <span className="empty-icon">📦</span>
            <p className="empty-text">{searchQuery ? '没有匹配的内容' : '还没有内容'}</p>
            <p className="empty-hint">去首页拍摄或扫描一张照片</p>
          </div>
        ) : (
          <div className="mc-list">
            {filtered.map((content) => (
              <div key={content.contentId} className="mc-card">
                <div className="mc-thumb">🎬</div>
                <div className="mc-info">
                  <p className="mc-name">{content.title || '未命名'}</p>
                  <p className="mc-meta">
                    {new Date(content.createdAt).toLocaleDateString('zh-CN')}
                    {' · '}
                    {content.permissions === 'public' ? '公开' : '私密'}
                  </p>
                </div>
                <div className="mc-actions">
                  <button className="mc-btn" onClick={() => viewAR(content)} title="查看 AR">👁️</button>
                  <button className="mc-btn" onClick={() => deleteContent(content.contentId)} title="删除">🗑️</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <style>{`
        .mc-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 20px 20px 8px;
        }
        .mc-title {
          font-size: 24px;
          font-weight: 700;
          margin: 0;
        }
        .mc-count {
          font-size: 13px;
          color: rgba(255,255,255,0.4);
        }
        .mc-search {
          display: flex;
          align-items: center;
          gap: 8px;
          margin: 8px 20px 12px;
          padding: 10px 14px;
          background: rgba(255,255,255,0.06);
          border-radius: 12px;
        }
        .search-icon {
          font-size: 16px;
          flex-shrink: 0;
        }
        .search-input {
          flex: 1;
          background: none;
          border: none;
          color: #fff;
          font-size: 14px;
          outline: none;
        }
        .search-input::placeholder {
          color: rgba(255,255,255,0.3);
        }
        .search-clear {
          background: none;
          border: none;
          color: rgba(255,255,255,0.4);
          cursor: pointer;
          font-size: 14px;
        }
        .mc-loading, .mc-empty {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 60px 20px;
          gap: 8px;
          color: rgba(255,255,255,0.4);
        }
        .empty-icon { font-size: 48px; }
        .empty-text { font-size: 16px; }
        .empty-hint { font-size: 13px; }
        .mc-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
          padding-bottom: 16px;
        }
        .mc-card {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px;
          background: rgba(255,255,255,0.03);
          border: 1px solid rgba(255,255,255,0.06);
          border-radius: 12px;
        }
        .mc-thumb {
          width: 52px;
          height: 52px;
          border-radius: 8px;
          background: rgba(255,255,255,0.05);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 24px;
          flex-shrink: 0;
        }
        .mc-info {
          flex: 1;
          min-width: 0;
        }
        .mc-name {
          font-size: 15px;
          font-weight: 500;
          color: #fff;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
        .mc-meta {
          font-size: 12px;
          color: rgba(255,255,255,0.4);
          margin-top: 2px;
        }
        .mc-actions {
          display: flex;
          gap: 4px;
          flex-shrink: 0;
        }
        .mc-btn {
          background: none;
          border: none;
          font-size: 18px;
          cursor: pointer;
          padding: 6px 8px;
          border-radius: 8px;
          transition: background 0.15s;
        }
        .mc-btn:hover {
          background: rgba(255,255,255,0.08);
        }
      `}</style>
    </div>
  );
};

export default MyContentPage;