# UI Kit Components Summary

Quick reference for all available components in the Card Master UI Kit.

## Import
```dart
import 'package:playfive/ui/ui_kit.dart';
```

## Components Checklist

### ✓ Buttons (7 types)
- [x] `PrimaryButton` - Golden gradient for main actions
- [x] `SecondaryButton` - Subtle button for secondary actions
- [x] `SuccessButton` - Green button for positive actions
- [x] `DisabledButton` - Shows disabled state
- [x] `SocialButton` - White button for social login
- [x] `CMIconButton` - Circular icon button
- [x] `BuyCoinsButton` - Green "Buy Coins" button
- [x] `NumberChip` - Circular number selector

### ✓ Input Fields (5 types)
- [x] `CMTextField` - Basic text input
- [x] `EmailField` - Email input with icon
- [x] `PasswordField` - Password with show/hide toggle
- [x] `SearchField` - Search with clear button
- [x] `CMDropdown` - Dropdown selector

### ✓ Cards (5 types)
- [x] `GameCard` - Display available games
- [x] `RoomCard` - Display game rooms
- [x] `LeaderboardItem` - Leaderboard row
- [x] `PlayerPosition` - Player on game table
- [x] `InfoCard` - Information display

### ✓ Dialogs (5 types)
- [x] `CMDialog` - Base dialog with golden border
- [x] `BidDialog` - Bid placement dialog
- [x] `RoundCompleteDialog` - Round results
- [x] `ConfirmDialog` - Simple confirmation
- [x] `LoadingDialog` - Loading indicator

### ✓ Navigation (5 types)
- [x] `CMBottomNav` - Bottom navigation bar
- [x] `AppHeader` - Logo header for auth
- [x] `UserHeader` - User info with balance
- [x] `RoomTopBar` - Top bar for room screens
- [x] `GameTopBar` - Minimal game table bar

### ✓ Tables & Utilities (6 types)
- [x] `CMDataTable` - Data table for results
- [x] `LeaderboardSection` - Leaderboard container
- [x] `StatsCard` - Statistics display
- [x] `CMBadge` - Status badge/chip
- [x] `EmptyState` - Empty state placeholder
- [x] `CMLoadingIndicator` - Loading spinner

## Total: 33 Components

## Screens That Can Be Built

Using these components, you can build:

1. **Login Screen**
   - AppHeader
   - EmailField
   - PasswordField
   - PrimaryButton
   - SocialButton

2. **Home/Dashboard Screen**
   - UserHeader
   - GameCard (grid/list)
   - LeaderboardSection
   - CMBottomNav

3. **Room List Screen**
   - RoomTopBar
   - RoomCard (list)
   - PrimaryButton (Create Room)

4. **Game Table Screen**
   - GameTopBar
   - PlayerPosition (4 players)
   - Playing cards area
   - BidDialog (when needed)
   - RoundCompleteDialog (when needed)

5. **Leaderboard Screen**
   - UserHeader or RoomTopBar
   - LeaderboardItem (list)
   - CMBottomNav

6. **Profile Screen**
   - UserHeader
   - StatsCard (grid)
   - CMBottomNav

7. **Shop Screen**
   - UserHeader
   - Product cards (use GameCard)
   - PrimaryButton
   - CMBottomNav

## Color Scheme

```dart
final palette = Palette();

// Backgrounds: Dark navy (#0A1628, #142038, #1A2942)
// Primary: Golden (#E8B339, #F2C94C, #D4A028)
// Secondary: Teal/Green (#1DD3B0, #27AE60)
// Text: White (#FFFFFF) & Light gray (#E2E8F0)
// Borders: Golden (#E8B339) & Dark gray (#2D3748)
```

## Common Patterns

### Full-Screen Layout
```dart
Scaffold(
  body: Container(
    decoration: BoxDecoration(
      gradient: palette.backgroundGradient,
    ),
    child: SafeArea(
      child: Column(
        children: [
          // Header
          // Content
          // Bottom Nav (if needed)
        ],
      ),
    ),
  ),
)
```

### List with Items
```dart
ListView(
  padding: const EdgeInsets.all(16),
  children: items.map((item) => RoomCard(...)).toList(),
)
```

### Grid of Cards
```dart
GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemBuilder: (context, index) => GameCard(...),
)
```

### Show Dialog
```dart
await BidDialog.show(
  context: context,
  handSize: 5,
  currentTrump: 'Spades',
  onConfirm: (bid) {
    // Handle bid
  },
);
```

## Design Tokens

### Border Radius
- Small: 12px
- Medium: 16px
- Large: 20-24px (buttons, dialogs)

### Padding
- Tight: 8px
- Normal: 12-16px
- Loose: 20-24px

### Shadows
- Card: 12px blur, 4px offset
- Button: 8px blur, 2px offset
- Glow: 16px blur (dialogs)

### Font Sizes
- Small: 11-13px
- Normal: 14-16px
- Large: 18-20px
- Extra Large: 24-28px

## Next Steps

1. **Customize**: Modify `Palette()` colors as needed
2. **Extend**: Add new components following the same patterns
3. **Test**: Build example screens to verify components
4. **Optimize**: Add animations and micro-interactions
5. **Document**: Update this guide with new components

## Support

For detailed documentation, see `UI_KIT_GUIDE.md`
