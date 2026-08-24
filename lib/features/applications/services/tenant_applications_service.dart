import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tenant_application.dart';

class TenantApplicationsService {
  final SupabaseClient _supabase;

  TenantApplicationsService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final value = _supabase.auth.currentUser?.id;
    if (value == null) throw StateError('No hay una sesión iniciada.');
    return value;
  }

  Future<List<TenantApplication>> loadApplications() async {
    final response = await _supabase
        .from('applications')
        .select(
          'id, property_id, room_id, status, created_at, updated_at, visit_scheduled_at',
        )
        .eq('tenant_id', _userId)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(
      (response as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final result = <TenantApplication>[];

    for (final row in rows) {
      final propertyId = row['property_id']?.toString() ?? '';
      final roomId = row['room_id']?.toString() ?? '';
      if (propertyId.isEmpty || roomId.isEmpty) continue;

      Map<String, dynamic> property = const {};
      Map<String, dynamic> room = const {};
      List<ApplicationVisitSlot> slots = const [];
      String? imageUrl;

      try {
        final value = await _supabase
            .from('properties')
            .select('id, name, address, city')
            .eq('id', propertyId)
            .single();
        property = Map<String, dynamic>.from(value);
      } catch (_) {}

      try {
        final value = await _supabase
            .from('rooms')
            .select('id, room_number, monthly_price, available_from')
            .eq('id', roomId)
            .single();
        room = Map<String, dynamic>.from(value);
      } catch (_) {}

      try {
        final value = await _supabase
            .from('application_visit_slots')
            .select('id, scheduled_at, status')
            .eq('application_id', row['id'].toString())
            .eq('status', 'available')
            .order('scheduled_at', ascending: true);

        slots = List<Map<String, dynamic>>.from(
          (value as List).map((e) => Map<String, dynamic>.from(e as Map)),
        )
            .map(
              (slot) => ApplicationVisitSlot(
                id: slot['id'].toString(),
                scheduledAt: DateTime.parse(slot['scheduled_at'].toString()),
                status: slot['status']?.toString() ?? 'available',
              ),
            )
            .toList();
      } catch (_) {
        slots = const [];
      }

      try {
        final photos = await _supabase
            .from('property_photos')
            .select('storage_path, position')
            .eq('property_id', propertyId)
            .order('position', ascending: true)
            .limit(1);

        final list = photos as List<dynamic>;
        if (list.isNotEmpty) {
          final path = list.first['storage_path']?.toString();
          if (path != null && path.isNotEmpty) {
            try {
              imageUrl = await _supabase.storage
                  .from('property-photos')
                  .createSignedUrl(path, 3600);
            } catch (_) {}
          }
        }
      } catch (_) {}

      result.add(
        TenantApplication(
          id: row['id'].toString(),
          propertyId: propertyId,
          roomId: roomId,
          status: row['status']?.toString() ?? 'pending',
          createdAt: _date(row['created_at']) ?? DateTime.now(),
          updatedAt: _date(row['updated_at']),
          visitScheduledAt: _date(row['visit_scheduled_at']),
          propertyName: property['name']?.toString() ?? 'Piso Cohabi',
          city: property['city']?.toString() ?? '',
          address: property['address']?.toString(),
          roomNumber: _int(room['room_number'], 1),
          monthlyPrice: _double(room['monthly_price']),
          availableFrom: _date(room['available_from']),
          imageUrl: imageUrl,
          visitSlots: slots,
        ),
      );
    }

    return result;
  }

  Future<void> confirmVisit(String slotId) async {
    await _supabase.rpc(
      'tenant_confirm_visit',
      params: {'target_slot_id': slotId},
    );
  }

  Future<void> declineVisit(String applicationId) async {
    await _supabase.rpc(
      'tenant_decline_visit',
      params: {'target_application_id': applicationId},
    );
  }

  Future<void> withdrawApplication(String applicationId) async {
    await _supabase
        .from('applications')
        .update({'status': 'withdrawn'})
        .eq('id', applicationId)
        .eq('tenant_id', _userId);
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
