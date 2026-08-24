import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/owner_application.dart';

class OwnerApplicationsService {
  final SupabaseClient _supabase;

  OwnerApplicationsService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión iniciada.');
    return id;
  }

  Future<List<OwnerApplication>> loadApplications() async {
    final ownedProperties = await _supabase
        .from('properties')
        .select('id, name')
        .eq('owner_id', _userId);

    final propertyRows = List<Map<String, dynamic>>.from(
      (ownedProperties as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    if (propertyRows.isEmpty) return [];

    final propertyMap = <String, String>{
      for (final p in propertyRows) p['id'].toString(): p['name']?.toString() ?? 'Piso Cohabi',
    };

    final apps = await _supabase
        .from('applications')
        .select('id, tenant_id, property_id, room_id, status, created_at, visit_scheduled_at')
        .inFilter('property_id', propertyMap.keys.toList())
        .order('created_at', ascending: false);

    final result = <OwnerApplication>[];
    for (final raw in apps as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final tenantId = row['tenant_id'].toString();
      final roomId = row['room_id'].toString();
      String tenantName = 'Inquilino Cohabi';
      int roomNumber = 1;

      try {
        final profile = await _supabase
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', tenantId)
            .single();
        final first = profile['first_name']?.toString() ?? '';
        final last = profile['last_name']?.toString() ?? '';
        final full = '$first $last'.trim();
        if (full.isNotEmpty) tenantName = full;
      } catch (_) {}

      try {
        final room = await _supabase
            .from('rooms')
            .select('room_number')
            .eq('id', roomId)
            .single();
        final value = room['room_number'];
        roomNumber = value is num ? value.toInt() : int.tryParse('$value') ?? 1;
      } catch (_) {}

      result.add(OwnerApplication(
        id: row['id'].toString(),
        tenantId: tenantId,
        propertyId: row['property_id'].toString(),
        roomId: roomId,
        status: row['status']?.toString() ?? 'pending',
        createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        visitScheduledAt: DateTime.tryParse(row['visit_scheduled_at']?.toString() ?? ''),
        tenantName: tenantName,
        propertyName: propertyMap[row['property_id'].toString()] ?? 'Piso Cohabi',
        roomNumber: roomNumber,
      ));
    }
    return result;
  }

  Future<void> markUnderReview(String applicationId) async {
    await _supabase.rpc('owner_mark_application_review', params: {
      'target_application_id': applicationId,
    });
  }

  Future<void> proposeVisit(String applicationId, List<DateTime> slots) async {
    await _supabase.rpc('owner_propose_visit', params: {
      'target_application_id': applicationId,
      'proposed_slots': slots.map((e) => e.toUtc().toIso8601String()).toList(),
    });
  }

  Future<void> accept(String applicationId) async {
    await _supabase.rpc('owner_decide_application', params: {
      'target_application_id': applicationId,
      'decision': 'accepted',
    });
  }

  Future<void> reject(String applicationId) async {
    await _supabase.rpc('owner_decide_application', params: {
      'target_application_id': applicationId,
      'decision': 'rejected',
    });
  }
}
