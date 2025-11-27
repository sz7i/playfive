# Multiplayer Card Game Platform

A real-time multiplayer card game platform built with Flutter and Supabase, supporting various card games with live synchronization.

## Quick Start

```bash
# Start Supabase backend
supabase start

# Run the app
cd flutter
flutter run -d chrome --web-port 3000
```

**App URL:** http://localhost:3000
**Database UI:** http://127.0.0.1:54323

## Project Status

**Current Phase:** Phase 3 - Game Framework
**Completion:** ~40% of MVP

### ✅ What's Working
- User authentication (signup/login)
- Room creation (public/private)
- Room browsing and filtering
- Real-time player updates
- Invite codes for private rooms
- Host game controls

### 🔄 In Progress
- Game plugin system
- Game state management
- Oh Hell card game implementation

## Documentation

- **Progress Tracker:** [PROGRESS.md](./PROGRESS.md) - Detailed accomplishments and next steps
- **Architecture Plan:** `/Users/simeon/.claude/plans/steady-drifting-wand.md` - Full system design
- **Database Schema:** `supabase/migrations/` - All table definitions and RLS policies

## Tech Stack

- **Frontend:** Flutter (iOS, Android, Web, Desktop)
- **Backend:** Supabase (PostgreSQL, Realtime, Auth, Edge Functions)
- **State Management:** Provider pattern
- **Real-time Sync:** Supabase Realtime channels

## Database Connection

```bash
# PostgreSQL connection
Host: 127.0.0.1
Port: 54322
User: postgres
Pass: postgres
DB:   postgres

# Connection string
postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

## Project Structure

```
.
├── flutter/              # Flutter app
│   ├── lib/
│   │   ├── auth/        # Authentication
│   │   ├── multiplayer/ # Room system, services
│   │   ├── game_core/   # Game framework (in progress)
│   │   ├── games/       # Game implementations
│   │   └── style/       # UI components
│   └── pubspec.yaml
├── supabase/
│   ├── migrations/      # Database schema
│   ├── functions/       # Edge Functions (coming soon)
│   └── config.toml
├── PROGRESS.md          # Development progress tracker
└── README.md            # This file
```

## Features

### Implemented
- 🔐 User authentication with profiles
- 🎮 Game room creation and management
- 👥 Real-time multiplayer lobbies
- 🔒 Public and private rooms
- 📋 Room filtering by game type
- 🎯 Host controls and permissions

### Coming Soon
- 🃏 Oh Hell card game (trick-taking with bidding)
- 💬 Text chat in rooms and games
- 🔄 Reconnection handling
- 📊 Scoreboard and statistics

## Development

### Reset Database
```bash
supabase db reset
```

### Run Tests
```bash
cd flutter
flutter test
```

### Analyze Code
```bash
cd flutter
flutter analyze
```

## First Game: Oh Hell

A trick-taking card game with bidding for 3-6 players:
- Standard 52-card deck
- Players bid on tricks they'll win
- Trump suit from remaining deck
- Exact bid = bonus points
- Multiple rounds with varying hand sizes

---

**Started:** 2025-11-26
**Current Status:** Phase 2 Complete, Phase 3 In Progress
