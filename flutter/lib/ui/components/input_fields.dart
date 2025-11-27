import 'package:flutter/material.dart';
import '../../style/palette.dart';

/// Text input field with icon and custom styling
class CMTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CMTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundElevated.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: palette.textTertiary,
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: palette.textTertiary,
                  size: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Password input field with show/hide toggle
class PasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordField({
    super.key,
    this.hintText = 'Password',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundElevated.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: palette.textTertiary,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: palette.textTertiary,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: palette.textTertiary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Email input field with email icon
class EmailField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailField({
    super.key,
    this.hintText = 'Email Address',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CMTextField(
      hintText: hintText,
      prefixIcon: Icons.email_outlined,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
    );
  }
}

/// Search input field with search icon
class SearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundElevated.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: palette.textTertiary,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: palette.textTertiary,
            size: 20,
          ),
          suffixIcon: controller?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: palette.textTertiary,
                    size: 20,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Dropdown field with custom styling
class CMDropdown<T> extends StatelessWidget {
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final IconData? prefixIcon;

  const CMDropdown({
    super.key,
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Palette();

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundElevated.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.borderLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(
              prefixIcon,
              color: palette.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hintText,
                  style: TextStyle(
                    color: palette.textTertiary,
                    fontSize: 16,
                  ),
                ),
                items: items,
                onChanged: onChanged,
                dropdownColor: palette.backgroundElevated,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: palette.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
