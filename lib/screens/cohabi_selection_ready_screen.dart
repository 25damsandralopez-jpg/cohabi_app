import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'owner_selection_waiting_screen.dart';

class CohabiSelectionReadyScreen extends StatefulWidget {
  final List<String> propertyIds;

  const CohabiSelectionReadyScreen({
    super.key,
    required this.propertyIds,
  });

  @override
  State<CohabiSelectionReadyScreen> createState() =>
      _CohabiSelectionReadyScreenState();
}

class _CohabiSelectionReadyScreenState
    extends State<CohabiSelectionReadyScreen> {
  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF10B9B4);
  static const Color purple = Color(0xFF7439F5);
  static const Color background = Color(0xFFFBFBFE);
  static const Color border = Color(0xFFE8EAF2);
  static const Color textSecondary = Color(0xFF66729A);

  String? _contactEmail;
  bool _loadingEmail = true;
  String? _emailError;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadSelectionEmail();
  }

  Future<void> _loadSelectionEmail() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _loadingEmail = false;
          _emailError = 'No hay una sesión iniciada.';
        });

        return;
      }

      final data = await supabase
          .from('owner_profiles')
          .select('selection_email')
          .eq('user_id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _contactEmail = data['selection_email'] as String?;
        _loadingEmail = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingEmail = false;
        _emailError = 'No se pudo cargar el correo.';
      });

      debugPrint('Error cargando selection_email: $e');
    }
  }

  Future<void> _copyEmail() async {
    final email = _contactEmail;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Todavía no se ha podido cargar tu correo de Cohabi.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: email,
      ),
    );

    if (!mounted) return;

    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Correo copiado al portapapeles.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _continue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OwnerSelectionWaitingScreen(
          propertyIds: widget.propertyIds,
        ),
      ),
          (route) => false,
    );
  }

  void _later() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OwnerSelectionWaitingScreen(
          propertyIds: widget.propertyIds,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHelp(),

                    const SizedBox(height: 12),

                    Image.asset(
                      'assets/images/cohabi_selection_success.png',
                      height: 170,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      '¡Cohabi Selección está lista!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navy,
                        fontSize: 30,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Solo queda un último paso para empezar a recibir candidatos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSparkDivider(),

                    const SizedBox(height: 28),

                    _buildExplanation(),

                    const SizedBox(height: 30),

                    _buildProcess(),

                    const SizedBox(height: 28),

                    _buildActivationCard(),
                  ],
                ),
              ),
            ),

            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelp() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Usa este correo como contacto en tus anuncios para activar el proceso automático.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: border,
            ),
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: navy,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildSparkDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE7E9F2),
            thickness: 1,
          ),
        ),
        const SizedBox(width: 18),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: purple,
            size: 17,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Divider(
            color: Color(0xFFE7E9F2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: textSecondary,
          fontSize: 14.5,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: 'A partir de ahora, ',
          ),
          TextSpan(
            text: 'Cohabi',
            style: TextStyle(
              color: purple,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text:
            ' se encargará de verificar, analizar y seleccionar automáticamente a los candidatos que contacten contigo desde cualquier portal inmobiliario.',
          ),
        ],
      ),
    );
  }

  Widget _buildProcess() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _processStep(
            number: 1,
            icon: Icons.web_asset_outlined,
            iconColor: const Color(0xFFFF9B3E),
            title: 'Publicas tu anuncio',
            subtitle: 'en Idealista, Fotocasa o cualquier portal.',
          ),
        ),

        _arrow(),

        Expanded(
          child: _processStep(
            number: 2,
            icon: Icons.alternate_email_rounded,
            iconColor: purple,
            title: 'El interesado contacta',
            subtitle: 'contigo a través del portal.',
          ),
        ),

        _arrow(),

        Expanded(
          child: _processStep(
            number: 3,
            icon: Icons.smart_toy_outlined,
            iconColor: purple,
            title: 'Cohabi verifica',
            subtitle: 'y analiza al candidato automáticamente.',
          ),
        ),

        _arrow(),

        Expanded(
          child: _processStep(
            number: 4,
            icon: Icons.home_work_outlined,
            iconColor: turquoise,
            title: 'Tú recibes solo',
            subtitle: 'candidatos compatibles, verificados y fiables.',
          ),
        ),
      ],
    );
  }

  Widget _arrow() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 34,
        left: 2,
        right: 2,
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Color(0xFFD7D9E5),
        size: 15,
      ),
    );
  }

  Widget _processStep({
    required int number,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final numberColor = number.isEven ? purple : turquoise;

    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 29,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 21,
          height: 21,
          decoration: BoxDecoration(
            color: numberColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: navy,
            fontSize: 10.5,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 8.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4EEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: purple,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activa el proceso automático',
                      style: TextStyle(
                        color: navy,
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Copia esta dirección de correo y utilízala como correo de contacto en tus anuncios publicados.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Cada persona interesada recibirá automáticamente un enlace para completar su perfil y realizar el proceso de selección de Cohabi.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: purple,
                  size: 27,
                ),

                SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solo recibirás candidatos verificados que cumplan tus requisitos y te aparecerán ordenados por mayor compatibilidad.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 7),

                      Text(
                        'Verificamos y descartamos automáticamente a quienes no cumplen.',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: purple.withValues(alpha: 0.45),
                width: 1.3,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _loadingEmail
                        ? 'Cargando correo...'
                        : _emailError != null
                        ? 'No disponible'
                        : (_contactEmail ?? 'No disponible'),
                    style: const TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: 38,
                  color: border,
                ),

                const SizedBox(width: 14),

                InkWell(
                  onTap: _copyEmail,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _copied
                              ? Icons.check_rounded
                              : Icons.content_copy_rounded,
                          color: purple,
                          size: 21,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          _copied ? 'Copiado' : 'Copiar',
                          style: const TextStyle(
                            color: purple,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        14,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _copied ? _continue : _copyEmail,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      turquoise,
                      Color(0xFF168FD9),
                      purple,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Spacer(),

                    Text(
                      _copied
                          ? 'He copiado el correo'
                          : 'Copiar correo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 25,
                    ),

                    const SizedBox(width: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _later,
              child: const Text(
                'Lo haré más tarde',
                style: TextStyle(
                  color: purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}