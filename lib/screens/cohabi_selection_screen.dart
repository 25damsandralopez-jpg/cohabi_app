import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cohabi_selection_requirements_screen.dart';

class CohabiSelectionScreen extends StatefulWidget {
  final String? initialPropertyId;

  const CohabiSelectionScreen({
    super.key,
    this.initialPropertyId,
  });

  @override
  State<CohabiSelectionScreen> createState() =>
      _CohabiSelectionScreenState();
}

class _CohabiSelectionScreenState extends State<CohabiSelectionScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;

  final List<_SelectionProperty> _properties = [];
  final Set<String> _selectedPropertyIds = {};

  static const Color _navy = Color(0xFF071747);
  static const Color _turquoise = Color(0xFF10B9B4);
  static const Color _purple = Color(0xFF7439F5);
  static const Color _background = Color(0xFFFBFBFE);
  static const Color _border = Color(0xFFE9EBF2);
  static const Color _textSecondary = Color(0xFF66729A);

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay una sesión iniciada.');
      }

      final response = await _supabase
          .from('properties')
          .select('id, name, address, city, rooms')
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      final List<_SelectionProperty> loaded = [];

      for (final rawProperty in response) {
        final property = Map<String, dynamic>.from(rawProperty);

        final propertyId = property['id']?.toString();

        if (propertyId == null || propertyId.isEmpty) {
          continue;
        }

        String? imageUrl;

        try {
          final photoResponse = await _supabase
              .from('property_photos')
              .select('storage_path, position')
              .eq('property_id', propertyId)
              .order('position', ascending: true)
              .limit(1);

          if (photoResponse.isNotEmpty) {
            final storagePath =
            photoResponse.first['storage_path']?.toString();

            if (storagePath != null && storagePath.isNotEmpty) {
              try {
                imageUrl = await _supabase.storage
                    .from('property-photos')
                    .createSignedUrl(
                  storagePath,
                  3600,
                );
              } catch (_) {
                imageUrl = _supabase.storage
                    .from('property-photos')
                    .getPublicUrl(storagePath);
              }
            }
          }
        } catch (_) {}

        loaded.add(
          _SelectionProperty(
            id: propertyId,
            name: property['name']?.toString().trim().isNotEmpty == true
                ? property['name'].toString()
                : 'Mi piso',
            address: property['address']?.toString() ?? '',
            city: property['city']?.toString() ?? '',
            rooms: _toInt(property['rooms']),
            imageUrl: imageUrl,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _properties
          ..clear()
          ..addAll(loaded);

        _selectedPropertyIds.clear();

        final initialId = widget.initialPropertyId;

        if (initialId != null &&
            loaded.any((property) => property.id == initialId)) {
          _selectedPropertyIds.add(initialId);
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  void _toggleProperty(String propertyId) {
    setState(() {
      if (_selectedPropertyIds.contains(propertyId)) {
        _selectedPropertyIds.remove(propertyId);
      } else {
        _selectedPropertyIds.add(propertyId);
      }
    });
  }

  void _continue() {
    if (_selectedPropertyIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona al menos un piso para continuar.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CohabiSelectionRequirementsScreen(
          propertyIds: _selectedPropertyIds.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProperties,
                color: _turquoise,
                child: _buildBody(),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 260),
          Center(
            child: CircularProgressIndicator(
              color: _turquoise,
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 150),
          const Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hemos podido cargar tus pisos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _loadProperties,
              child: const Text('Volver a intentar'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        32,
      ),
      children: [
        _buildTopBar(),

        const SizedBox(height: 20),

        _buildProgress(),

        const SizedBox(height: 28),

        Image.asset(
          'assets/images/cohabi_selection.png',
          height: 125,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 18),

        const Text(
          'Cohabi Selección',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _navy,
            fontSize: 36,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 16),

        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text:
                'Nuestro proceso de selección inteligente ',
              ),
              TextSpan(
                text: 'trabaja por ti',
                style: TextStyle(
                  color: _turquoise,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        _buildIntroCard(),

        const SizedBox(height: 34),

        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F9F8),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'Paso 1 de 4',
              style: TextStyle(
                color: _turquoise,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Selecciona los pisos',
          style: TextStyle(
            color: _navy,
            fontSize: 29,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Elige los pisos en los que los requisitos que definas serán los mismos.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 22),

        if (_properties.isEmpty)
          _buildEmptyState()
        else
          _buildPropertiesPanel(),

        const SizedBox(height: 18),

        _buildInfoMessage(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const Spacer(),

        _circleButton(
          icon: Icons.help_outline_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Selecciona uno o varios pisos que compartirán los mismos requisitos.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: _border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: _navy,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 72,
      ),
      child: Row(
        children: [
          _progressSegment(true),
          const SizedBox(width: 10),
          _progressSegment(false),
          const SizedBox(width: 10),
          _progressSegment(false),
          const SizedBox(width: 10),
          _progressSegment(false),
        ],
      ),
    );
  }

  Widget _progressSegment(bool active) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: active
              ? _turquoise
              : const Color(0xFFE0E3ED),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.96,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE1E4ED),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _purple,
              size: 37,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 15,
                  height: 1.55,
                ),
                children: [
                  TextSpan(
                    text:
                    'Analizamos, filtramos y verificamos para que solo recibas candidatos que realmente ',
                  ),
                  TextSpan(
                    text: 'encajen con lo que buscas.',
                    style: TextStyle(
                      color: _purple,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.96,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          _properties.length,
              (index) {
            final property = _properties[index];

            return Column(
              children: [
                _propertyRow(property),
                if (index != _properties.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Divider(
                      height: 1,
                      color: _border,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _propertyRow(
      _SelectionProperty property,
      ) {
    final selected =
    _selectedPropertyIds.contains(property.id);

    return InkWell(
      onTap: () => _toggleProperty(property.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: 105,
                height: 82,
                child: property.imageUrl != null &&
                    property.imageUrl!.isNotEmpty
                    ? Image.network(
                  property.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _propertyPlaceholder(),
                )
                    : _propertyPlaceholder(),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: _textSecondary,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.city.isEmpty
                              ? 'Ciudad no indicada'
                              : property.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            AnimatedContainer(
              duration: const Duration(
                milliseconds: 170,
              ),
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFF4FFFE)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? _turquoise
                      : const Color(0xFFD5D9E5),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: _turquoise,
                size: 29,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyPlaceholder() {
    return Container(
      color: const Color(0xFFEAF9F8),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          color: _turquoise,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.85,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _turquoise,
            size: 24,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Podrás configurar requisitos específicos para cada piso más adelante si lo necesitas.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            color: _turquoise,
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'Todavía no tienes pisos disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final enabled =
        _selectedPropertyIds.isNotEmpty;

    return Container(
      color: _background,
      padding: const EdgeInsets.fromLTRB(
        22,
        10,
        22,
        16,
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: enabled ? _continue : null,
          borderRadius: BorderRadius.circular(19),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 170,
            ),
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: enabled
                  ? const LinearGradient(
                colors: [
                  _turquoise,
                  Color(0xFF168FD9),
                  _purple,
                ],
              )
                  : null,
              color: enabled
                  ? null
                  : const Color(0xFFE2E5EE),
            ),
            child: Row(
              children: [
                const Spacer(),

                Text(
                  enabled
                      ? 'Continuar'
                      : 'Selecciona un piso',
                  style: TextStyle(
                    color: enabled
                        ? Colors.white
                        : const Color(0xFF9CA4B9),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_rounded,
                  color: enabled
                      ? Colors.white
                      : const Color(0xFF9CA4B9),
                  size: 27,
                ),

                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionProperty {
  final String id;
  final String name;
  final String address;
  final String city;
  final int rooms;
  final String? imageUrl;

  const _SelectionProperty({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.rooms,
    required this.imageUrl,
  });
}