import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerTenantsScreen extends StatefulWidget {
  const OwnerTenantsScreen({super.key});

  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await Supabase.instance.client.rpc('owner_application_feed');
      final rows = List<Map<String, dynamic>>.from(
        (response as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ).where((e) => e['status'] == 'accepted').toList();
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text('Inquilinos', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : _rows.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Aún no tienes inquilinos aceptados. Cuando aceptes un candidato aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CohabiColors.textSecondary, height: 1.4),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final row = _rows[index];
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: CohabiColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: CohabiColors.turquoiseSoft,
                            child: Icon(Icons.person_rounded, color: CohabiColors.turquoise),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row['tenant_name']?.toString() ?? 'Inquilino', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text('${row['property_name'] ?? ''} · Hab. ${row['room_number'] ?? ''}', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 3, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }
}
