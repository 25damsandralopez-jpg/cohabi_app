import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class CohabiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final bool withShadow;
  final BorderSide? borderSide;

  const CohabiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = Colors.white,
    this.withShadow = true,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CohabiRadius.xl),
        border: Border.fromBorderSide(
          borderSide ?? const BorderSide(color: CohabiColors.border),
        ),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CohabiRadius.xl),
        child: content,
      ),
    );
  }
}
