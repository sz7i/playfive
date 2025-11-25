-- Initial schema for multiplayer card game platform
-- Creates all tables, RLS policies, functions, and seed data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLES
-- =====================================================

-- User profiles (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT username_length CHECK (char_length(username) >= 3 AND char_length(username) <= 20)
);

-- Game definitions (metadata about available games)
CREATE TABLE game_definitions (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  min_players INTEGER NOT NULL DEFAULT 2,
  max_players INTEGER NOT NULL DEFAULT 4,
  default_config JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rooms (game lobbies)
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id TEXT NOT NULL REFERENCES game_definitions(id),
  name TEXT NOT NULL,
  host_id UUID NOT NULL REFERENCES profiles(id),
  status TEXT NOT NULL DEFAULT 'waiting',
  visibility TEXT NOT NULL DEFAULT 'public',
  max_players INTEGER NOT NULL DEFAULT 4,
  game_config JSONB DEFAULT '{}'::jsonb,
  invite_code TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,

  CONSTRAINT valid_status CHECK (status IN ('waiting', 'playing', 'finished')),
  CONSTRAINT valid_visibility CHECK (visibility IN ('public', 'private'))
);

-- Room members
CREATE TABLE room_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  player_index INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'connected',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,

  UNIQUE(room_id, user_id),
  UNIQUE(room_id, player_index),
  CONSTRAINT valid_member_status CHECK (status IN ('connected', 'disconnected', 'left'))
);

-- Game sessions (active game state)
CREATE TABLE game_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE UNIQUE,
  game_id TEXT NOT NULL REFERENCES game_definitions(id),
  state JSONB NOT NULL DEFAULT '{}'::jsonb,
  current_turn_player_index INTEGER,
  turn_number INTEGER DEFAULT 0,
  version INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Game moves (history/audit trail)
CREATE TABLE game_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  player_index INTEGER NOT NULL,
  move_type TEXT NOT NULL,
  move_data JSONB NOT NULL,
  previous_state_version INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT message_length CHECK (char_length(message) <= 500)
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_visibility ON rooms(visibility, status);
CREATE INDEX idx_rooms_game_id ON rooms(game_id);
CREATE INDEX idx_room_members_user ON room_members(user_id);
CREATE INDEX idx_room_members_room ON room_members(room_id);
CREATE INDEX idx_game_sessions_room ON game_sessions(room_id);
CREATE INDEX idx_game_moves_session ON game_moves(session_id);
CREATE INDEX idx_chat_messages_room ON chat_messages(room_id, created_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_moves ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read all profiles, update only their own
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- game_definitions: Read-only for all authenticated users
ALTER TABLE game_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Game definitions are viewable by everyone"
  ON game_definitions FOR SELECT
  USING (true);

-- Rooms: Public rooms visible to all, private rooms only to members
CREATE POLICY "Public rooms are viewable by everyone"
  ON rooms FOR SELECT
  USING (
    visibility = 'public'
    OR auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = rooms.id
    )
  );

CREATE POLICY "Authenticated users can create rooms"
  ON rooms FOR INSERT
  WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Room hosts can update their rooms"
  ON rooms FOR UPDATE
  USING (auth.uid() = host_id);

-- Room Members: Visible to all members of the room
CREATE POLICY "Room members can view other members"
  ON room_members FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = room_members.room_id
    )
  );

CREATE POLICY "Users can join rooms"
  ON room_members FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own membership"
  ON room_members FOR UPDATE
  USING (auth.uid() = user_id);

-- Game Sessions: Visible to room members
CREATE POLICY "Game sessions visible to room members"
  ON game_sessions FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = game_sessions.room_id
    )
  );

-- Game Moves: Visible to room members, insertable by current turn player
CREATE POLICY "Game moves visible to room members"
  ON game_moves FOR SELECT
  USING (
    auth.uid() IN (
      SELECT rm.user_id
      FROM room_members rm
      JOIN game_sessions gs ON gs.room_id = rm.room_id
      WHERE gs.id = game_moves.session_id
    )
  );

-- Chat Messages: Visible to room members, insertable by members
CREATE POLICY "Chat messages visible to room members"
  ON chat_messages FOR SELECT
  USING (
    auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = chat_messages.room_id
    )
  );

CREATE POLICY "Room members can send messages"
  ON chat_messages FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND auth.uid() IN (
      SELECT user_id FROM room_members WHERE room_id = chat_messages.room_id
    )
  );

-- =====================================================
-- DATABASE FUNCTIONS
-- =====================================================

-- Function to create a new game session when room starts
CREATE OR REPLACE FUNCTION start_game_session(p_room_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_session_id UUID;
  v_game_id TEXT;
  v_initial_state JSONB;
BEGIN
  -- Get game_id from room
  SELECT game_id INTO v_game_id FROM rooms WHERE id = p_room_id;

  -- Create initial game state (placeholder - will be populated by Edge Function)
  v_initial_state := jsonb_build_object(
    'initialized', false,
    'players', jsonb_build_array()
  );

  -- Insert game session
  INSERT INTO game_sessions (room_id, game_id, state, version)
  VALUES (p_room_id, v_game_id, v_initial_state, 0)
  RETURNING id INTO v_session_id;

  -- Update room status
  UPDATE rooms
  SET status = 'playing', started_at = NOW()
  WHERE id = p_room_id;

  RETURN v_session_id;
END;
$$;

-- Function to end a game session
CREATE OR REPLACE FUNCTION end_game_session(p_session_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  -- Get room_id
  SELECT room_id INTO v_room_id FROM game_sessions WHERE id = p_session_id;

  -- Update room status
  UPDATE rooms
  SET status = 'finished', finished_at = NOW()
  WHERE id = v_room_id;
END;
$$;

-- Function to handle user profile creation after signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- This will be called by a trigger when a new user signs up
  -- For now, it's just a placeholder
  RETURN NEW;
END;
$$;

-- =====================================================
-- SEED DATA
-- =====================================================

-- Insert Oh Hell game definition
INSERT INTO game_definitions (id, name, description, min_players, max_players, default_config, is_active)
VALUES (
  'oh-hell',
  'Oh Hell',
  'A trick-taking card game with bidding. Players predict how many tricks they will win each round. Score points for exact predictions!',
  3,
  6,
  '{
    "scoring": {
      "exactBidBonus": 10,
      "perTrickPoint": 1,
      "missedBidPenalty": 0
    },
    "rounds": {
      "type": "variable",
      "startCards": 1,
      "maxCards": 7
    }
  }'::jsonb,
  true
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- GRANTS
-- =====================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;
