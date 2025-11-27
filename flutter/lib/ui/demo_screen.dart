import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui_kit.dart';

/// Demo screen showcasing all UI components from the Card Master UI Kit
class UIKitDemoScreen extends StatefulWidget {
  const UIKitDemoScreen({super.key});

  @override
  State<UIKitDemoScreen> createState() => _UIKitDemoScreenState();
}

class _UIKitDemoScreenState extends State<UIKitDemoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  int _selectedBid = 0;
  int _bottomNavIndex = 0;
  String? _selectedDropdown;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
              // Header
              RoomTopBar(
                balance: '\$12,500',
                title: 'UI Kit Demo',
                onBack: () => Navigator.of(context).pop(),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection(
                      'Buttons',
                      [
                        const Text(
                          'Primary Button',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          text: 'Primary Button',
                          onPressed: () => _showSnackBar('Primary tapped'),
                          icon: Icons.play_arrow,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Primary Button (Loading)',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          text: 'Loading...',
                          onPressed: null,
                          isLoading: true,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Secondary Button',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Secondary Button',
                          onPressed: () => _showSnackBar('Secondary tapped'),
                          icon: Icons.settings,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Success & Disabled Buttons',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SuccessButton(
                                text: 'Join',
                                onPressed: () => _showSnackBar('Join tapped'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: DisabledButton(text: 'Full'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Social Login Buttons',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(
                              icon: const Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 28,
                              ),
                              label: 'Google',
                              onPressed: () => _showSnackBar('Google login'),
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              icon: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 24,
                              ),
                              label: 'Apple',
                              onPressed: () => _showSnackBar('Apple login'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Icon Buttons',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CMIconButton(
                              icon: Icons.arrow_back,
                              onPressed: () => _showSnackBar('Back'),
                            ),
                            const SizedBox(width: 12),
                            CMIconButton(
                              icon: Icons.settings,
                              onPressed: () => _showSnackBar('Settings'),
                            ),
                            const SizedBox(width: 12),
                            CMIconButton(
                              icon: Icons.logout,
                              onPressed: () => _showSnackBar('Logout'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Buy Coins & Number Chips',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BuyCoinsButton(
                              onPressed: () => _showSnackBar('Buy coins'),
                            ),
                            ...List.generate(
                              6,
                              (i) => NumberChip(
                                number: i,
                                isSelected: _selectedBid == i,
                                onTap: () => setState(() => _selectedBid = i),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildSection(
                      'Input Fields',
                      [
                        const Text(
                          'Email Field',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        EmailField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Password Field',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        PasswordField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Text Field with Icon',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        CMTextField(
                          controller: _nameController,
                          hintText: 'Enter your name',
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Search Field',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SearchField(
                          controller: _searchController,
                          hintText: 'Search rooms...',
                          onClear: () => _searchController.clear(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dropdown',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        CMDropdown<String>(
                          hintText: 'Select a game',
                          value: _selectedDropdown,
                          items: const [
                            DropdownMenuItem(
                                value: 'oh_hell', child: Text('Oh Hell')),
                            DropdownMenuItem(value: 'uno', child: Text('UNO')),
                            DropdownMenuItem(
                                value: 'poker', child: Text('Poker')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedDropdown = value),
                          prefixIcon: Icons.casino,
                        ),
                      ],
                    ),
                    _buildSection(
                      'Cards',
                      [
                        const Text(
                          'Game Cards',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              GameCard(
                                title: 'Oh Hell',
                                subtitle: 'Live Game',
                                imageUrl: 'assets/images/back.png',
                                onPlay: () => _showSnackBar('Play Oh Hell'),
                              ),
                              const SizedBox(width: 12),
                              GameCard(
                                title: 'UNO',
                                subtitle: 'Coming Soon',
                                imageUrl: 'assets/images/back.png',
                                isAvailable: false,
                              ),
                              const SizedBox(width: 12),
                              GameCard(
                                title: 'Poker',
                                subtitle: 'Coming Soon',
                                imageUrl: 'assets/images/back.png',
                                isAvailable: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Room Card',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        RoomCard(
                          roomName: '1. "Casual Lounge"',
                          stake: '\$100',
                          playerCount: '(2/5)',
                          onJoin: () => _showSnackBar('Join room'),
                        ),
                        const SizedBox(height: 8),
                        RoomCard(
                          roomName: '2. "HighRollers Table"',
                          stake: '\$5000',
                          playerCount: '(4/4)',
                          isFull: true,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Info Cards',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                title: 'Stake',
                                value: '\$100',
                                icon: Icons.attach_money,
                                valueColor: palette.goldMedium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                title: 'Players',
                                value: '2/5',
                                icon: Icons.people,
                                valueColor: palette.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildSection(
                      'Leaderboard',
                      [
                        LeaderboardItem(
                          rank: 1,
                          playerName: 'Alice',
                          avatarUrl: '',
                          score: 55000,
                          isCurrentUser: true,
                        ),
                        LeaderboardItem(
                          rank: 2,
                          playerName: 'Bob',
                          avatarUrl: '',
                          score: 43000,
                        ),
                        LeaderboardItem(
                          rank: 3,
                          playerName: 'Charlie',
                          avatarUrl: '',
                          score: 38000,
                        ),
                      ],
                    ),
                    _buildSection(
                      'Player Positions',
                      [
                        const Text(
                          'Game Table Players',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PlayerPosition(
                              playerName: 'You',
                              bidInfo: 'Bid 1 | Won 1',
                              winInfo: 'Opp',
                              isActive: true,
                            ),
                            PlayerPosition(
                              playerName: 'Alice',
                              bidInfo: 'Bid 0 | Won 1',
                            ),
                            PlayerPosition(
                              playerName: 'Bob',
                              bidInfo: 'Bid 2 | Won 0',
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildSection(
                      'Tables & Stats',
                      [
                        const Text(
                          'Data Table',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        CMDataTable(
                          headers: const ['Player', 'Bid', 'Won', 'Pts'],
                          rows: const [
                            ['Alice', '2', '2', '+12'],
                            ['Bob', '0', '1', '-1'],
                            ['You', '1', '1', '+5'],
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Stats Cards',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                label: 'Games Won',
                                value: '42',
                                icon: Icons.emoji_events,
                                valueColor: palette.goldMedium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatsCard(
                                label: 'Win Rate',
                                value: '68%',
                                icon: Icons.trending_up,
                                valueColor: palette.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildSection(
                      'Badges & Empty States',
                      [
                        const Text(
                          'Badges',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            CMBadge(
                              text: 'New',
                              backgroundColor: palette.success,
                            ),
                            CMBadge(
                              text: 'Hot',
                              backgroundColor: palette.error,
                            ),
                            CMBadge(
                              text: 'Premium',
                              backgroundColor: palette.goldMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Empty State',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: palette.backgroundElevated,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: EmptyState(
                            icon: Icons.inbox,
                            title: 'No items',
                            message: 'Nothing to show here',
                            action: PrimaryButton(
                              text: 'Add Item',
                              onPressed: () => _showSnackBar('Add item'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading Indicator',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: palette.backgroundElevated,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const CMLoadingIndicator(
                            message: 'Loading...',
                          ),
                        ),
                      ],
                    ),
                    _buildSection(
                      'Dialogs',
                      [
                        const Text(
                          'Tap buttons to show dialogs',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Show Confirm Dialog',
                          onPressed: () => _showConfirmDialog(),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Show Bid Dialog',
                          onPressed: () => _showBidDialog(),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Show Round Complete',
                          onPressed: () => _showRoundCompleteDialog(),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                        SecondaryButton(
                          text: 'Show Loading Dialog',
                          onPressed: () => _showLoadingDialog(),
                          width: double.infinity,
                        ),
                      ],
                    ),
                    _buildSection(
                      'Navigation',
                      [
                        const Text(
                          'Bottom Navigation',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        CMBottomNav(
                          currentIndex: _bottomNavIndex,
                          onTap: (index) =>
                              setState(() => _bottomNavIndex = index),
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
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final palette = Palette();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: palette.goldMedium,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showConfirmDialog() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Confirm Action',
      message: 'This is a confirmation dialog. Do you want to proceed?',
      confirmText: 'Yes',
      cancelText: 'No',
    );

    _showSnackBar(confirmed ? 'Confirmed!' : 'Cancelled');
  }

  Future<void> _showBidDialog() async {
    await BidDialog.show(
      context: context,
      handSize: 5,
      currentTrump: 'Spades (♠)',
      maxBid: 5,
      onConfirm: (bid) => _showSnackBar('Bid placed: $bid'),
    );
  }

  Future<void> _showRoundCompleteDialog() async {
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
        {
          'player': 'Bob',
          'bid': 1,
          'won': 0,
          'roundPoints': -5,
          'totalScore': 38,
        },
      ],
      nextRoundInfo: 'Next Round starts in 4s...',
      onContinue: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _showLoadingDialog() async {
    LoadingDialog.show(context: context, message: 'Processing...');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      LoadingDialog.hide(context);
      _showSnackBar('Done!');
    }
  }
}
