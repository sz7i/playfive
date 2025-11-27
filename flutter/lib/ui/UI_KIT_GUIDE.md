# Card Master UI Kit - Component Guide

A comprehensive UI component library based on wireframe designs with a premium casino aesthetic.

## Table of Contents
- [Installation](#installation)
- [Theme](#theme)
- [Buttons](#buttons)
- [Input Fields](#input-fields)
- [Cards](#cards)
- [Dialogs](#dialogs)
- [Navigation](#navigation)
- [Tables & Specialized Components](#tables--specialized-components)

## Installation

Import the UI kit in your Dart files:

```dart
import 'package:playfive/ui/ui_kit.dart';
```

## Theme

### Palette

Access the color palette and design tokens:

```dart
final palette = Palette();

// Background colors
palette.backgroundMain        // Deep navy
palette.backgroundSecondary   // Lighter navy
palette.backgroundElevated    // Card surfaces

// Primary colors
palette.goldLight             // Light gold
palette.goldMedium            // Medium gold (default)
palette.goldDark              // Dark gold

// Secondary colors
palette.tealLight             // Bright teal
palette.greenSuccess          // Success green
palette.error                 // Error red

// Text colors
palette.textPrimary           // White
palette.textSecondary         // Light gray
palette.textTertiary          // Medium gray

// Gradients
palette.backgroundGradient    // Navy gradient for backgrounds
palette.goldGradient          // Gold gradient for buttons
palette.tealGradient          // Teal gradient

// Shadows
palette.cardShadow            // For cards
palette.buttonShadow          // For buttons
palette.glowShadow            // Golden glow effect
```

## Buttons

### PrimaryButton

Golden gradient button for primary actions (LOG IN, CONFIRM BID, CREATE ROOM).

```dart
PrimaryButton(
  text: 'Log In',
  onPressed: () {
    // Handle tap
  },
  isLoading: false,          // Optional: show loading spinner
  width: 200,                // Optional: custom width
  icon: Icons.login,         // Optional: add icon
)
```

### SecondaryButton

Subtle button for secondary actions.

```dart
SecondaryButton(
  text: 'Cancel',
  onPressed: () {
    // Handle tap
  },
  width: 200,                // Optional
  icon: Icons.close,         // Optional
)
```

### SuccessButton

Green button for positive actions (JOIN).

```dart
SuccessButton(
  text: 'Join',
  onPressed: () {
    // Handle tap
  },
  width: 80,                 // Optional
  height: 40,                // Optional (default: 40)
)
```

### DisabledButton

Displays disabled state (FULL).

```dart
const DisabledButton(
  text: 'Full',
  width: 80,
  height: 40,
)
```

### SocialButton

White button for social login.

```dart
SocialButton(
  icon: Icon(Icons.g_mobiledata), // Your Google icon
  label: 'Google',
  onPressed: () {
    // Handle social login
  },
)
```

### CMIconButton

Circular icon button.

```dart
CMIconButton(
  icon: Icons.arrow_back,
  onPressed: () {
    // Handle tap
  },
  size: 40,                  // Optional (default: 40)
  backgroundColor: null,     // Optional: custom color
  iconColor: null,           // Optional: custom icon color
)
```

### BuyCoinsButton

Green button with icon for purchasing coins.

```dart
BuyCoinsButton(
  onPressed: () {
    // Handle purchase
  },
)
```

### NumberChip

Circular number selector for bid dialog.

```dart
NumberChip(
  number: 3,
  isSelected: selectedBid == 3,
  onTap: () {
    setState(() => selectedBid = 3);
  },
)
```

## Input Fields

### CMTextField

Basic text input with optional icon.

```dart
CMTextField(
  hintText: 'Enter your name',
  prefixIcon: Icons.person,
  controller: nameController,
  keyboardType: TextInputType.text,
  enabled: true,
  maxLines: 1,
  onChanged: (value) {
    // Handle change
  },
)
```

### EmailField

Pre-configured email input.

```dart
EmailField(
  hintText: 'Email Address',
  controller: emailController,
  onChanged: (value) {
    // Handle change
  },
)
```

### PasswordField

Password input with show/hide toggle.

```dart
PasswordField(
  hintText: 'Password',
  controller: passwordController,
  onChanged: (value) {
    // Handle change
  },
)
```

### SearchField

Search input with clear button.

```dart
SearchField(
  hintText: 'Search rooms...',
  controller: searchController,
  onChanged: (value) {
    // Handle search
  },
  onClear: () {
    searchController.clear();
  },
)
```

### CMDropdown

Dropdown selector with custom styling.

```dart
CMDropdown<String>(
  hintText: 'Select game',
  value: selectedGame,
  items: [
    DropdownMenuItem(value: 'oh_hell', child: Text('Oh Hell')),
    DropdownMenuItem(value: 'uno', child: Text('UNO')),
  ],
  onChanged: (value) {
    setState(() => selectedGame = value);
  },
  prefixIcon: Icons.games,   // Optional
)
```

## Cards

### GameCard

Card for displaying available games.

```dart
GameCard(
  title: 'Oh Hell',
  subtitle: 'Live Game',
  imageUrl: 'assets/images/oh_hell.png',
  isAvailable: true,
  onPlay: () {
    // Navigate to game
  },
)
```

### RoomCard

Card for displaying game rooms.

```dart
RoomCard(
  roomName: '1. "Casual Lounge"',
  stake: '\$100',
  playerCount: '(2/5)',
  isFull: false,
  onJoin: () {
    // Join room
  },
)
```

### LeaderboardItem

Row item for leaderboard display.

```dart
LeaderboardItem(
  rank: 1,
  playerName: 'Player Name',
  avatarUrl: 'https://...',
  score: 55000,
  isCurrentUser: false,
)
```

### PlayerPosition

Player indicator for game table.

```dart
PlayerPosition(
  playerName: 'You',
  avatarUrl: null,
  bidInfo: 'Bid 1 | Won 1',
  winInfo: 'Opp',
  isActive: true,
)
```

### InfoCard

Information display card.

```dart
InfoCard(
  title: 'Stake',
  value: '\$100',
  icon: Icons.attach_money,
  valueColor: palette.goldMedium,
)
```

## Dialogs

### CMDialog (Base)

Generic dialog with golden border.

```dart
await CMDialog.show(
  context: context,
  title: 'Confirm',
  content: Text('Are you sure?'),
  actions: [
    SecondaryButton(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      width: double.infinity,
    ),
    PrimaryButton(
      text: 'Confirm',
      onPressed: () {
        // Handle confirm
        Navigator.pop(context);
      },
      width: double.infinity,
    ),
  ],
  dismissible: true,
);
```

### BidDialog

Specialized dialog for placing bids.

```dart
await BidDialog.show(
  context: context,
  handSize: 5,
  currentTrump: 'Spades (♠)',
  maxBid: 5,
  onConfirm: (bid) {
    // Handle bid placement
    print('Bid placed: $bid');
  },
);
```

### RoundCompleteDialog

Shows round results in a table.

```dart
await RoundCompleteDialog.show(
  context: context,
  results: [
    {
      'player': 'You',
      'bid': 2,
      'won': 2,
      'roundPoints': 12,
      'totalScore': 55,
    },
    {
      'player': 'Alice',
      'bid': 0,
      'won': 1,
      'roundPoints': -1,
      'totalScore': 40,
    },
  ],
  nextRoundInfo: 'Next Round starts in 4s...',
  onContinue: () {
    Navigator.pop(context);
  },
);
```

### ConfirmDialog

Simple confirmation dialog.

```dart
final confirmed = await ConfirmDialog.show(
  context: context,
  title: 'Leave Game?',
  message: 'Are you sure you want to leave?',
  confirmText: 'Leave',
  cancelText: 'Stay',
);

if (confirmed) {
  // Handle leave
}
```

### LoadingDialog

Loading indicator dialog.

```dart
// Show loading
LoadingDialog.show(
  context: context,
  message: 'Joining room...',
);

// Hide loading
LoadingDialog.hide(context);
```

## Navigation

### CMBottomNav

Bottom navigation bar.

```dart
CMBottomNav(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() => _currentIndex = index);
  },
)
```

### AppHeader

Logo header for auth screens.

```dart
AppHeader(
  showBackButton: false,
  onBack: () {
    Navigator.pop(context);
  },
)
```

### UserHeader

User info header with avatar and balance.

```dart
UserHeader(
  username: 'Player Name',
  balance: '\$12,500',
  avatarUrl: 'https://...',
  onBuyCoins: () {
    // Show buy coins screen
  },
  onProfileTap: () {
    // Navigate to profile
  },
)
```

### RoomTopBar

Top bar for room screens.

```dart
RoomTopBar(
  balance: '\$12,500',
  title: 'Oh Hell Rooms',
  onBack: () => Navigator.pop(context),
  onFilter: () {
    // Show filter options
  },
)
```

### GameTopBar

Minimal top bar for game table.

```dart
GameTopBar(
  avatarUrl: 'https://...',
  onSettings: () {
    // Show settings
  },
  onBack: () => Navigator.pop(context),
)
```

## Tables & Specialized Components

### CMDataTable

Data table for results.

```dart
CMDataTable(
  headers: ['Player', 'Bid', 'Won', 'Pts', 'Total'],
  rows: [
    ['You', '2', '2', '+12', '55'],
    ['Alice', '0', '1', '-1', '40'],
  ],
  rowColors: [null, null],
  columnAlignments: [
    TextAlign.left,
    TextAlign.center,
    TextAlign.center,
    TextAlign.center,
    TextAlign.center,
  ],
)
```

### LeaderboardSection

Container for leaderboard items.

```dart
LeaderboardSection(
  title: 'Daily Leaderboard Preview',
  items: [
    LeaderboardItem(rank: 1, playerName: 'Alice', avatarUrl: '', score: 55000),
    LeaderboardItem(rank: 2, playerName: 'Bob', avatarUrl: '', score: 43000),
  ],
  showViewAll: true,
  onViewAll: () {
    // Navigate to full leaderboard
  },
)
```

### StatsCard

Statistics display card.

```dart
StatsCard(
  label: 'Games Won',
  value: '42',
  icon: Icons.emoji_events,
  valueColor: palette.goldMedium,
)
```

### CMBadge

Small badge/chip for status.

```dart
CMBadge(
  text: 'New',
  backgroundColor: palette.success,
  textColor: palette.textPrimary,
)
```

### EmptyState

Empty state placeholder.

```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No rooms available',
  message: 'Create a new room to get started',
  action: PrimaryButton(
    text: 'Create Room',
    onPressed: () {
      // Create room
    },
  ),
)
```

### CMLoadingIndicator

Loading spinner.

```dart
const CMLoadingIndicator(
  message: 'Loading rooms...',
)
```

## Design Principles

### Colors

- **Dark Navy Backgrounds**: Reduce eye strain during gaming
- **Golden Accents**: Premium, casino-like feel
- **Teal/Green**: Secondary actions and success states
- **White Text**: High contrast for readability

### Typography

- **Title Font**: Permanent Marker (for "CARD MASTER" logo)
- **Body Font**: Roboto (for UI text)
- **Letter Spacing**: Generous spacing for uppercase text

### Spacing

- **Card Padding**: 12-16px
- **Dialog Padding**: 20px
- **Component Margins**: 8-16px
- **Border Radius**: 12-24px (larger for buttons)

### Shadows

All cards and buttons include subtle shadows for depth:
- Cards: 12px blur, 4px offset
- Buttons: 8px blur, 2px offset
- Golden glow: 16px blur for dialogs

## Examples

### Complete Login Screen

```dart
import 'package:playfive/ui/ui_kit.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: palette.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const AppHeader(),
                const Spacer(),
                EmailField(
                  hintText: 'Email Address',
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  hintText: 'Password',
                  controller: passwordController,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Log In',
                  onPressed: () {
                    // Handle login
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
                Text(
                  'Or continue with',
                  style: TextStyle(
                    color: palette.textTertiary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(
                      icon: Icon(Icons.g_mobiledata),
                      label: 'Google',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    SocialButton(
                      icon: Icon(Icons.apple),
                      label: 'Apple',
                      onPressed: () {},
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Complete Room List Screen

```dart
import 'package:playfive/ui/ui_kit.dart';

class RoomListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: palette.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              RoomTopBar(
                balance: '\$12,500',
                title: 'Oh Hell Rooms',
                onBack: () => Navigator.pop(context),
                onFilter: () {},
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'FEATURED GAMES:',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    RoomCard(
                      roomName: '1. "Casual Lounge"',
                      stake: '\$100',
                      playerCount: '(2/5)',
                      onJoin: () {},
                    ),
                    RoomCard(
                      roomName: '2. "HighRollers Table"',
                      stake: '\$5000',
                      playerCount: '(4/4)',
                      isFull: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  text: 'Create Room',
                  icon: Icons.add,
                  onPressed: () {},
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Consistent Spacing**: Use 8px increments (8, 16, 24, 32)
2. **Accessibility**: Ensure text has sufficient contrast
3. **Responsive**: Test on multiple screen sizes
4. **Loading States**: Always show feedback during async operations
5. **Error Handling**: Display clear error messages
6. **Empty States**: Use EmptyState component when no data
7. **Gradients**: Use palette gradients for consistency
8. **Uppercase**: Use uppercase for button labels and headers

## Troubleshooting

### Component not rendering?
- Check that you've imported `package:playfive/ui/ui_kit.dart`
- Verify parent widget has size constraints

### Colors look different?
- Ensure you're using `Palette()` instance
- Check for parent Container background colors

### Buttons not responding?
- Verify `onPressed` is not null
- Check if button is inside a scrollable widget

### Text overflowing?
- Use `Expanded` or `Flexible` widgets
- Set `maxLines` and `overflow` properties

## Contributing

When adding new components:
1. Follow existing naming conventions (CM prefix for generic components)
2. Use Palette() for all colors
3. Add comprehensive documentation
4. Include usage examples
5. Export in `ui_kit.dart`
