import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../style/my_button.dart';
import '../../style/palette.dart';
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
    final palette = context.watch<Palette>();
    final authController = context.watch<AuthController>();
    final roomController = context.watch<RoomController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        topMessageArea: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome, ${authController.profile?.username ?? "Player"}',
              style: TextStyle(
                fontFamily: palette.titleFontFamily,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () => authController.signOut(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
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
                  Text(
                    'Public Rooms',
                    style: TextStyle(
                      fontFamily: palette.titleFontFamily,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: roomController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : roomController.publicRooms.isEmpty
                            ? Center(
                                child: Text(
                                  'No public rooms available.\nCreate one to get started!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: palette.ink.withValues(alpha: 0.6),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    roomController.fetchPublicRooms(
                                  gameId: _selectedGameId,
                                ),
                                child: ListView.builder(
                                  itemCount: roomController.publicRooms.length,
                                  itemBuilder: (context, index) {
                                    final room =
                                        roomController.publicRooms[index];
                                    return _RoomCard(
                                      room: room,
                                      game: roomController.gameDefinitions
                                          .firstWhere(
                                        (g) => g.id == room.gameId,
                                        orElse: () => GameDefinition(
                                          id: room.gameId,
                                          name: 'Unknown Game',
                                          description: '',
                                          minPlayers: 2,
                                          maxPlayers: 4,
                                          defaultConfig: const {},
                                          isActive: true,
                                          createdAt: DateTime.now(),
                                        ),
                                      ),
                                      onJoin: () async {
                                        final success =
                                            await roomController.joinRoom(
                                          room.id,
                                        );
                                        if (success && mounted) {
                                          context.go('/room/${room.id}');
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
        rectangularMenuArea: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              onPressed: () => _showCreateRoomDialog(context),
              child: const Text('Create Room'),
            ),
            const SizedBox(height: 12),
            MyButton(
              onPressed: () => _showJoinByCodeDialog(context),
              child: const Text('Join by Code'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  roomController.fetchPublicRooms(gameId: _selectedGameId),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final roomController = context.read<RoomController>();
    final palette = context.read<Palette>();

    if (roomController.gameDefinitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No games available')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    GameDefinition? selectedGame = roomController.gameDefinitions.first;
    bool isPublic = true;
    int maxPlayers = selectedGame.maxPlayers;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: palette.backgroundMain,
          title: Text(
            'Create Room',
            style: TextStyle(fontFamily: palette.titleFontFamily),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    hintText: 'My Awesome Game',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GameDefinition>(
                  initialValue: selectedGame,
                  decoration: const InputDecoration(labelText: 'Game'),
                  items: roomController.gameDefinitions.map((game) {
                    return DropdownMenuItem(
                      value: game,
                      child: Text(game.name),
                    );
                  }).toList(),
                  onChanged: (game) {
                    if (game != null) {
                      setState(() {
                        selectedGame = game;
                        maxPlayers = game.maxPlayers;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Max Players:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: maxPlayers.toDouble(),
                        min: selectedGame!.minPlayers.toDouble(),
                        max: selectedGame!.maxPlayers.toDouble(),
                        divisions: selectedGame!.maxPlayers -
                            selectedGame!.minPlayers,
                        label: maxPlayers.toString(),
                        onChanged: (value) {
                          setState(() {
                            maxPlayers = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text(maxPlayers.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Public Room'),
                  subtitle: Text(
                    isPublic
                        ? 'Anyone can join'
                        : 'Invite code required to join',
                  ),
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedGame != null) {
                  Navigator.of(dialogContext).pop();

                  final room = await roomController.createRoom(
                    gameId: selectedGame!.id,
                    name: nameController.text,
                    isPublic: isPublic,
                    maxPlayers: maxPlayers,
                  );

                  if (room != null && context.mounted) {
                    context.go('/room/${room.id}');
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinByCodeDialog(BuildContext context) {
    final roomController = context.read<RoomController>();
    final palette = context.read<Palette>();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.backgroundMain,
        title: Text(
          'Join by Invite Code',
          style: TextStyle(fontFamily: palette.titleFontFamily),
        ),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Invite Code',
            hintText: 'ABC123',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.isEmpty) return;

              Navigator.of(dialogContext).pop();

              final success =
                  await roomController.joinRoomByInviteCode(code);

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
            child: const Text('Join'),
          ),
        ],
      ),
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
    final palette = context.watch<Palette>();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          name,
          style: TextStyle(
            color: isSelected ? palette.backgroundMain : palette.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: palette.backgroundCard,
        selectedColor: palette.gold,
        side: BorderSide(
          color: isSelected ? palette.gold : palette.backgroundCard,
          width: isSelected ? 2 : 1,
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: palette.gold.withValues(alpha: 0.5),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final GameDefinition game;
  final VoidCallback onJoin;

  const _RoomCard({
    required this.room,
    required this.game,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerCount = room.memberCount ?? 0;
    final isAlmostFull = playerCount >= room.maxPlayers - 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onJoin,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Room icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: palette.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.table_bar,
                  color: palette.backgroundMain,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Room info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: TextStyle(
                        fontFamily: palette.titleFontFamily,
                        fontSize: 18,
                        color: palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.casino_outlined,
                          size: 14,
                          color: palette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.name,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: palette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.hostUsername ?? "Unknown",
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: isAlmostFull ? palette.warning : palette.cyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$playerCount/${room.maxPlayers} players',
                          style: TextStyle(
                            color: isAlmostFull ? palette.warning : palette.cyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Join button
              Icon(
                Icons.arrow_forward_ios,
                color: palette.gold,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
