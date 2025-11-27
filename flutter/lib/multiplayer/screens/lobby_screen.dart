import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../ui/ui_kit.dart';
import '../../style/responsive_screen.dart';
import '../controllers/room_controller.dart';
import '../models/game_definition.dart';
import '../models/room.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? _selectedGameId;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomController = context.read<RoomController>();
      roomController.initialize().then((_) {
        roomController.fetchPublicRooms();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    final authController = context.watch<AuthController>();
    final roomController = context.watch<RoomController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: palette.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // User Header
              if (authController.profile != null)
                UserHeader(
                  username: authController.profile!.username ?? 'Player',
                  balance: '\$12,500', // TODO: Get real balance
                  avatarUrl: authController.profile!.avatarUrl,
                  onBuyCoins: () {
                    // TODO: Navigate to shop
                  },
                  onProfileTap: () {
                    // TODO: Navigate to profile
                  },
                  onLogout: () async {
                    final confirmed = await ConfirmDialog.show(
                      context: context,
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      cancelText: 'Cancel',
                    );

                    if (confirmed && mounted) {
                      await authController.signOut();
                      if (mounted) {
                        context.go('/auth');
                      }
                    }
                  },
                ),

              // Main content
              Expanded(
                child: ResponsiveScreen(
                  squarishMainArea: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game selector
            if (roomController.gameDefinitions.isNotEmpty) ...[
              Text(
                'Select Game',
                style: TextStyle(
                  fontFamily: palette.titleFontFamily,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: roomController.gameDefinitions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _GameChip(
                        name: 'All Games',
                        isSelected: _selectedGameId == null,
                        onTap: () {
                          setState(() {
                            _selectedGameId = null;
                          });
                          roomController.fetchPublicRooms();
                        },
                      );
                    }
                    final game = roomController.gameDefinitions[index - 1];
                    return _GameChip(
                      name: game.name,
                      isSelected: _selectedGameId == game.id,
                      onTap: () {
                        setState(() {
                          _selectedGameId = game.id;
                        });
                        roomController.fetchPublicRooms(gameId: game.id);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Public rooms list
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'PUBLIC ROOMS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: roomController.isLoading
                        ? const CMLoadingIndicator(
                            message: 'Loading rooms...',
                          )
                        : roomController.publicRooms.isEmpty
                            ? EmptyState(
                                icon: Icons.inbox,
                                title: 'No rooms available',
                                message:
                                    'Create a new room to get started!',
                                action: PrimaryButton(
                                  text: 'Create Room',
                                  onPressed: () =>
                                      _showCreateRoomDialog(context),
                                  icon: Icons.add,
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    roomController.fetchPublicRooms(
                                  gameId: _selectedGameId,
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: roomController.publicRooms.length,
                                  itemBuilder: (context, index) {
                                    final room =
                                        roomController.publicRooms[index];
                                    final playerCount =
                                        room.memberCount ?? 0;
                                    final isFull =
                                        playerCount >= room.maxPlayers;

                                    return RoomCard(
                                      roomName: '${index + 1}. "${room.name}"',
                                      stake: '\$100', // TODO: Get real stake
                                      playerCount:
                                          '($playerCount/${room.maxPlayers})',
                                      isFull: isFull,
                                      onJoin: isFull
                                          ? null
                                          : () async {
                                              final success =
                                                  await roomController
                                                      .joinRoom(room.id);
                                              if (success && mounted) {
                                                context
                                                    .go('/room/${room.id}');
                                              }
                                            },
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
                  rectangularMenuArea: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrimaryButton(
                          text: 'Create Room',
                          onPressed: () => _showCreateRoomDialog(context),
                          icon: Icons.add,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'Join by Code',
                          onPressed: () => _showJoinByCodeDialog(context),
                          icon: Icons.vpn_key,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'UI Demo',
                          onPressed: () => context.go('/ui-demo'),
                          icon: Icons.palette,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final roomController = context.read<RoomController>();
    final palette = Palette();

    if (roomController.gameDefinitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No games available')),
      );
      return;
    }

    final nameController = TextEditingController();
    GameDefinition selectedGame = roomController.gameDefinitions.first;
    bool isPublic = true;
    int maxPlayers = selectedGame.maxPlayers;

    CMDialog.show(
      context: context,
      title: 'Create Room',
      dismissible: true,
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CMTextField(
              hintText: 'Room Name',
              controller: nameController,
              prefixIcon: Icons.meeting_room,
            ),
            const SizedBox(height: 16),
            Text(
              'Max Players: $maxPlayers',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 14,
              ),
            ),
            Slider(
              value: maxPlayers.toDouble(),
              min: selectedGame.minPlayers.toDouble(),
              max: selectedGame.maxPlayers.toDouble(),
              divisions:
                  selectedGame.maxPlayers - selectedGame.minPlayers,
              label: maxPlayers.toString(),
              activeColor: palette.goldMedium,
              onChanged: (value) {
                setState(() {
                  maxPlayers = value.toInt();
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: isPublic,
                  activeColor: palette.goldMedium,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value ?? true;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    isPublic
                        ? 'Public Room (Anyone can join)'
                        : 'Private Room (Invite code required)',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          width: double.infinity,
        ),
        PrimaryButton(
          text: 'Create',
          onPressed: () async {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a room name'),
                ),
              );
              return;
            }

            Navigator.of(context).pop();

            final room = await roomController.createRoom(
              gameId: selectedGame.id,
              name: nameController.text,
              isPublic: isPublic,
              maxPlayers: maxPlayers,
            );

            if (room != null && context.mounted) {
              context.go('/room/${room.id}');
            }
          },
          width: double.infinity,
        ),
      ],
    );
  }

  void _showJoinByCodeDialog(BuildContext context) {
    final roomController = context.read<RoomController>();
    final codeController = TextEditingController();

    CMDialog.show(
      context: context,
      title: 'Join by Invite Code',
      content: CMTextField(
        hintText: 'Enter Invite Code',
        controller: codeController,
        prefixIcon: Icons.vpn_key,
      ),
      actions: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          width: double.infinity,
        ),
        PrimaryButton(
          text: 'Join',
          onPressed: () async {
            final code = codeController.text.trim().toUpperCase();
            if (code.isEmpty) return;

            Navigator.of(context).pop();

            LoadingDialog.show(
              context: context,
              message: 'Joining room...',
            );

            final success =
                await roomController.joinRoomByInviteCode(code);

            if (context.mounted) {
              LoadingDialog.hide(context);
            }

            if (success && context.mounted) {
              context.go('/room/${roomController.currentRoom!.id}');
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    roomController.error ?? 'Failed to join room',
                  ),
                ),
              );
            }
          },
          width: double.infinity,
        ),
      ],
    );
  }
}

class _GameChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? palette.goldMedium
                : palette.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? palette.goldMedium : palette.borderLight,
              width: 2,
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? palette.textOnGold : palette.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
