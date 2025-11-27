import 'package:flutter/material.dart';
import '../../style/palette.dart';

/// Data table for displaying game results and scores
class CMDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<dynamic>> rows;
  final List<Color?>? rowColors;
  final List<TextAlign>? columnAlignments;

  const CMDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.rowColors,
    this.columnAlignments,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundMain,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        border: TableBorder.all(
          color: palette.borderLight,
          width: 1,
        ),
        columnWidths: _buildColumnWidths(),
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: palette.backgroundElevated,
            ),
            children: headers
                .asMap()
                .entries
                .map((entry) => _buildTableCell(
                      entry.value,
                      isHeader: true,
                      alignment: columnAlignments?[entry.key] ?? TextAlign.center,
                    ))
                .toList(),
          ),

          // Data rows
          ...rows.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final row = rowEntry.value;

            return TableRow(
              children: row
                  .asMap()
                  .entries
                  .map((cellEntry) => _buildTableCell(
                        cellEntry.value.toString(),
                        color: rowColors?[rowIndex],
                        alignment: columnAlignments?[cellEntry.key] ??
                            TextAlign.center,
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    return Map.fromEntries(
      List.generate(
        headers.length,
        (index) => MapEntry(index, const FlexColumnWidth(1)),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    Color? color,
    TextAlign alignment = TextAlign.center,
  }) {
    final palette = Palette();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ??
              (isHeader ? palette.textSecondary : palette.textPrimary),
          fontSize: isHeader ? 12 : 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: alignment,
      ),
    );
  }
}

/// Leaderboard section with title and list
class LeaderboardSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const LeaderboardSection({
    super.key,
    required this.title,
    required this.items,
    this.showViewAll = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              if (showViewAll && onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: palette.goldMedium,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Items
          ...items,
        ],
      ),
    );
  }
}

/// Stats card for displaying player statistics
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(
            icon,
            color: palette.goldMedium,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Badge widget for displaying status or counts
class CMBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const CMBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.goldMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor ?? palette.textOnGold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: palette.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  color: palette.textTertiary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator
class CMLoadingIndicator extends StatelessWidget {
  final String? message;

  const CMLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(palette.goldMedium),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
