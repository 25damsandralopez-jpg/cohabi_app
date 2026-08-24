import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/owner_application.dart';

class OwnerApplicationsService {
  final SupabaseClient _supabase;

  OwnerApplicationsService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final value = _supabase.auth.currentUser?.id;
    if (value == null) throw StateError('No hay una sesión iniciada.');
    return value;
  }

  Future<List<OwnerApplication>> loadApplications() async {
    final response = await _supabase.rpc('owner_application_feed');

    final rows = List<Map<String, dynamic>>.from(
      (response as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final result = <OwnerApplication>[];

    for (final row in rows) {
      final applicationId = row['application_id']?.toString() ?? '';
      if (applicationId.isEmpty) continue;

      List<OwnerVisitSlot> slots = const [];

      try {
        final slotResponse = await _supabase
            .from('application_visit_slots')
            .select('id, scheduled_at, status')
            .eq('application_id', applicationId)
            .order('scheduled_at', ascending: true);

        slots = List<Map<String, dynamic>>.from(
          (slotResponse as List)
              .map((e) => Map<String, dynamic>.from(e as Map)),
        )
            .map(
              (slot) => OwnerVisitSlot(
                id: slot['id'].toString(),
                scheduledAt: DateTime.parse(slot['scheduled_at'].toString()),
                status: slot['status']?.toString() ?? 'available',
              ),
            )
            .toList();
      } catch (_) {
        slots = const [];
      }

      result.add(
        OwnerApplication(
          id: applicationId,
          tenantId: row['tenant_id']?.toString() ?? '',
          tenantName: row['tenant_name']?.toString().trim().isNotEmpty == true
              ? row['tenant_name'].toString()
              : 'Inquilino Cohabi',
          propertyId: row['property_id']?.toString() ?? '',
          propertyName: row['property_name']?.toString() ?? 'Piso Cohabi',
          city: row['city']?.toString() ?? '',
          roomId: row['room_id']?.toString() ?? '',
          roomNumber: _int(row['room_number'], 1),
          monthlyPrice: _double(row['monthly_price']),
          status: row['status']?.toString() ?? 'pending',
          createdAt: _date(row['created_at']) ?? DateTime.now(),
          visitScheduledAt: _date(row['visit_scheduled_at']),
          visitSlots: slots,
        ),
      );
    }

    return result;
  }

  Future<void> markUnderReview(String applicationId) async {
    await _supabase.rpc(
      'owner_mark_application_under_review',
      params: {'target_application_id': applicationId},
    );
  }

  Future<void> proposeVisit(String applicationId) async {
    final now = DateTime.now();
    final slots = <DateTime>[
      DateTime(now.year, now.month, now.day + 1, 18, 0),
      DateTime(now.year, now.month, now.day + 2, 12, 0),
      DateTime(now.year, now.month, now.day + 3, 18, 30),
    ];

    await _supabase.rpc(
      'owner_propose_visit',
      params: {
        'target_application_id': applicationId,
        'proposed_slots': slots.map((e) => e.toUtc().toIso8601String()).toList(),
      },
    );
  }

  Future<void> rejectApplication(String applicationId) async {
    await _supabase.rpc(
      'owner_reject_application',
      params: {'target_application_id': applicationId},
    );
  }

  Future<void> acceptApplication(String applicationId) async {
    await _supabase.rpc(
      'owner_accept_application',
      params: {'target_application_id': applicationId},
    );
  }

  DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  int _int(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
