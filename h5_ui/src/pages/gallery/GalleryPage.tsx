/// 画廊页面 — 管理 AR 内容

import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StorageAPI, ARAPI } from '../../bridge/bridge';
import type { ContentMeta } from '../../bridge/types';

const GalleryPage: React.FC = () => {
  const navigate = useNavigate();
  const [contents, setContents] = useState<ContentMeta[]>([]);
  const [loading, setLoading] = useState(true);

  const loadContents = async () => {
    setLoading(true);
    try {
      const result = await StorageAPI.listContents(0, 50) as { data?: ContentMeta[] };
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

  const viewAR = (content: ContentMeta) => {
    ARAPI.start({
      contentId: content.contentId,
      videoPath: content.filePath || '',
    });
    navigate('/preview', { state: { contentId: content.contentId } });
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
      <div className="gallery-header">
        <button className="header-btn" onClick={() => navigate(-1)}>← 返回</button>
        <span className="header-title">画廊</span>
        <button className="header-btn" onClick={loadContents}>🔄</button>
      </div>

      <div className="page-content">
        {loading ? (
          <div className="gallery-loading">加载中...</div>
        ) : contents.length === 0 ? (
          <div className="gallery-empty">
            <span className="empty-icon">🖼️</span>
            <p className="empty-text">还没有内容</p>
            <p className="empty-hint">去拍摄或扫描一张照片</p>
          </div>
        ) : (
          <div className="gallery-grid">
            {contents.map((content) => (
              <div key={content.contentId} className="gallery-card">
                <div className="card-thumbnail">
                  <span className="thumb-icon">🎬</span>
                </div>
                <div className="card-info">
                  <p className="card-title">{content.title || '未命名'}</p>
                  <p className="card-meta">
                    {new Date(content.createdAt).toLocaleDateString()}
                    {' · '}
                    {content.permissions === 'public' ? '公开' : '私密'}
                  </p>
                </div>
                <div className="card-actions">
                  <button className="card-btn" onClick={() => viewAR(content)}>👁️</button>
                  <button className="card-btn" onClick={() => deleteContent(content.contentId)}>🗑️</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <style>{`
        .gallery-header {
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
        .gallery-loading, .gallery-empty {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 200px;
          gap: 8px;
          color: rgba(255,255,255,0.4);
        }
        .empty-icon {
          font-size: 48px;
        }
        .empty-text {
          font-size: 16px;
        }
        .empty-hint {
          font-size: 13px;
        }
        .gallery-grid {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }
        .gallery-card {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px;
          background: rgba(255,255,255,0.03);
          border: 1px solid rgba(255,255,255,0.06);
          border-radius: 12px;
        }
        .card-thumbnail {
          width: 56px;
          height: 56px;
          border-radius: 8px;
          background: rgba(255,255,255,0.05);
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .thumb-icon {
          font-size: 24px;
        }
        .card-info {
          flex: 1;
        }
        .card-title {
          font-size: 15px;
          font-weight: 500;
          color: #fff;
        }
        .card-meta {
          font-size: 12px;
          color: rgba(255,255,255,0.4);
          margin-top: 2px;
        }
        .card-actions {
          display: flex;
          gap: 4px;
        }
        .card-btn {
          background: none;
          border: none;
          font-size: 18px;
          cursor: pointer;
          padding: 4px 8px;
        }
      `}</style>
    </div>
  );
};

export default GalleryPage;