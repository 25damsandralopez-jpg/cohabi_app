import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/owner_property_detail_service.dart';

class OwnerPropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const OwnerPropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<OwnerPropertyDetailScreen> createState() =>
      _OwnerPropertyDetailScreenState();
}

class _OwnerPropertyDetailScreenState
    extends State<OwnerPropertyDetailScreen> {
  final _service = OwnerPropertyDetailService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _service.load(widget.propertyId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic> get _property =>
      Map<String, dynamic>.from((_data['property'] as Map?) ?? const {});
  List<Map<String, dynamic>> get _rooms =>
      List<Map<String, dynamic>>.from((_data['rooms'] as List?) ?? const []);
  List<Map<String, dynamic>> get _tenancies =>
      List<Map<String, dynamic>>.from((_data['tenancies'] as List?) ?? const []);
  List<Map<String, dynamic>> get _payments =>
      List<Map<String, dynamic>>.from((_data['payments'] as List?) ?? const []);
  List<Map<String, dynamic>> get _incidents =>
      List<Map<String, dynamic>>.from((_data['incidents'] as List?) ?? const []);
  List<Map<String, dynamic>> get _expenses =>
      List<Map<String, dynamic>>.from((_data['expenses'] as List?) ?? const []);
  List<Map<String, dynamic>> get _announcements =>
      List<Map<String, dynamic>>.from((_data['announcements'] as List?) ?? const []);
  Map<String, Map<String, dynamic>> get _profiles =>
      Map<String, Map<String, dynamic>>.from((_data['profiles'] as Map?) ?? const {});

  double _num(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  String _money(dynamic value) => _num(value).toStringAsFixed(0);

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'Sin fecha';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: CohabiColors.background,
        body: Center(
          child: CircularProgressIndicator(color: CohabiColors.turquoise),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: CohabiColors.background,
        appBar: AppBar(backgroundColor: CohabiColors.background),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 40),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: CohabiColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      );
    }

    final liveTenancies = _tenancies
        .where((t) => ['reserved', 'active', 'ending'].contains(t['status']))
        .toList();
    final occupied = _tenancies.where((t) => t['status'] == 'active').length;
    final reserved = _tenancies.where((t) => t['status'] == 'reserved').length;
    final openIncidents = _incidents
        .where((i) => !['resolved', 'closed'].contains(i['status']))
        .toList();
    final monthlyIncome = liveTenancies.fold<double>(
      0,
      (sum, t) => sum + _num(t['monthly_rent']),
    );
    final collected = _payments
        .where((p) => p['status'] == 'paid')
        .fold<double>(0, (sum, p) => sum + _num(p['amount']));
    final pending = _payments
        .where((p) => ['pending', 'partial', 'late'].contains(p['status']))
        .fold<double>(0, (sum, p) => sum + _num(p['amount']));
    final expenses = _expenses.fold<double>(
      0,
      (sum, e) => sum + _num(e['amount']),
    );
    final occupancy = _rooms.isEmpty
        ? 0
        : (((occupied + reserved) / _rooms.length) * 100).round();

    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 245,
              backgroundColor: Colors.white,
              foregroundColor: CohabiColors.navy,
              title: Text(
                _property['name']?.toString() ?? 'Piso',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              flexibleSpace: FlexibleSpaceBar(background: _hero()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    _property['address']?.toString().trim().isNotEmpty == true
                        ? '${_property['address']}, ${_property['city'] ?? ''}'
                        : (_property['city']?.toString() ?? ''),
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _metric('Habitaciones', '${_rooms.length}', Icons.bed_outlined,
                          CohabiColors.blue),
                      _metric('Inquilinos', '$occupied', Icons.people_outline,
                          CohabiColors.purple),
                      _metric('Ingresos/mes', '${monthlyIncome.toStringAsFixed(0)} €',
                          Icons.euro_rounded, CohabiColors.turquoise),
                      _metric('Ocupación', '$occupancy%', Icons.donut_large_rounded,
                          CohabiColors.success),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle('Ocupación del piso'),
                  const SizedBox(height: 10),
                  _roomsCard(liveTenancies),
                  const SizedBox(height: 22),
                  _sectionTitle('Inquilinos y próximas fechas'),
                  const SizedBox(height: 10),
                  _tenantsCard(liveTenancies),
                  const SizedBox(height: 22),
                  _sectionTitle('Resumen financiero'),
                  const SizedBox(height: 10),
                  _financeCard(collected, pending, expenses, monthlyIncome),
                  const SizedBox(height: 22),
                  _sectionTitle('Pagos'),
                  const SizedBox(height: 10),
                  _paymentsCard(),
                  const SizedBox(height: 22),
                  _sectionTitle('Incidencias'),
                  const SizedBox(height: 10),
                  _incidentsCard(openIncidents),
                  const SizedBox(height: 22),
                  _sectionTitle('Mensaje para todos los inquilinos'),
                  const SizedBox(height: 10),
                  _announcementsCard(),
                  const SizedBox(height: 22),
                  _sectionTitle('Filtro de selección'),
                  const SizedBox(height: 10),
                  _selectionFilterCard(),
                  const SizedBox(height: 22),
                  _sectionTitle('Datos del piso'),
                  const SizedBox(height: 10),
                  _propertyDataCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    final url = _data['hero_url']?.toString();
    final count = (_data['photo_count'] as int?) ?? 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: CohabiColors.turquoiseSoft),
        if (url != null && url.isNotEmpty)
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.apartment_rounded,
                  size: 72, color: CohabiColors.turquoise),
            ),
          )
        else
          const Center(
            child: Icon(Icons.apartment_rounded,
                size: 72, color: CohabiColors.turquoise),
          ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count fotos',
              style: const TextStyle(
                color: CohabiColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: CohabiColors.navy,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      );

  Widget _metric(String label, String value, IconData icon, Color color) =>
      _card(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.10),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                  Text(label,
                      style: const TextStyle(
                          color: CohabiColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _roomsCard(List<Map<String, dynamic>> liveTenancies) {
    if (_rooms.isEmpty) return _empty('Todavía no hay habitaciones configuradas.');
    return _card(
      child: Column(
        children: _rooms.map((room) {
          Map<String, dynamic>? tenancy;
          for (final candidate in liveTenancies) {
            if (candidate['room_id']?.toString() == room['id']?.toString()) {
              tenancy = candidate;
              break;
            }
          }
          final status = tenancy?['status']?.toString() ?? room['status']?.toString() ?? 'Disponible';
          final isActive = status == 'active';
          final isReserved = status == 'reserved';
          final color = isActive
              ? CohabiColors.success
              : isReserved
                  ? CohabiColors.purple
                  : CohabiColors.turquoise;
          final label = isActive
              ? 'Alquilada'
              : isReserved
                  ? 'Reservada'
                  : status;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(.10),
                  child: Icon(Icons.bed_outlined, color: color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Habitación ${room['room_number'] ?? ''}',
                          style: const TextStyle(
                              color: CohabiColors.navy,
                              fontWeight: FontWeight.w800)),
                      Text('${_money(room['monthly_price'])} €/mes',
                          style: const TextStyle(
                              color: CohabiColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 11)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tenantsCard(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return _empty('No hay reservas ni estancias activas.');
    return _card(
      child: Column(
        children: rows.map((row) {
          final profile = _profiles[row['tenant_id']?.toString()] ?? const {};
          final name = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
          final room = _rooms.cast<Map<String, dynamic>?>().firstWhere(
                (r) => r?['id']?.toString() == row['room_id']?.toString(),
                orElse: () => null,
              );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: CohabiColors.purpleSoft,
                  child: Text(
                    name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: CohabiColors.purple,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Inquilino' : name,
                          style: const TextStyle(
                              color: CohabiColors.navy,
                              fontWeight: FontWeight.w900)),
                      Text(
                        'Hab. ${room?['room_number'] ?? '-'} · ${row['status'] == 'reserved' ? 'Entrada' : 'Desde'} ${_date(row['start_date'])}',
                        style: const TextStyle(
                            color: CohabiColors.textSecondary, fontSize: 12),
                      ),
                      if (row['end_date'] != null)
                        Text('Salida ${_date(row['end_date'])}',
                            style: const TextStyle(
                                color: CohabiColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${_money(row['monthly_rent'])} €',
                    style: const TextStyle(
                        color: CohabiColors.turquoise,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _financeCard(
      double collected, double pending, double expenses, double monthlyIncome) {
    return _card(
      child: Column(
        children: [
          _financeRow('Ingresos mensuales activos', monthlyIncome, CohabiColors.turquoise),
          _financeRow('Pagos cobrados registrados', collected, CohabiColors.success),
          _financeRow('Pagos pendientes', pending, CohabiColors.orange),
          _financeRow('Gastos registrados', expenses, CohabiColors.coral),
          const Divider(),
          _financeRow('Resultado registrado', collected - expenses,
              collected - expenses >= 0 ? CohabiColors.success : CohabiColors.coral),
        ],
      ),
    );
  }

  Widget _financeRow(String label, double value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: CohabiColors.textSecondary)),
            ),
            Text('${value.toStringAsFixed(0)} €',
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _paymentsCard() {
    if (_payments.isEmpty) return _empty('Todavía no hay pagos registrados.');
    final rows = _payments.take(8).toList();
    return _card(
      child: Column(
        children: rows.map((payment) {
          final status = payment['status']?.toString() ?? 'pending';
          final isPaid = status == 'paid';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                    color: isPaid ? CohabiColors.success : CohabiColors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payment['concept']?.toString() ?? 'Alquiler',
                          style: const TextStyle(
                              color: CohabiColors.navy,
                              fontWeight: FontWeight.w800)),
                      Text('Vence ${_date(payment['due_date'])}',
                          style: const TextStyle(
                              color: CohabiColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${_money(payment['amount'])} €',
                    style: const TextStyle(
                        color: CohabiColors.navy, fontWeight: FontWeight.w900)),
                if (!isPaid) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await _service.markPaymentPaid(payment['id'].toString());
                      await _load();
                    },
                    child: const Text('Cobrado'),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _incidentsCard(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return _empty('No hay incidencias abiertas.');
    return _card(
      child: Column(
        children: rows.take(5).map((incident) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: CohabiColors.coralSoft,
                  child: Icon(Icons.handyman_outlined, color: CohabiColors.coral),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident['title']?.toString() ?? 'Incidencia',
                          style: const TextStyle(
                              color: CohabiColors.navy,
                              fontWeight: FontWeight.w800)),
                      Text(incident['category']?.toString() ?? 'Otros',
                          style: const TextStyle(
                              color: CohabiColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(_incidentStatus(incident['status']?.toString() ?? 'new'),
                    style: const TextStyle(
                        color: CohabiColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _incidentStatus(String value) => {
        'new': 'Nueva',
        'reviewing': 'En revisión',
        'in_progress': 'En proceso',
        'resolved': 'Resuelta',
        'closed': 'Cerrada',
      }[value] ??
      value;

  Widget _announcementsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_announcements.isEmpty)
            const Text('Todavía no has enviado avisos a este piso.',
                style: TextStyle(color: CohabiColors.textSecondary))
          else
            ..._announcements.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']?.toString() ?? 'Aviso',
                            style: const TextStyle(
                                color: CohabiColors.navy,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(item['body']?.toString() ?? '',
                            style: const TextStyle(
                                color: CohabiColors.textSecondary,
                                height: 1.35)),
                      ],
                    ),
                  ),
                ),
          ElevatedButton.icon(
            onPressed: _showAnnouncementDialog,
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Enviar mensaje'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CohabiColors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAnnouncementDialog() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mensaje al piso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mensaje'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Enviar')),
        ],
      ),
    );
    if (send == true &&
        titleController.text.trim().isNotEmpty &&
        bodyController.text.trim().isNotEmpty) {
      await _service.sendAnnouncement(
        widget.propertyId,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );
      await _load();
    }
    titleController.dispose();
    bodyController.dispose();
  }

  Widget _selectionFilterCard() {
    final filter = Map<String, dynamic>.from(
        (_data['selection_filter'] as Map?) ?? const {});
    final chips = <String>[];
    if (filter['non_smokers_only'] == true) chips.add('No fumadores');
    if (filter['no_pets'] == true) chips.add('Sin mascotas');
    if (filter['income_verifiable'] == true) chips.add('Ingresos verificables');
    if (_num(filter['min_monthly_income']) > 0) {
      chips.add('Ingresos ≥ ${_money(filter['min_monthly_income'])} €');
    }
    final minStayMonths = (filter['min_stay_months'] as num?)?.toInt();
    if (minStayMonths != null && minStayMonths > 0) {
      chips.add('Estancia ≥ $minStayMonths meses');
    }
    final minAgeValue = (filter['min_age'] as num?)?.toInt();
    if (minAgeValue != null && minAgeValue > 0) {
      final maxAgeValue = (filter['max_age'] as num?)?.toInt();
      chips.add(maxAgeValue != null && maxAgeValue > 0
          ? '$minAgeValue-$maxAgeValue años'
          : 'Desde $minAgeValue años');
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (chips.isEmpty)
            const Text('Sin filtros especiales. Se mostrarán todos los candidatos compatibles con la habitación.',
                style: TextStyle(color: CohabiColors.textSecondary, height: 1.35))
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: chips
                  .map((text) => Chip(
                        label: Text(text),
                        backgroundColor: CohabiColors.purpleSoft,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _editFilter(filter),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Modificar filtro'),
          ),
        ],
      ),
    );
  }

  Future<void> _editFilter(Map<String, dynamic> current) async {
    final minAge = TextEditingController(text: current['min_age']?.toString() ?? '');
    final maxAge = TextEditingController(text: current['max_age']?.toString() ?? '');
    final minIncome = TextEditingController(text: current['min_monthly_income']?.toString() ?? '');
    final minStay = TextEditingController(text: current['min_stay_months']?.toString() ?? '');
    bool nonSmokers = current['non_smokers_only'] == true;
    bool noPets = current['no_pets'] == true;
    bool verified = current['income_verifiable'] == true;

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Filtro de selección'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: TextField(controller: minAge, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad mín.'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: maxAge, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad máx.'))),
                ]),
                const SizedBox(height: 10),
                TextField(controller: minIncome, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ingresos mínimos €/mes')),
                const SizedBox(height: 10),
                TextField(controller: minStay, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estancia mínima (meses)')),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: nonSmokers, onChanged: (v) => setLocalState(() => nonSmokers = v), title: const Text('Solo no fumadores')),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: noPets, onChanged: (v) => setLocalState(() => noPets = v), title: const Text('Sin mascotas')),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: verified, onChanged: (v) => setLocalState(() => verified = v), title: const Text('Ingresos verificables')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );

    if (save == true) {
      int? parseInt(String text) => int.tryParse(text.trim());
      double? parseDouble(String text) => double.tryParse(text.trim().replaceAll(',', '.'));
      await _service.saveSelectionFilter(widget.propertyId, {
        'min_age': parseInt(minAge.text),
        'max_age': parseInt(maxAge.text),
        'min_monthly_income': parseDouble(minIncome.text),
        'min_stay_months': parseInt(minStay.text),
        'non_smokers_only': nonSmokers,
        'no_pets': noPets,
        'income_verifiable': verified,
      });
      await _load();
    }

    minAge.dispose();
    maxAge.dispose();
    minIncome.dispose();
    minStay.dispose();
  }

  Widget _propertyDataCard() {
    return _card(
      child: Column(
        children: [
          _dataRow('Tipo', _property['property_type']?.toString() ?? '-'),
          _dataRow('Habitaciones', '${_property['rooms'] ?? _rooms.length}'),
          _dataRow('Baños', '${_property['bathrooms'] ?? '-'}'),
          _dataRow('Superficie', _property['surface'] == null ? '-' : '${_property['surface']} m²'),
          _dataRow('Estado', _property['status']?.toString() ?? '-'),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: CohabiColors.textSecondary)),
            ),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      color: CohabiColors.navy, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );

  Widget _empty(String text) => _card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CohabiColors.textSecondary)),
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: CohabiColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08071747),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}
