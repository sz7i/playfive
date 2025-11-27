import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../style/my_button.dart';
import '../../style/palette.dart';
import '../../style/responsive_screen.dart';
import '../controllers/room_controller.dart';
import '../models/room.dart';
import '../models/room_member.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;

  const RoomScreen({required this.roomId, super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    _joinRoomIfNeeded();
  }

  Future<void> _joinRoomIfNeeded() async {
    final roomController = context.read<RoomController>();

    // If we're not in this room yet, join it
    if (roomController.currentRoom?.id != widget.roomId) {
      final success = await roomController.joinRoom(widget.roomId);
      if (!success && mounted) {
        // Failed to join, go back to lobby
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomController.error ?? 'Failed to join room',
            ),
          ),
        );
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final roomController = context.watch<RoomController>();
    final room = roomController.currentRoom;

    if (room == null || room.id != widget.roomId) {
      return Scaffold(
        backgroundColor: palette.backgroundMain,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Listen for game start
    if (room.status == RoomStatus.playing && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // TODO: Navigate to game screen once implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game started! (Game screen not yet implemented)'),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        topMessageArea: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              room.name,
              style: TextStyle(
                fontFamily: palette.titleFontFamily,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await roomController.leaveRoom();
                if (mounted) {
                  context.go('/');
                }
              },
              tooltip: 'Leave Room',
            ),
          ],
        ),
        squarishMainArea: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Room info
            Card(
              color: palette.backgroundPlayArea,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Details',
                      style: TextStyle(
                        fontFamily: palette.titleFontFamily,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${_formatStatus(room.status)}'),
                    Text(
                      'Visibility: ${room.visibility == RoomVisibility.public ? "Public" : "Private"}',
                    ),
                    Text(
                      'Players: ${roomController.currentRoomMembers.where((m) => m.status == MemberStatus.connected).length}/${room.maxPlayers}',
                    ),
                    if (room.inviteCode != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Invite Code: ${room.inviteCode}',
                            style: TextStyle(
                              fontFamily: palette.titleFontFamily,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: room.inviteCode!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invite code copied!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Copy invite code',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Players list
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Players',
                    style: TextStyle(
                      fontFamily: palette.titleFontFamily,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: roomController.currentRoomMembers.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount:
                                roomController.currentRoomMembers.length,
                            itemBuilder: (context, index) {
                              final member =
                                  roomController.currentRoomMembers[index];
                              return _PlayerCard(
                                member: member,
                                isHost: member.userId == room.hostId,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        rectangularMenuArea: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (roomController.isHost &&
                room.status == RoomStatus.waiting) ...[
              MyButton(
                onPressed: roomController.currentRoomMembers
                            .where((m) => m.status == MemberStatus.connected)
                            .length >=
                        2
                    ? () async {
                        final sessionId = await roomController.startGame();
                        if (sessionId != null && mounted) {
                          // TODO: Navigate to game screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Game session created: $sessionId'),
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                roomController.error ?? 'Failed to start game',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Start Game'),
              ),
              const SizedBox(height: 8),
              Text(
                roomController.currentRoomMembers
                            .where((m) => m.status == MemberStatus.connected)
                            .length <
                        2
                    ? 'Waiting for more players...'
                    : 'Ready to start!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: palette.ink.withValues(alpha: 0.7),
                ),
              ),
            ] else if (room.status == RoomStatus.waiting) ...[
              Text(
                'Waiting for host to start...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: palette.ink.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 16),
            MyButton(
              onPressed: () async {
                await roomController.leaveRoom();
                if (mounted) {
                  context.go('/');
                }
              },
              child: const Text('Leave Room'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'Waiting';
      case RoomStatus.playing:
        return 'Playing';
      case RoomStatus.finished:
        return 'Finished';
    }
  }
}

class _PlayerCard extends StatelessWidget {
  final RoomMember member;
  final bool isHost;

  const _PlayerCard({
    required this.member,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final isOnline = member.status == MemberStatus.connected;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isOnline ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Player avatar
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isOnline
                        ? palette.goldGradient
                        : LinearGradient(
                            colors: [
                              palette.backgroundCard,
                              palette.backgroundCard,
                            ],
                          ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline ? palette.gold : palette.textDisabled,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.displayNameOrUsername[0].toUpperCase(),
                      style: TextStyle(
                        color: isOnline
                            ? palette.backgroundMain
                            : palette.textDisabled,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Online indicator
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: palette.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.backgroundCard,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.displayNameOrUsername,
                        style: TextStyle(
                          fontFamily: palette.titleFontFamily,
                          fontSize: 16,
                          color: palette.textPrimary,
                        ),
                      ),
                      if (isHost) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: palette.goldGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: palette.backgroundMain,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'HOST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: palette.backgroundMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Player ${member.playerIndex + 1}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Status
            _StatusIndicator(status: member.status),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final MemberStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    final color = switch (status) {
      MemberStatus.connected => palette.success,
      MemberStatus.disconnected => palette.warning,
      MemberStatus.left => palette.error,
    };

    final text = switch (status) {
      MemberStatus.connected => 'Online',
      MemberStatus.disconnected => 'Away',
      MemberStatus.left => 'Left',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
