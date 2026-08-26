import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/navigation/tenant_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tenant_bottom_navigation.dart';
import '../models/tenant_match.dart';
import '../services/tenant_matches_service.dart';
import 'tenant_interest_sent_screen.dart';

class TenantPropertyDetailScreen extends StatefulWidget {
  final TenantMatch match;

  const TenantPropertyDetailScreen({
    super.key,
    required this.match,
  });

  @override
  State<TenantPropertyDetailScreen> createState() =>
      _TenantPropertyDetailScreenState();
}

class _TenantPropertyDetailScreenState extends State<TenantPropertyDetailScreen> {
  final _supabase = Supabase.instance.client;
  final _matchesService = TenantMatchesService();

  bool _loading = true;
  bool _sending = false;
  bool _favoriteBusy = false;
  late bool _isFavorite;
  String? _error;
  Map<String, dynamic> _property = {};
  Map<String, dynamic> _room = {};
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.match.isFavorite;
    _load();
  }

  Future<void> _load() async {
    try {
      final property = await _supabase
          .from('properties')
          .select(
            'id, name, address, city, postal_code, property_type, rooms, bathrooms, surface, condition, tenant_type, features, services, other_services',
          )
          .eq('id', widget.match.propertyId)
          .single();

      final room = await _supabase
          .from('rooms')
          .select(
            'id, room_number, status, available_from, monthly_price, deposit, reservation_price, min_stay, max_stay, max_people, area_m2, bed_size, private_bathroom, room_lock, private_kitchen, exterior_view, equipment',
          )
          .eq('id', widget.match.roomId)
          .single();

      final urls = <String>[];
      try {
        final photoRows = await _supabase
            .from('property_photos')
            .select('storage_path, position')
            .eq('property_id', widget.match.propertyId)
            .order('position', ascending: true);
        for (final raw in photoRows as List<dynamic>) {
          final path = raw['storage_path']?.toString();
          if (path == null || path.isEmpty) continue;
          try {
            urls.add(
              await _supabase.storage
                  .from('property-photos')
                  .createSignedUrl(path, 3600),
            );
          } catch (_) {}
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _property = Map<String, dynamic>.from(property);
        _room = Map<String, dynamic>.from(room);
        _photos = urls;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteBusy) return;
    setState(() => _favoriteBusy = true);
    try {
      final value = await _matchesService.toggleFavorite(widget.match);
      if (!mounted) return;
      setState(() => _isFavorite = value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar favoritos: $e')),
      );
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  Future<void> _sendInterest() async {
    if (_sending || widget.match.hasApplied) return;
    setState(() => _sending = true);
    try {
      await _matchesService.apply(widget.match);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TenantInterestSentScreen(match: widget.match),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el interés: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: TenantBottomNavigation(
        currentIndex: 1,
        onTap: (index) => handleTenantNavigation(context, index),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: CohabiColors.turquoise),
              )
            : _error != null
                ? _errorView()
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _header()),
                      SliverToBoxAdapter(child: _hero()),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                        sliver: SliverList.list(
                          children: [
                            _summary(),
                            const SizedBox(height: 14),
                            _propertySection(),
                            const SizedBox(height: 14),
                            _roomSection(),
                            const SizedBox(height: 14),
                            _locationSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _loading || _error != null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Descartar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CohabiColors.purple,
                          side: const BorderSide(color: CohabiColors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: CohabiColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextButton.icon(
                        onPressed: widget.match.hasApplied || _sending
                            ? null
                            : _sendInterest,
                        icon: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.favorite_border_rounded, color: Colors.white),
                        label: Text(
                          widget.match.hasApplied ? 'Interés enviado' : 'Me interesa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Expanded(
              child: Text(
                'Cohabi Selección ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _favoriteBusy ? null : _toggleFavorite,
              icon: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite ? CohabiColors.coral : null,
              ),
            ),
          ],
        ),
      );

  Widget _hero() {
    if (_photos.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [CohabiColors.turquoiseSoft, CohabiColors.purpleSoft],
          ),
        ),
        child: const Icon(Icons.apartment_rounded, size: 100, color: CohabiColors.purple),
      );
    }

    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: _photos.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.network(
              _photos[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: CohabiColors.purpleSoft,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _property['name']?.toString() ?? widget.match.propertyName,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 19, color: CohabiColors.purple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_property['address'] ?? widget.match.address ?? ''}${(_property['address'] ?? widget.match.address) == null ? '' : ' · '}${_property['city'] ?? widget.match.city}',
                    style: const TextStyle(color: CohabiColors.textSecondary),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Wrap(
              spacing: 22,
              runSpacing: 14,
              children: [
                _stat(Icons.bed_outlined, 'Habitación ${_room['room_number'] ?? widget.match.roomNumber}'),
                _stat(Icons.euro_rounded, '${_money(_room['monthly_price'])} €/mes'),
                _stat(Icons.calendar_month_outlined, _dateText(_room['available_from'])),
              ],
            ),
          ],
        ),
      );

  Widget _propertySection() {
    final features = _stringList(_property['features']);
    final services = _stringList(_property['services']);
    return _card(
      title: 'Sobre el piso',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (_property['surface'] != null) _chip('${_property['surface']} m²'),
              if (_property['rooms'] != null) _chip('${_property['rooms']} habitaciones'),
              if (_property['bathrooms'] != null) _chip('${_property['bathrooms']} baños'),
              ...features.map(_chip),
              ...services.map(_chip),
            ],
          ),
          if ((_property['other_services']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _property['other_services'].toString(),
              style: const TextStyle(color: CohabiColors.textSecondary, height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  Widget _roomSection() => _card(
        title: 'La habitación',
        child: Column(
          children: [
            _line('Precio mensual', '${_money(_room['monthly_price'])} €/mes'),
            _line('Fianza', '${_money(_room['deposit'])} €'),
            _line('Reserva', '${_money(_room['reservation_price'])} €'),
            _line('Estancia mínima', _room['min_stay']?.toString() ?? '—'),
            _line('Estancia máxima', _room['max_stay']?.toString() ?? '—'),
            _line('Tamaño', _room['area_m2'] == null ? '—' : '${_room['area_m2']} m²'),
            _line('Cama', _room['bed_size']?.toString() ?? '—'),
            _line('Baño privado', _yesNo(_room['private_bathroom'])),
            _line('Cerradura', _yesNo(_room['room_lock'])),
            _line('Vista exterior', _yesNo(_room['exterior_view'])),
            if ((_room['equipment']?.toString() ?? '').isNotEmpty)
              _line('Equipamiento', _room['equipment'].toString()),
          ],
        ),
      );

  Widget _locationSection() => _card(
        title: 'Ubicación',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: CohabiColors.turquoiseSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.map_outlined, size: 42, color: CohabiColors.turquoise),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${_property['address'] ?? ''}\n${_property['postal_code'] ?? ''} ${_property['city'] ?? ''}',
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _card({String? title, required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: CohabiColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      );

  Widget _stat(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: CohabiColors.purple),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: CohabiColors.purpleSoft.withOpacity(.55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w600)),
      );

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.textSecondary))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54, color: CohabiColors.coral),
              const SizedBox(height: 12),
              const Text('No se pudo cargar el piso.'),
              const SizedBox(height: 8),
              Text(_error ?? '', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );

  List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  String _money(dynamic value) {
    if (value is num) return value.toStringAsFixed(0);
    final parsed = double.tryParse(value?.toString() ?? '');
    return parsed?.toStringAsFixed(0) ?? '0';
  }

  String _dateText(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Disponible';
    return 'Desde ${date.day}/${date.month}/${date.year}';
  }

  String _yesNo(dynamic value) => value == true ? 'Sí' : 'No';
}
