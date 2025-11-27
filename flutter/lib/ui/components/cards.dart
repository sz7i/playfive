import 'package:flutter/material.dart';
import '../../style/palette.dart';
import 'buttons.dart';

/// Game card for displaying available games on home screen
class GameCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final VoidCallback? onPlay;
  final bool isAvailable;

  const GameCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.onPlay,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: palette.backgroundCard,
                    child: Icon(
                      Icons.casino,
                      size: 48,
                      color: palette.textTertiary,
                    ),
                  );
                },
              ),
            ),
          ),

          // Game info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: isAvailable
                      ? SuccessButton(
                          text: 'Play',
                          onPressed: onPlay,
                          height: 36,
                        )
                      : SecondaryButton(
                          text: 'Play',
                          onPressed: null,
                          width: double.infinity,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Room card for displaying available game rooms
class RoomCard extends StatelessWidget {
  final String roomName;
  final String stake;
  final String playerCount;
  final bool isFull;
  final VoidCallback? onJoin;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.stake,
    required this.playerCount,
    this.isFull = false,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Room number circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.backgroundCard,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                roomName.substring(0, 1),
                style: TextStyle(
                  color: palette.goldMedium,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Stake: $stake',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Players: $playerCount',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Join button
          SizedBox(
            width: 80,
            child: isFull
                ? const DisabledButton(text: 'Full', width: 80)
                : SuccessButton(
                    text: 'Join',
                    onPressed: onJoin,
                    width: 80,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Leaderboard item for displaying player rankings
class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String playerName;
  final String avatarUrl;
  final int score;
  final bool isCurrentUser;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.playerName,
    required this.avatarUrl,
    required this.score,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? palette.backgroundCard.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: rank <= 3 ? palette.goldMedium : palette.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: palette.backgroundCard,
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: palette.textTertiary,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Player name
          Expanded(
            child: Text(
              playerName,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score
          Text(
            score.toString(),
            style: TextStyle(
              color: palette.goldMedium,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Player position indicator for game table
class PlayerPosition extends StatelessWidget {
  final String playerName;
  final String? avatarUrl;
  final String? bidInfo;
  final String? winInfo;
  final bool isActive;

  const PlayerPosition({
    super.key,
    required this.playerName,
    this.avatarUrl,
    this.bidInfo,
    this.winInfo,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: palette.goldMedium, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: palette.backgroundCard,
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 24,
                    color: palette.textTertiary,
                  )
                : null,
          ),

          const SizedBox(height: 4),

          // Player name
          Text(
            playerName,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Bid/Win info
          if (bidInfo != null) ...[
            const SizedBox(height: 2),
            Text(
              bidInfo!,
              style: TextStyle(
                color: palette.textTertiary,
                fontSize: 10,
              ),
            ),
          ],

          if (winInfo != null) ...[
            const SizedBox(height: 2),
            Text(
              winInfo!,
              style: TextStyle(
                color: palette.success,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info card for displaying game information
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: palette.textTertiary,
              size: 20,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? palette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
