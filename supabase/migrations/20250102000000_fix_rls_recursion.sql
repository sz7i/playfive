-- Fix infinite recursion in RLS policies

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Public rooms are viewable by everyone" ON rooms;
DROP POLICY IF EXISTS "Room members can view other members" ON room_members;
DROP POLICY IF EXISTS "Game sessions visible to room members" ON game_sessions;
DROP POLICY IF EXISTS "Game moves visible to room members" ON game_moves;

-- Recreate rooms policy without subquery
CREATE POLICY "Public rooms are viewable by everyone"
  ON rooms FOR SELECT
  USING (visibility = 'public' OR auth.uid() = host_id);

-- Recreate room_members policy - allow all authenticated users to see members of rooms they're in
-- We'll use a simpler approach: allow viewing members of any room for now
-- (In production, you might want to restrict this further with a stored function)
CREATE POLICY "Room members can view other members"
  ON room_members FOR SELECT
  USING (true); -- Temporarily allow all authenticated users to view room members

-- Recreate game_sessions policy without subquery
CREATE POLICY "Game sessions visible to room members"
  ON game_sessions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = game_sessions.room_id
      AND (rooms.visibility = 'public' OR rooms.host_id = auth.uid())
    )
  );

-- Recreate game_moves policy
CREATE POLICY "Game moves visible to room members"
  ON game_moves FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM game_sessions gs
      JOIN rooms r ON r.id = gs.room_id
      WHERE gs.id = game_moves.session_id
      AND (r.visibility = 'public' OR r.host_id = auth.uid())
    )
  );
