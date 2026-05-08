-- ═══════════════════════════════════════════════════════════
-- Claude Skills Registry - Supabase Schema
-- 社区版：点赞、评论、收藏（不需要强制登录）
-- ═══════════════════════════════════════════════════════════

-- 1. 技能统计表（点赞数、评论数）
CREATE TABLE IF NOT EXISTS skill_stats (
  skill_install TEXT PRIMARY KEY,           -- 技能安装路径，如 "openai/codex/skill-installer"
  likes_count INT DEFAULT 0,                -- 点赞总数
  comments_count INT DEFAULT 0,             -- 评论总数
  views_count INT DEFAULT 0,                -- 浏览次数
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 点赞记录表（防止重复点赞）
CREATE TABLE IF NOT EXISTS skill_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  skill_install TEXT NOT NULL,              -- 技能安装路径
  device_id TEXT NOT NULL,                  -- 设备ID（匿名用户）
  user_id UUID REFERENCES auth.users,       -- 可选：登录用户ID
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- 每个设备/用户只能点赞一次
  UNIQUE(skill_install, device_id)
);

-- 3. 评论表
CREATE TABLE IF NOT EXISTS skill_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  skill_install TEXT NOT NULL,              -- 技能安装路径
  device_id TEXT NOT NULL,                  -- 设备ID
  user_id UUID REFERENCES auth.users,       -- 可选：登录用户ID
  nickname TEXT DEFAULT 'Anonymous',        -- 昵称
  content TEXT NOT NULL,                    -- 评论内容
  rating INT CHECK (rating >= 1 AND rating <= 5), -- 1-5星评分
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 收藏表（需要设备ID或用户ID）
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  skill_install TEXT NOT NULL,
  device_id TEXT,                           -- 设备ID（匿名用户）
  user_id UUID REFERENCES auth.users,       -- 登录用户ID
  folder TEXT DEFAULT 'default',            -- 收藏夹名称
  note TEXT,                                -- 用户笔记
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- 每个设备/用户每个技能只收藏一次
  UNIQUE(skill_install, device_id),
  UNIQUE(skill_install, user_id)
);

-- ═══════════════════════════════════════════════════════════
-- 索引优化
-- ═══════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_skill_stats_likes ON skill_stats(likes_count DESC);
CREATE INDEX IF NOT EXISTS idx_skill_comments_skill ON skill_comments(skill_install);
CREATE INDEX IF NOT EXISTS idx_skill_comments_created ON skill_comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_favorites_device ON user_favorites(device_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_user ON user_favorites(user_id);

-- ═══════════════════════════════════════════════════════════
-- RLS (Row Level Security) 策略
-- ═══════════════════════════════════════════════════════════

-- 启用 RLS
ALTER TABLE skill_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- skill_stats: 所有人可读，通过函数更新
CREATE POLICY "Anyone can read stats" ON skill_stats
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert stats" ON skill_stats
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update stats" ON skill_stats
  FOR UPDATE USING (true);

-- skill_likes: 所有人可读可写
CREATE POLICY "Anyone can read likes" ON skill_likes
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert likes" ON skill_likes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete own likes" ON skill_likes
  FOR DELETE USING (true);

-- skill_comments: 所有人可读，可写自己的评论
CREATE POLICY "Anyone can read comments" ON skill_comments
  FOR SELECT USING (is_deleted = false);

CREATE POLICY "Anyone can insert comments" ON skill_comments
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own comments" ON skill_comments
  FOR UPDATE USING (true);

-- user_favorites: 只能读写自己的收藏
CREATE POLICY "Users can read own favorites" ON user_favorites
  FOR SELECT USING (true);

CREATE POLICY "Users can insert favorites" ON user_favorites
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete own favorites" ON user_favorites
  FOR DELETE USING (true);

-- ═══════════════════════════════════════════════════════════
-- 辅助函数
-- ═══════════════════════════════════════════════════════════

-- 点赞函数（自动更新统计）
CREATE OR REPLACE FUNCTION toggle_like(p_skill_install TEXT, p_device_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_exists BOOLEAN;
  v_new_count INT;
BEGIN
  -- 检查是否已点赞
  SELECT EXISTS(
    SELECT 1 FROM skill_likes
    WHERE skill_install = p_skill_install AND device_id = p_device_id
  ) INTO v_exists;

  IF v_exists THEN
    -- 取消点赞
    DELETE FROM skill_likes
    WHERE skill_install = p_skill_install AND device_id = p_device_id;

    UPDATE skill_stats
    SET likes_count = GREATEST(0, likes_count - 1), updated_at = NOW()
    WHERE skill_install = p_skill_install;
  ELSE
    -- 添加点赞
    INSERT INTO skill_likes (skill_install, device_id)
    VALUES (p_skill_install, p_device_id);

    -- 确保 skill_stats 存在
    INSERT INTO skill_stats (skill_install, likes_count)
    VALUES (p_skill_install, 1)
    ON CONFLICT (skill_install)
    DO UPDATE SET likes_count = skill_stats.likes_count + 1, updated_at = NOW();
  END IF;

  -- 返回新的点赞数
  SELECT likes_count INTO v_new_count
  FROM skill_stats WHERE skill_install = p_skill_install;

  RETURN json_build_object(
    'liked', NOT v_exists,
    'count', COALESCE(v_new_count, 0)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 添加评论函数
CREATE OR REPLACE FUNCTION add_comment(
  p_skill_install TEXT,
  p_device_id TEXT,
  p_content TEXT,
  p_nickname TEXT DEFAULT 'Anonymous',
  p_rating INT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_comment_id UUID;
BEGIN
  -- 插入评论
  INSERT INTO skill_comments (skill_install, device_id, content, nickname, rating)
  VALUES (p_skill_install, p_device_id, p_content, p_nickname, p_rating)
  RETURNING id INTO v_comment_id;

  -- 更新评论计数
  INSERT INTO skill_stats (skill_install, comments_count)
  VALUES (p_skill_install, 1)
  ON CONFLICT (skill_install)
  DO UPDATE SET comments_count = skill_stats.comments_count + 1, updated_at = NOW();

  RETURN json_build_object('id', v_comment_id, 'success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 获取技能统计和用户状态
CREATE OR REPLACE FUNCTION get_skill_stats(p_skill_install TEXT, p_device_id TEXT)
RETURNS JSON AS $$
DECLARE
  v_stats skill_stats%ROWTYPE;
  v_liked BOOLEAN;
  v_favorited BOOLEAN;
BEGIN
  -- 获取统计
  SELECT * INTO v_stats FROM skill_stats WHERE skill_install = p_skill_install;

  -- 检查是否点赞
  SELECT EXISTS(
    SELECT 1 FROM skill_likes
    WHERE skill_install = p_skill_install AND device_id = p_device_id
  ) INTO v_liked;

  -- 检查是否收藏
  SELECT EXISTS(
    SELECT 1 FROM user_favorites
    WHERE skill_install = p_skill_install AND device_id = p_device_id
  ) INTO v_favorited;

  RETURN json_build_object(
    'likes_count', COALESCE(v_stats.likes_count, 0),
    'comments_count', COALESCE(v_stats.comments_count, 0),
    'views_count', COALESCE(v_stats.views_count, 0),
    'liked', COALESCE(v_liked, false),
    'favorited', COALESCE(v_favorited, false)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 获取热门技能排行
CREATE OR REPLACE FUNCTION get_trending_skills(p_limit INT DEFAULT 50)
RETURNS TABLE (
  skill_install TEXT,
  likes_count INT,
  comments_count INT,
  score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.skill_install,
    s.likes_count,
    s.comments_count,
    (s.likes_count * 2 + s.comments_count)::NUMERIC AS score
  FROM skill_stats s
  ORDER BY score DESC, s.updated_at DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
