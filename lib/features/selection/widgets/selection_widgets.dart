import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SelectionProgress extends StatelessWidget {
  final int step;
  final int total;
  const SelectionProgress({super.key, required this.step, this.total = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(total, (index) {
            final done = index < step - 1;
            final active = index == step - 1;
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? CohabiColors.turquoise : (active ? CohabiColors.purple : Colors.white),
                      border: Border.all(
                        color: done || active ? (done ? CohabiColors.turquoise : CohabiColors.purple) : CohabiColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  if (index < total - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < step - 1 ? CohabiColors.turquoise : CohabiColors.border,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          '$step de $total',
          style: const TextStyle(color: CohabiColors.purple, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class SelectionSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;

  const SelectionSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CohabiColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: CohabiColors.purpleSoft, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: CohabiColors.purple),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: CohabiColors.navy, fontSize: 18, fontWeight: FontWeight.w800)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 13, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? CohabiColors.turquoiseSoft : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? CohabiColors.turquoise : CohabiColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? CohabiColors.turquoise : CohabiColors.purple),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w600))),
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? CohabiColors.turquoise : CohabiColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class SelectionPrimaryButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onPressed;
  const SelectionPrimaryButton({super.key, required this.text, this.loading = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(gradient: CohabiColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 14),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
