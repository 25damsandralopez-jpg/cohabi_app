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

  /// Devuelve todas las habitaciones DISPONIBLES de pisos PUBLICADOS.
  ///
  /// Las preferencias del tenant (ciudad, presupuesto, fecha, zona...) y los
  /// criterios del propietario NO ocultan resultados: se usan únicamente para
  /// calcular el nivel de compatibilidad y ordenar la lista.
  ///
  /// Los únicos requisitos duros son:
  /// 1) property.status == 'published'
  /// 2) room.status == 'Disponible'
  ///
  /// El score NO es aleatorio: se calcula solo con criterios reales que
  /// podemos comprobar con datos existentes en Supabase.
  Future<List<TenantMatch>> loadMatches() async {
    final tenantResponse = await _supabase
        .from('tenant_profiles')
        .select()
        .eq('user_id', _userId)
        .single();
    final tenant = Map<String, dynamic>.from(tenantResponse);

    Map<String, dynamic> selection = {};
    try {
      final selectionResponse = await _supabase
          .from('tenant_selection_profiles')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();
      if (selectionResponse != null) {
        selection = Map<String, dynamic>.from(selectionResponse);
      }
    } catch (_) {}

    final propertiesResponse = await _supabase
        .from('properties')
        .select('id, name, address, city, status, tenant_type, property_type')
        .eq('status', 'published')
        .order('created_at', ascending: false);

    final properties = List<Map<String, dynamic>>.from(
      (propertiesResponse as List)
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );

    final favoriteKeys = <String>{};
    final appliedKeys = <String>{};

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

    final searchZone = _normalize(tenant['search_zone']);
    final maxBudget = _toDouble(tenant['max_monthly_budget']);
    final entryDate = _parseDate(tenant['entry_date']);
    final age = _ageFromBirthDate(_parseDate(tenant['birth_date']));
    final smoker = _bool(tenant['smoker']);
    final hasPet = _bool(tenant['has_pet']);
    final income = _incomeLowerBound(
      tenant['monthly_income']?.toString() ??
          selection['monthly_income_range']?.toString(),
    );
    final incomeVerifiable = _bool(selection['income_verifiable']);
    final stayMonths = _stayMonths(tenant['stay_duration']?.toString());

    final matches = <TenantMatch>[];

    for (final property in properties) {
      final propertyId = property['id']?.toString();
      if (propertyId == null || propertyId.isEmpty) continue;

      Map<String, dynamic> ownerFilter = {};
      try {
        final filterResponse = await _supabase
            .from('property_selection_filters')
            .select()
            .eq('property_id', propertyId)
            .maybeSingle();
        if (filterResponse != null) {
          ownerFilter = Map<String, dynamic>.from(filterResponse);
        }
      } catch (_) {
        // Si el tenant no puede leer el filtro por RLS, la vivienda sigue
        // siendo visible y simplemente no usamos criterios privados del owner.
      }

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

        final monthlyPrice = _toDouble(room['monthly_price']);
        final availableFrom = _parseDate(room['available_from']);

        // Presupuesto y fecha ya no excluyen la habitación.
        // Se ponderan dentro del score para que las opciones que mejor encajan
        // aparezcan antes, sin ocultar otras habitaciones disponibles.

        final result = _compatibility(
          property: property,
          room: room,
          ownerFilter: ownerFilter,
          tenant: tenant,
          selection: selection,
          searchZone: searchZone,
          maxBudget: maxBudget,
          entryDate: entryDate,
          age: age,
          income: income,
          smoker: smoker,
          hasPet: hasPet,
          incomeVerifiable: incomeVerifiable,
          stayMonths: stayMonths,
        );

        final key = '$propertyId:$roomId';
        matches.add(
          TenantMatch(
            propertyId: propertyId,
            roomId: roomId,
            propertyName: property['name']?.toString() ?? 'Piso Cohabi',
            city: property['city']?.toString() ?? '',
            address: property['address']?.toString(),
            roomNumber: _toInt(room['room_number'], fallback: 1),
            monthlyPrice: monthlyPrice,
            availableFrom: availableFrom,
            imageUrl: imageUrl,
            score: result.score,
            reasons: result.reasons,
            isFavorite: favoriteKeys.contains(key),
            hasApplied: appliedKeys.contains(key),
          ),
        );
      }
    }

    matches.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      return a.monthlyPrice.compareTo(b.monthlyPrice);
    });
    return matches;
  }

  bool _passesOwnerEligibility(
    Map<String, dynamic> filter, {
    required int? age,
    required double? monthlyIncome,
    required bool smoker,
    required bool hasPet,
    required bool incomeVerifiable,
    required int? stayMonths,
  }) {
    if (filter.isEmpty) return true;

    final minAge = _toNullableInt(filter['min_age']);
    final maxAge = _toNullableInt(filter['max_age']);
    final minIncome = _toNullableDouble(filter['min_monthly_income']);
    final minStay = _toNullableInt(filter['min_stay_months']);

    if (minAge != null && age != null && age < minAge) return false;
    if (maxAge != null && age != null && age > maxAge) return false;
    if (minIncome != null && monthlyIncome != null && monthlyIncome < minIncome) {
      return false;
    }
    if (filter['non_smokers_only'] == true && smoker) return false;
    if (filter['no_pets'] == true && hasPet) return false;
    if (filter['income_verifiable'] == true && !incomeVerifiable) return false;
    if (minStay != null && stayMonths != null && stayMonths < minStay) {
      return false;
    }
    return true;
  }

  _CompatibilityResult _compatibility({
    required Map<String, dynamic> property,
    required Map<String, dynamic> room,
    required Map<String, dynamic> ownerFilter,
    required Map<String, dynamic> tenant,
    required Map<String, dynamic> selection,
    required String searchZone,
    required double maxBudget,
    required DateTime? entryDate,
    required int? age,
    required double? income,
    required bool smoker,
    required bool hasPet,
    required bool incomeVerifiable,
    required int? stayMonths,
  }) {
    // Modelo Cohabi actual: 100 puntos exactos.
    //
    // Ciudad                  20
    // Presupuesto             20
    // Fecha de entrada        15
    // Duración                10
    // Edad                     5
    // Ingresos mínimos        10
    // No fumador               5
    // Mascotas                 5
    // Ingresos verificables    5
    // Zona / requisito básico  5
    // TOTAL                  100
    int score = 0;
    final reasons = <String>[];

    void add(bool matches, int weight, String reason) {
      if (!matches) return;
      score += weight;
      reasons.add(reason);
    }

    // 1) CIUDAD - 20%
    final propertyCity = _normalize(property['city']);
    final searchCity = _normalize(tenant['search_city']);
    add(
      searchCity.isNotEmpty &&
          propertyCity.isNotEmpty &&
          propertyCity == searchCity,
      20,
      'Ciudad compatible',
    );

    // 2) PRESUPUESTO - 20%
    final price = _toDouble(room['monthly_price']);
    add(
      maxBudget > 0 && price <= maxBudget,
      20,
      'Dentro de tu presupuesto',
    );

    // 3) FECHA DE ENTRADA - 15%
    final availableFrom = _parseDate(room['available_from']);
    final entryMatches = entryDate != null &&
        (availableFrom == null || !availableFrom.isAfter(entryDate));
    add(
      entryMatches,
      15,
      'Disponible para tu fecha',
    );

    // 4) DURACIÓN DE ESTANCIA - 10%
    final minStay = _toNullableInt(ownerFilter['min_stay_months']);
    final stayMatches = minStay == null ||
        (stayMonths != null && stayMonths >= minStay);
    add(
      stayMatches,
      10,
      minStay == null
          ? 'Sin restricción de estancia'
          : 'Estancia compatible',
    );

    // 5) EDAD - 5%
    final minAge = _toNullableInt(ownerFilter['min_age']);
    final maxAge = _toNullableInt(ownerFilter['max_age']);
    final ageMatches = (minAge == null && maxAge == null) ||
        (age != null &&
            (minAge == null || age >= minAge) &&
            (maxAge == null || age <= maxAge));
    add(
      ageMatches,
      5,
      minAge == null && maxAge == null
          ? 'Sin restricción de edad'
          : 'Edad compatible',
    );

    // 6) INGRESOS MÍNIMOS - 10%
    final minIncome = _toNullableDouble(ownerFilter['min_monthly_income']);
    final incomeMatches =
        minIncome == null || (income != null && income >= minIncome);
    add(
      incomeMatches,
      10,
      minIncome == null
          ? 'Sin mínimo de ingresos'
          : 'Ingresos compatibles',
    );

    // 7) NO FUMADOR - 5%
    final nonSmokersOnly = ownerFilter['non_smokers_only'] == true;
    add(
      !nonSmokersOnly || !smoker,
      5,
      nonSmokersOnly
          ? 'Compatible con política de no fumadores'
          : 'Sin restricción de fumador',
    );

    // 8) MASCOTAS - 5%
    final noPets = ownerFilter['no_pets'] == true;
    add(
      !noPets || !hasPet,
      5,
      noPets
          ? 'Compatible con política de mascotas'
          : 'Mascotas permitidas o sin restricción',
    );

    // 9) INGRESOS VERIFICABLES - 5%
    final requiresVerifiableIncome =
        ownerFilter['income_verifiable'] == true;
    add(
      !requiresVerifiableIncome || incomeVerifiable,
      5,
      requiresVerifiableIncome
          ? 'Ingresos verificables'
          : 'Sin requisito de verificación de ingresos',
    );

    // 10) ZONA / OTRO REQUISITO BÁSICO - 5%
    //
    // El esquema actual no tiene un campo estructurado de barrio/zona en
    // properties, por lo que usamos address. Si el tenant no ha indicado zona,
    // no existe una incompatibilidad y se conceden los 5 puntos.
    final address = _normalize(property['address']);
    final zoneMatches = searchZone.isEmpty ||
        (address.isNotEmpty && address.contains(searchZone));
    add(
      zoneMatches,
      5,
      searchZone.isEmpty
          ? 'Sin restricción de zona'
          : 'Zona compatible',
    );

    if (reasons.isEmpty) {
      reasons.add('Habitación publicada y disponible');
    }

    return _CompatibilityResult(
      score.clamp(0, 100),
      reasons.take(5).toList(),
    );
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

  String _normalize(dynamic value) {
    return (value?.toString() ?? '').trim().toLowerCase();
  }

  bool _bool(dynamic value) {
    if (value is bool) return value;
    final text = _normalize(value);
    return ['sí', 'si', 'true', 'yes', '1'].contains(text);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  int? _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double? _incomeLowerBound(String? value) {
    if (value == null || value.trim().isEmpty || value.contains('Selecciona')) {
      return null;
    }
    final cleaned = value.replaceAll('.', '').replaceAll('€', '').trim();
    if (cleaned.toLowerCase().contains('menos de')) return 0;
    if (cleaned.toLowerCase().contains('más de')) {
      final digits = RegExp(r'\d+').allMatches(cleaned).map((m) => m.group(0)!).join();
      return double.tryParse(digits);
    }
    final first = RegExp(r'\d[\d\s]*').firstMatch(cleaned)?.group(0)?.replaceAll(' ', '');
    return first == null ? null : double.tryParse(first);
  }

  int? _stayMonths(String? value) {
    if (value == null) return null;
    final text = value.toLowerCase();
    if (text.contains('menos de 3')) return 2;
    if (text.contains('3 a 6')) return 6;
    if (text.contains('6 a 12')) return 12;
    if (text.contains('más de 12')) return 24;
    return null;
  }
}

class _CompatibilityResult {
  final int score;
  final List<String> reasons;

  const _CompatibilityResult(this.score, this.reasons);
}
