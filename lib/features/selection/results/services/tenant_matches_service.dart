import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tenant_match.dart';

class TenantMatchesService {
  final SupabaseClient _supabase;

  TenantMatchesService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión iniciada.');
    return id;
  }

  /// MVP actual: muestra todas las habitaciones disponibles de pisos publicados.
  Future<List<TenantMatch>> loadMatches() async {
    final propertiesResponse = await _supabase
        .from('properties')
        .select('id, name, address, city, status')
        .eq('status', 'published')
        .order('created_at', ascending: false);

    final properties = List<Map<String, dynamic>>.from(
      (propertiesResponse as List)
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );

    final favoriteKeys = <String>{};
    final appliedKeys = <String>{};

    // Estas tablas son auxiliares. Si todavía no existen o falla RLS,
    // la pantalla de pisos sigue funcionando.
    try {
      final favorites = await _supabase
          .from('tenant_favorites')
          .select('property_id, room_id')
          .eq('tenant_id', _userId);
      for (final raw in favorites as List<dynamic>) {
        favoriteKeys.add('${raw['property_id']}:${raw['room_id']}');
      }
    } catch (_) {}

    try {
      final applications = await _supabase
          .from('applications')
          .select('property_id, room_id, status')
          .eq('tenant_id', _userId)
          .neq('status', 'withdrawn');
      for (final raw in applications as List<dynamic>) {
        appliedKeys.add('${raw['property_id']}:${raw['room_id']}');
      }
    } catch (_) {}

    final matches = <TenantMatch>[];

    for (final property in properties) {
      final propertyId = property['id']?.toString();
      if (propertyId == null || propertyId.isEmpty) continue;

      final roomsResponse = await _supabase
          .from('rooms')
          .select('id, room_number, status, available_from, monthly_price')
          .eq('property_id', propertyId)
          .eq('status', 'Disponible')
          .order('monthly_price', ascending: true);

      final rooms = List<Map<String, dynamic>>.from(
        (roomsResponse as List)
            .map((item) => Map<String, dynamic>.from(item as Map)),
      );

      if (rooms.isEmpty) continue;

      String? imageUrl;
      try {
        final photosResponse = await _supabase
            .from('property_photos')
            .select('storage_path, position')
            .eq('property_id', propertyId)
            .order('position', ascending: true)
            .limit(1);

        final photos = photosResponse as List<dynamic>;
        if (photos.isNotEmpty) {
          final path = photos.first['storage_path']?.toString();
          if (path != null && path.isNotEmpty) {
            try {
              imageUrl = await _supabase.storage
                  .from('property-photos')
                  .createSignedUrl(path, 3600);
            } catch (_) {}
          }
        }
      } catch (_) {}

      for (final room in rooms) {
        final roomId = room['id']?.toString();
        if (roomId == null || roomId.isEmpty) continue;
        final key = '$propertyId:$roomId';

        matches.add(
          TenantMatch(
            propertyId: propertyId,
            roomId: roomId,
            propertyName: property['name']?.toString() ?? 'Piso Cohabi',
            city: property['city']?.toString() ?? '',
            address: property['address']?.toString(),
            roomNumber: _toInt(room['room_number'], fallback: 1),
            monthlyPrice: _toDouble(room['monthly_price']),
            availableFrom: _parseDate(room['available_from']),
            imageUrl: imageUrl,
            score: 0,
            reasons: const ['Habitación disponible'],
            isFavorite: favoriteKeys.contains(key),
            hasApplied: appliedKeys.contains(key),
          ),
        );
      }
    }

    matches.sort((a, b) => a.monthlyPrice.compareTo(b.monthlyPrice));
    return matches;
  }

  Future<bool> toggleFavorite(TenantMatch match) async {
    if (match.isFavorite) {
      await _supabase
          .from('tenant_favorites')
          .delete()
          .eq('tenant_id', _userId)
          .eq('property_id', match.propertyId)
          .eq('room_id', match.roomId);
      return false;
    }

    await _supabase.from('tenant_favorites').insert({
      'tenant_id': _userId,
      'property_id': match.propertyId,
      'room_id': match.roomId,
    });
    return true;
  }

  Future<String> apply(TenantMatch match) async {
    final existing = await _supabase
        .from('applications')
        .select('id, status')
        .eq('tenant_id', _userId)
        .eq('property_id', match.propertyId)
        .eq('room_id', match.roomId)
        .maybeSingle();

    if (existing != null) return existing['id'].toString();

    final inserted = await _supabase
        .from('applications')
        .insert({
          'tenant_id': _userId,
          'property_id': match.propertyId,
          'room_id': match.roomId,
          'status': 'pending',
        })
        .select('id')
        .single();

    return inserted['id'].toString();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
