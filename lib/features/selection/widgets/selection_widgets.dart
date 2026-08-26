import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SelectionProgress extends StatelessWidget {
  final int step;
  final int total;

  const SelectionProgress({
    super.key,
    required this.step,
    this.total = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(total, (index) {
              final number = index + 1;
              final done = number < step;
              final active = number == step;

              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: active
                            ? const LinearGradient(
                          colors: [
                            CohabiColors.turquoise,
                            CohabiColors.purple,
                          ],
                        )
                            : null,
                        color: done
                            ? CohabiColors.turquoise
                            : active
                            ? null
                            : Colors.white,
                        border: Border.all(
                          color: done
                              ? CohabiColors.turquoise
                              : active
                              ? CohabiColors.purple
                              : const Color(0xFFBCC3D6),
                          width: 1.7,
                        ),
                      ),
                      child: done
                          ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    if (index < total - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: number < step
                                ? CohabiColors.turquoise
                                : const Color(0xFFDDE1EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$step de $total',
          style: const TextStyle(
            color: CohabiColors.purple,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
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
  final Color? iconColor;
  final Color? iconBackground;

  const SelectionSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
    this.iconColor,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? CohabiColors.purple;
    final resolvedIconBackground =
        iconBackground ?? CohabiColors.purple.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EBF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: resolvedIconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: resolvedIconColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: CohabiColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CohabiColors.turquoise
                  : const Color(0xFFE2E5EE),
              width: selected ? 1.7 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: CohabiColors.turquoise.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment:
            icon == null ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? CohabiColors.turquoise.withValues(alpha: 0.10)
                        : CohabiColors.purple.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? CohabiColors.turquoise
                        : CohabiColors.purple,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: icon == null ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 13.5,
                    fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionPrimaryButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onPressed;

  const SelectionPrimaryButton({
    super.key,
    required this.text,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 59,
      decoration: BoxDecoration(
        gradient: CohabiColors.primaryGradient,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: CohabiColors.purple.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: loading
                ? const Center(
              child: SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            )
                : Row(
              children: [
                const SizedBox(width: 31),
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
