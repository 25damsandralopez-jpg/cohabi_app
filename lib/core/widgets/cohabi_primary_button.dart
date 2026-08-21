import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class CohabiPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double height;

  const CohabiPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.65 : 1,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: CohabiColors.primaryGradient,
          borderRadius: BorderRadius.circular(CohabiRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(CohabiRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  if (!isLoading && trailingIcon != null)
                    Icon(trailingIcon, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
