import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class CohabiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  const CohabiTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: CohabiColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: CohabiColors.textMuted, size: 21),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CohabiRadius.md),
          borderSide: const BorderSide(color: CohabiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CohabiRadius.md),
          borderSide: const BorderSide(color: CohabiColors.turquoise, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CohabiRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CohabiRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
