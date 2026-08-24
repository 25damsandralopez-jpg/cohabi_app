import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../results/screens/tenant_best_matches_screen.dart';
import '../services/tenant_selection_service.dart';
import 'tenant_selection_screen.dart';

class TenantSelectionGateScreen extends StatefulWidget {
  const TenantSelectionGateScreen({super.key});

  @override
  State<TenantSelectionGateScreen> createState() => _TenantSelectionGateScreenState();
}

class _TenantSelectionGateScreenState extends State<TenantSelectionGateScreen> {
  final _service = TenantSelectionService();
  bool _loading = true;
  bool _completed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _service.getOrCreate();
      if (!mounted) return;
      setState(() {
        _completed = profile.completed;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: CohabiColors.background,
        body: Center(child: CircularProgressIndicator(color: CohabiColors.turquoise)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: CohabiColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo abrir Cohabi Selección: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: CohabiColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return _completed
        ? const TenantBestMatchesScreen()
        : const TenantSelectionScreen();
  }
}
