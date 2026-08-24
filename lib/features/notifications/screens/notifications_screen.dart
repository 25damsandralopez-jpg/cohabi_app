import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final response = await Supabase.instance.client
          .from('notifications')
          .select('id, type, title, body, is_read, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from((response as List).map((e) => Map<String, dynamic>.from(e as Map)));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    await Supabase.instance.client.rpc('mark_all_notifications_read');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text('Notificaciones', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
        actions: [TextButton(onPressed: _markAll, child: const Text('Marcar leídas'))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : _rows.isEmpty
              ? const Center(child: Text('No tienes notificaciones.', style: TextStyle(color: CohabiColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final n = _rows[index];
                    final unread = n['is_read'] != true;
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: unread ? CohabiColors.purpleSoft : Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: CohabiColors.border),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(unread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, color: unread ? CohabiColors.purple : CohabiColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n['title']?.toString() ?? 'Notificación', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
                          if (n['body']?.toString().trim().isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(n['body'].toString(), style: const TextStyle(color: CohabiColors.textSecondary, height: 1.35)),
                          ],
                        ])),
                      ]),
                    );
                  },
                ),
    );
  }
}
