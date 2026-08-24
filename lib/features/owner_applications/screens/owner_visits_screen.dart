import 'package:flutter/material.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../models/owner_application.dart';
import '../services/owner_applications_service.dart';

class OwnerVisitsScreen extends StatefulWidget {
  const OwnerVisitsScreen({super.key});

  @override
  State<OwnerVisitsScreen> createState() => _OwnerVisitsScreenState();
}

class _OwnerVisitsScreenState extends State<OwnerVisitsScreen> {
  final _service = OwnerApplicationsService();
  bool _loading = true;
  String? _error;
  List<OwnerApplication> _visits = [];

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
      final all = await _service.loadApplications();
      if (!mounted) return;
      setState(() {
        _visits = all
            .where((e) => e.visitScheduledAt != null && const {
                  'visit_confirmed',
                  'accepted',
                }.contains(e.status))
            .toList()
          ..sort((a, b) => a.visitScheduledAt!.compareTo(b.visitScheduledAt!));
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
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (index) => handleOwnerNavigation(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: CohabiColors.turquoise,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            children: [
              const Text(
                'Visitas',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aquí aparecen las visitas confirmadas por tus candidatos.',
                style: TextStyle(color: CohabiColors.textSecondary),
              ),
              const SizedBox(height: 22),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: CohabiColors.turquoise)),
                )
              else if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.redAccent))
              else if (_visits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CohabiColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.event_available_outlined, color: CohabiColors.turquoise, size: 52),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no tienes visitas confirmadas.',
                        style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                )
              else
                ..._visits.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CohabiColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: CohabiColors.turquoiseSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calendar_month_rounded, color: CohabiColors.turquoise),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.tenantName,
                                  style: const TextStyle(
                                    color: CohabiColors.navy,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${app.propertyName} · Habitación ${app.roomNumber}',
                                  style: const TextStyle(color: CohabiColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _dateTime(app.visitScheduledAt!),
                                  style: const TextStyle(
                                    color: CohabiColors.turquoise,
                                    fontWeight: FontWeight.w800,
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
            ],
          ),
        ),
      ),
    );
  }

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}
