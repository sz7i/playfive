import 'package:flutter/material.dart';
import '../../style/palette.dart';

/// Primary button with golden gradient - used for main actions
/// Examples: "LOG IN", "CONFIRM BID", "CREATE ROOM"
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      width: width,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          gradient: palette.goldGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: palette.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.textOnGold,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: palette.textOnGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text.toUpperCase(),
                          style: TextStyle(
                            color: palette.textOnGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button with subtle styling - used for less prominent actions
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    final isDisabled = onPressed == null;

    return SizedBox(
      width: width,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? palette.disabled : palette.backgroundElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDisabled ? palette.borderLight : palette.borderMedium,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isDisabled ? palette.disabledText : palette.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      color: isDisabled ? palette.disabledText : palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Success button (green) - used for "JOIN" actions
class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: palette.success,
          borderRadius: BorderRadius.circular(20),
          boxShadow: palette.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Disabled state button - used for "FULL" or unavailable actions
class DisabledButton extends StatelessWidget {
  final String text;
  final double? width;
  final double height;

  const DisabledButton({
    super.key,
    required this.text,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: palette.disabled,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: palette.disabledText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Social login button - white rounded button with icon
class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      width: 140,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: palette.trueWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: palette.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: icon,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: palette.textOnGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button - circular button with icon only
class CMIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const CMIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? palette.backgroundElevated,
          shape: BoxShape.circle,
          boxShadow: palette.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              color: iconColor ?? palette.textPrimary,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Buy coins button - green with icon
class BuyCoinsButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BuyCoinsButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return SizedBox(
      height: 32,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.greenBuyCoins,
          borderRadius: BorderRadius.circular(16),
          boxShadow: palette.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: palette.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Buy Coins',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip button for number selection in bid dialog
class NumberChip extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback? onTap;

  const NumberChip({
    super.key,
    required this.number,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? palette.success : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? palette.success : palette.goldMedium,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}