import 'package:flutter/material.dart';
import '../../style/palette.dart';
import 'buttons.dart';

/// Bottom navigation bar with icons
class CMBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CMBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: palette.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: palette.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.pureBlack.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.leaderboard,
            label: 'Leaderboard',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.shopping_bag,
            label: 'Shop',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? palette.goldMedium : palette.textTertiary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? palette.goldMedium : palette.textTertiary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// App header with logo for login/auth screens
class AppHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo and title
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card icon/logo placeholder
              Icon(
                Icons.style,
                size: 64,
                color: palette.goldMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'CARD MASTER',
                style: TextStyle(
                  fontFamily: palette.titleFontFamily,
                  color: palette.goldMedium,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          // Back button
          if (showBackButton)
            Positioned(
              left: 16,
              child: CMIconButton(
                icon: Icons.arrow_back,
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}

/// User header with avatar, username, and balance
class UserHeader extends StatelessWidget {
  final String username;
  final String balance;
  final String? avatarUrl;
  final VoidCallback? onBuyCoins;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;

  const UserHeader({
    super.key,
    required this.username,
    required this.balance,
    this.avatarUrl,
    this.onBuyCoins,
    this.onProfileTap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: palette.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar and username
          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: palette.backgroundCard,
                    backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null || avatarUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 28,
                            color: palette.textTertiary,
                          )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Username and balance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 14,
                              color: palette.goldMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              balance,
                              style: TextStyle(
                                color: palette.goldMedium,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buy coins button
          if (onBuyCoins != null) ...[
            BuyCoinsButton(
              onPressed: onBuyCoins,
            ),
            const SizedBox(width: 8),
          ],

          // Logout button
          if (onLogout != null)
            CMIconButton(
              icon: Icons.logout,
              onPressed: onLogout,
              size: 36,
            ),
        ],
      ),
    );
  }
}

/// Top bar for room screens with back button and balance
class RoomTopBar extends StatelessWidget {
  final String balance;
  final VoidCallback? onBack;
  final VoidCallback? onFilter;
  final String? title;

  const RoomTopBar({
    super.key,
    required this.balance,
    this.onBack,
    this.onFilter,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: palette.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (onBack != null)
            CMIconButton(
              icon: Icons.arrow_back,
              onPressed: onBack,
            ),

          const SizedBox(width: 12),

          // Balance chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.backgroundElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 16,
                  color: palette.goldMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  balance,
                  style: TextStyle(
                    color: palette.goldMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Title
          if (title != null)
            Expanded(
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(width: 12),

          // Filter button
          if (onFilter != null)
            CMIconButton(
              icon: Icons.filter_list,
              onPressed: onFilter,
            ),
        ],
      ),
    );
  }
}

/// Game table top bar with player info and settings
class GameTopBar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;

  const GameTopBar({
    super.key,
    this.avatarUrl,
    this.onSettings,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player avatar
          if (avatarUrl != null)
            CircleAvatar(
              radius: 20,
              backgroundColor: palette.backgroundCard,
              backgroundImage:
                  avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 24,
                      color: palette.textTertiary,
                    )
                  : null,
            )
          else if (onBack != null)
            CMIconButton(
              icon: Icons.arrow_back,
              onPressed: onBack,
            )
          else
            const SizedBox(width: 40),

          // Settings button
          if (onSettings != null)
            CMIconButton(
              icon: Icons.settings,
              onPressed: onSettings,
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}
