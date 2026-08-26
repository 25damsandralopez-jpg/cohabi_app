import 'package:flutter/material.dart';

import '../../../../core/navigation/tenant_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tenant_bottom_navigation.dart';
import '../models/tenant_match.dart';
import '../services/tenant_matches_service.dart';
import '../../screens/tenant_selection_screen.dart';
import 'tenant_interest_sent_screen.dart';
import 'tenant_property_detail_screen.dart';

class TenantBestMatchesScreen extends StatefulWidget {
  const TenantBestMatchesScreen({super.key});

  @override
  State<TenantBestMatchesScreen> createState() => _TenantBestMatchesScreenState();
}

class _TenantBestMatchesScreenState extends State<TenantBestMatchesScreen> {
  final _service = TenantMatchesService();

  bool _loading = true;
  String? _error;
  String _sort = 'compatibility';
  List<TenantMatch> _matches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final matches = await _service.loadMatches();
      if (!mounted) return;
      setState(() {
        _matches = matches;
        _sortMatches();
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

  void _sortMatches() {
    switch (_sort) {
      case 'price':
        _matches.sort((a, b) => a.monthlyPrice.compareTo(b.monthlyPrice));
        break;
      case 'date':
        _matches.sort((a, b) {
          final ad = a.availableFrom ?? DateTime(2100);
          final bd = b.availableFrom ?? DateTime(2100);
          return ad.compareTo(bd);
        });
        break;
      case 'zone':
        _matches.sort((a, b) => a.city.compareTo(b.city));
        break;
      default:
        _matches.sort((a, b) => b.score.compareTo(a.score));
    }
  }

  void _setSort(String value) {
    setState(() {
      _sort = value;
      _sortMatches();
    });
  }

  Future<void> _toggleFavorite(int index) async {
    try {
      final current = _matches[index];
      final newValue = await _service.toggleFavorite(current);
      if (!mounted) return;
      setState(() {
        _matches[index] = current.copyWith(isFavorite: newValue);
      });
    } catch (e) {
      _showError('No se pudo actualizar favoritos: $e');
    }
  }

  Future<void> _apply(int index) async {
    final current = _matches[index];
    if (current.hasApplied) return;

    try {
      await _service.apply(current);
      if (!mounted) return;
      setState(() {
        _matches[index] = current.copyWith(hasApplied: true);
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TenantInterestSentScreen(match: current),
        ),
      );
    } catch (e) {
      _showError('No se pudo enviar la solicitud: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showDetails(TenantMatch match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TenantPropertyDetailScreen(match: match),
      ),
    );
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
        child: RefreshIndicator(
          onRefresh: _load,
          color: CohabiColors.turquoise,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header()),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: CohabiColors.turquoise)),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _errorState(),
                )
              else if (_matches.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyMatches(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  sliver: SliverList.separated(
                    itemCount: _matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return _MatchCard(
                        match: match,
                        best: index == 0 && _sort == 'compatibility',
                        onFavorite: () => _toggleFavorite(index),
                        onView: () => _showDetails(match),
                        onApply: () => _apply(index),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => handleTenantNavigation(context, 1),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CohabiColors.navy),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Cohabi Selección ✨',
                    style: TextStyle(
                      color: CohabiColors.purple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openPreferences,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Ajustar preferencias'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CohabiColors.purple,
                  side: const BorderSide(color: CohabiColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Pisos compatibles contigo ✨',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _matches.isEmpty
                ? 'Buscamos habitaciones publicadas que cumplan tus preferencias de búsqueda y los requisitos del piso.'
                : 'Hemos encontrado ${_matches.length} opciones compatibles. Están ordenadas usando los criterios que podemos comprobar con tus preferencias y los requisitos de cada piso.',
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  label: 'Compatibilidad',
                  icon: Icons.track_changes_rounded,
                  selected: _sort == 'compatibility',
                  onTap: () => _setSort('compatibility'),
                ),
                const SizedBox(width: 10),
                _SortChip(
                  label: 'Precio',
                  icon: Icons.euro_rounded,
                  selected: _sort == 'price',
                  onTap: () => _setSort('price'),
                ),
                const SizedBox(width: 10),
                _SortChip(
                  label: 'Zona',
                  icon: Icons.location_on_outlined,
                  selected: _sort == 'zone',
                  onTap: () => _setSort('zone'),
                ),
                const SizedBox(width: 10),
                _SortChip(
                  label: 'Fecha disponible',
                  icon: Icons.calendar_month_outlined,
                  selected: _sort == 'date',
                  onTap: () => _setSort('date'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPreferences() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TenantSelectionScreen(editMode: true),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            const Text('No pudimos cargar tus opciones.', style: TextStyle(color: CohabiColors.navy, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: CohabiColors.textSecondary)),
            const SizedBox(height: 18),
            FilledButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  static Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: CohabiColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.home_work_outlined, color: Colors.white, size: 54),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final TenantMatch match;
  final bool best;
  final VoidCallback onFavorite;
  final VoidCallback onView;
  final VoidCallback onApply;

  const _MatchCard({
    required this.match,
    required this.best,
    required this.onFavorite,
    required this.onView,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CohabiColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 310, child: _image()),
                Expanded(child: _content()),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 240, child: _image()),
              _content(),
            ],
          );
        },
      ),
    );
  }

  Widget _image() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          child: match.imageUrl == null
              ? Container(
                  decoration: const BoxDecoration(gradient: CohabiColors.primaryGradient),
                  child: const Icon(Icons.home_work_outlined, color: Colors.white, size: 58),
                )
              : Image.network(
                  match.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(gradient: CohabiColors.primaryGradient),
                    child: const Icon(Icons.home_work_outlined, color: Colors.white, size: 58),
                  ),
                ),
        ),
        Positioned(
          left: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CohabiColors.turquoise,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 25),
                const SizedBox(height: 4),
                Text(
                  '${match.score}% compatible',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  match.score >= 85
                      ? 'Muy compatible'
                      : match.score >= 65
                          ? 'Compatible'
                          : match.score >= 45
                              ? 'Compatibilidad media'
                              : 'Compatibilidad baja',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (best)
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CohabiColors.navy.withOpacity(.82),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text('⭐ Tu mejor opción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.propertyName,
                  style: const TextStyle(color: CohabiColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  match.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: CohabiColors.purple,
                ),
              ),
            ],
          ),
          Text(
            '📍 ${match.city}',
            style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              Text('🛏 Habitación ${match.roomNumber}', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w600)),
              Text('• ${match.monthlyPrice.toStringAsFixed(0)} €/mes', style: const TextStyle(color: CohabiColors.turquoise, fontWeight: FontWeight.w800)),
              if (match.availableFrom != null)
                Text('📅 ${_formatDate(match.availableFrom!)}', style: const TextStyle(color: CohabiColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CohabiColors.purpleSoft.withOpacity(.62),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💜 Por qué encaja contigo', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: match.reasons
                      .map(
                        (reason) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: CohabiColors.border),
                          ),
                          child: Text(reason, style: const TextStyle(color: CohabiColors.navy, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CohabiColors.turquoise,
                    side: const BorderSide(color: CohabiColors.turquoise),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ver piso', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: match.hasApplied ? null : CohabiColors.primaryGradient,
                    color: match.hasApplied ? CohabiColors.turquoiseSoft : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: match.hasApplied ? null : onApply,
                    style: TextButton.styleFrom(
                      foregroundColor: match.hasApplied ? CohabiColors.turquoise : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      match.hasApplied ? 'Solicitud enviada' : 'Me interesa →',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? CohabiColors.turquoise : CohabiColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? CohabiColors.turquoise : CohabiColors.navy),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(color: selected ? CohabiColors.turquoise : CohabiColors.navy, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(color: CohabiColors.purpleSoft, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, color: CohabiColors.purple, size: 42),
            ),
            const SizedBox(height: 18),
            const Text('Aún no hay opciones publicadas', style: TextStyle(color: CohabiColors.navy, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Cuando haya habitaciones publicadas que encajen con tu búsqueda aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CohabiColors.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
