import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../applications/screens/tenant_applications_screen.dart';
import '../models/tenant_match.dart';

class TenantInterestSentScreen extends StatelessWidget {
  final TenantMatch match;

  const TenantInterestSentScreen({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [CohabiColors.turquoiseSoft, CohabiColors.purpleSoft],
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      size: 88,
                      color: CohabiColors.purple,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '💜 ¡Interés enviado!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Hemos enviado tu perfil al propietario de ${match.propertyName}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 18,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: CohabiColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CohabiColors.turquoiseSoft,
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: CohabiColors.turquoise,
                            size: 31,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            'El propietario podrá revisar tu perfil y, si quiere conocerte, proponerte una visita para la habitación ${match.roomNumber}.',
                            style: const TextStyle(
                              color: CohabiColors.navy,
                              fontSize: 16,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: CohabiColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TenantApplicationsScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        child: const Text(
                          'Ver mis solicitudes  →',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CohabiColors.purple,
                        side: const BorderSide(color: CohabiColors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Seguir viendo pisos',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CohabiColors.purpleSoft.withOpacity(.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.notifications_none_rounded, color: CohabiColors.purple),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Te avisaremos cuando el propietario revise tu perfil o te proponga una visita.',
                            style: TextStyle(
                              color: CohabiColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
