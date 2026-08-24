import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerPropertyDetailService {
  final SupabaseClient _client;

  OwnerPropertyDetailService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>> load(String propertyId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada.');

    final property = Map<String, dynamic>.from(
      await _client
          .from('properties')
          .select('id, owner_id, name, address, city, postal_code, property_type, rooms, bathrooms, surface, condition, tenant_type, features, services, other_services, status')
          .eq('id', propertyId)
          .eq('owner_id', user.id)
          .single(),
    );

    final roomRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('rooms')
                  .select('id, room_number, status, available_from, monthly_price, deposit, reservation_price, min_stay, max_stay, max_people, area_m2, bed_size, private_bathroom, room_lock, private_kitchen, exterior_view, equipment')
                  .eq('property_id', propertyId)
                  .order('room_number', ascending: true)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final tenancyRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('tenancies')
                  .select('id, tenant_id, room_id, start_date, end_date, monthly_rent, deposit, status, check_in_at, check_out_at')
                  .eq('property_id', propertyId)
                  .order('created_at', ascending: false)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final tenantIds = tenancyRows
        .map((e) => e['tenant_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    final profiles = <String, Map<String, dynamic>>{};
    if (tenantIds.isNotEmpty) {
      final profileRows = await _client
          .from('profiles')
          .select('id, first_name, last_name, phone')
          .inFilter('id', tenantIds);
      for (final item in (profileRows as List)) {
        final row = Map<String, dynamic>.from(item as Map);
        profiles[row['id'].toString()] = row;
      }
    }

    final paymentRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('payments')
                  .select('id, tenancy_id, tenant_id, room_id, concept, amount, due_date, paid_at, status, notes')
                  .eq('property_id', propertyId)
                  .order('due_date', ascending: false)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final incidentRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('incidents')
                  .select('id, tenancy_id, room_id, tenant_id, category, title, description, priority, status, owner_notes, resolved_at, created_at')
                  .eq('property_id', propertyId)
                  .order('created_at', ascending: false)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final expenseRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('property_expenses')
                  .select('id, category, concept, amount, expense_date, recurring, notes')
                  .eq('property_id', propertyId)
                  .order('expense_date', ascending: false)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final announcementRows = List<Map<String, dynamic>>.from(
      ((await _client
                  .from('property_announcements')
                  .select('id, title, body, created_at')
                  .eq('property_id', propertyId)
                  .order('created_at', ascending: false)
                  .limit(10)) as List)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

    final filter = await _client
        .from('property_selection_filters')
        .select()
        .eq('property_id', propertyId)
        .maybeSingle();

    String? heroUrl;
    int photoCount = 0;
    try {
      final photoRows = await _client
          .from('property_photos')
          .select('storage_path, position')
          .eq('property_id', propertyId)
          .order('position', ascending: true);
      final photos = List<Map<String, dynamic>>.from(
        (photoRows as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      photoCount = photos.length;
      if (photos.isNotEmpty) {
        final path = photos.first['storage_path']?.toString();
        if (path != null && path.isNotEmpty) {
          heroUrl = await _client.storage
              .from('property-photos')
              .createSignedUrl(path, 3600);
        }
      }
    } catch (_) {}

    return {
      'property': property,
      'rooms': roomRows,
      'tenancies': tenancyRows,
      'profiles': profiles,
      'payments': paymentRows,
      'incidents': incidentRows,
      'expenses': expenseRows,
      'announcements': announcementRows,
      'selection_filter': filter == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(filter),
      'hero_url': heroUrl,
      'photo_count': photoCount,
    };
  }

  Future<void> saveSelectionFilter(
    String propertyId,
    Map<String, dynamic> values,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada.');
    await _client.from('property_selection_filters').upsert({
      'property_id': propertyId,
      'owner_id': user.id,
      ...values,
    }, onConflict: 'property_id');
  }

  Future<void> sendAnnouncement(
    String propertyId, {
    required String title,
    required String body,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay una sesión iniciada.');
    await _client.from('property_announcements').insert({
      'property_id': propertyId,
      'owner_id': user.id,
      'title': title,
      'body': body,
    });

    final tenancies = await _client
        .from('tenancies')
        .select('tenant_id')
        .eq('property_id', propertyId)
        .inFilter('status', ['reserved', 'active', 'ending']);

    final tenantIds = (tenancies as List)
        .map((e) => (e as Map)['tenant_id']?.toString())
        .whereType<String>()
        .toSet();

    if (tenantIds.isNotEmpty) {
      try {
        await _client.from('notifications').insert(
              tenantIds
                  .map((tenantId) => {
                        'user_id': tenantId,
                        'type': 'announcement',
                        'title': title,
                        'body': body,
                        'entity_type': 'property',
                        'entity_id': propertyId,
                      })
                  .toList(),
            );
      } catch (_) {
        // El aviso queda guardado aunque una política antigua de notifications
        // todavía no permita el insert directo.
      }
    }
  }

  Future<void> markPaymentPaid(String paymentId) async {
    await _client.from('payments').update({
      'status': 'paid',
      'paid_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', paymentId);
  }
}
