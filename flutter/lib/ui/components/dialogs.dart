import 'package:flutter/material.dart';
import '../../style/palette.dart';
import 'buttons.dart';

/// Base dialog with golden border and dark background
class CMDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final bool dismissible;

  const CMDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.width,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width ?? 320,
        decoration: BoxDecoration(
          color: palette.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: palette.borderGold,
            width: 3,
          ),
          boxShadow: palette.glowShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            if (title != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: palette.borderGold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    title!.toUpperCase(),
                    style: TextStyle(
                      color: palette.goldMedium,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: content,
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: actions!
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: action,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    double? width,
    bool dismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Palette().dialogOverlay,
      builder: (context) => CMDialog(
        title: title,
        content: content,
        actions: actions,
        width: width,
        dismissible: dismissible,
      ),
    );
  }
}

/// Bid selection dialog for placing bids in the game
class BidDialog extends StatefulWidget {
  final int handSize;
  final String currentTrump;
  final int maxBid;
  final Function(int bid) onConfirm;

  const BidDialog({
    super.key,
    required this.handSize,
    required this.currentTrump,
    this.maxBid = 5,
    required this.onConfirm,
  });

  @override
  State<BidDialog> createState() => _BidDialogState();

  static Future<void> show({
    required BuildContext context,
    required int handSize,
    required String currentTrump,
    int maxBid = 5,
    required Function(int bid) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Palette().dialogOverlay,
      builder: (context) => BidDialog(
        handSize: handSize,
        currentTrump: currentTrump,
        maxBid: maxBid,
        onConfirm: onConfirm,
      ),
    );
  }
}

class _BidDialogState extends State<BidDialog> {
  int? selectedBid;

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return CMDialog(
      title: 'Place Your Bid',
      width: 340,
      dismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hand size info
          Text(
            'Hand Size: ${widget.handSize} Cards',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),

          // Current trump
          Text(
            'Current Trump: ${widget.currentTrump}',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          // Number chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(
              widget.maxBid + 1,
              (index) => NumberChip(
                number: index,
                isSelected: selectedBid == index,
                onTap: () {
                  setState(() {
                    selectedBid = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        PrimaryButton(
          text: 'Confirm Bid',
          onPressed: selectedBid != null
              ? () {
                  widget.onConfirm(selectedBid!);
                  Navigator.of(context).pop();
                }
              : null,
          width: double.infinity,
        ),
      ],
    );
  }
}

/// Round complete dialog showing results
class RoundCompleteDialog extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String? nextRoundInfo;
  final VoidCallback? onContinue;

  const RoundCompleteDialog({
    super.key,
    required this.results,
    this.nextRoundInfo,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return CMDialog(
      title: 'Round Complete',
      width: 360,
      dismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cards display (placeholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.style,
                size: 48,
                color: palette.goldMedium,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Results table
          Container(
            decoration: BoxDecoration(
              color: palette.backgroundMain,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Table(
              border: TableBorder.all(
                color: palette.borderLight,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1.5),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: palette.backgroundElevated,
                  ),
                  children: [
                    _buildTableCell('Player', isHeader: true),
                    _buildTableCell('Bid', isHeader: true),
                    _buildTableCell('Won', isHeader: true),
                    _buildTableCell('Rnd Pts', isHeader: true),
                    _buildTableCell('Total Score', isHeader: true),
                  ],
                ),

                // Data rows
                ...results.map((result) {
                  return TableRow(
                    children: [
                      _buildTableCell((result['player'] ?? '') as String),
                      _buildTableCell(result['bid']?.toString() ?? '0'),
                      _buildTableCell(result['won']?.toString() ?? '0'),
                      _buildTableCell(
                        result['roundPoints']?.toString() ?? '0',
                        color: ((result['roundPoints'] as num?) ?? 0) >= 0
                            ? Palette().success
                            : Palette().error,
                      ),
                      _buildTableCell(result['totalScore']?.toString() ?? '0'),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Next round info
          if (nextRoundInfo != null) ...[
            const SizedBox(height: 16),
            Text(
              nextRoundInfo!,
              style: TextStyle(
                color: palette.textTertiary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: onContinue != null
          ? [
              PrimaryButton(
                text: 'Continue',
                onPressed: onContinue,
                width: double.infinity,
              ),
            ]
          : null,
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    Color? color,
  }) {
    final palette = Palette();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color ??
              (isHeader ? palette.textSecondary : palette.textPrimary),
          fontSize: isHeader ? 12 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> results,
    String? nextRoundInfo,
    VoidCallback? onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Palette().dialogOverlay,
      builder: (context) => RoundCompleteDialog(
        results: results,
        nextRoundInfo: nextRoundInfo,
        onContinue: onContinue,
      ),
    );
  }
}

/// Confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return CMDialog(
      title: title,
      content: Text(
        message,
        style: TextStyle(
          color: palette.textSecondary,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        SecondaryButton(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
          width: double.infinity,
        ),
        PrimaryButton(
          text: confirmText,
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          width: double.infinity,
        ),
      ],
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Palette().dialogOverlay,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
    return result ?? false;
  }
}

/// Loading dialog
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: palette.borderGold,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(palette.goldMedium),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Palette().dialogOverlay,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
