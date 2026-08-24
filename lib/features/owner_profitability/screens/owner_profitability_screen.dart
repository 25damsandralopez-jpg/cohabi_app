import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerProfitabilityScreen extends StatefulWidget {
  const OwnerProfitabilityScreen({super.key});

  @override
  State<OwnerProfitabilityScreen> createState() => _OwnerProfitabilityScreenState();
}

class _OwnerProfitabilityScreenState extends State<OwnerProfitabilityScreen> {
  bool _loading = true;
  double _expected = 0;
  double _collected = 0;
  double _expenses = 0;
  int _rooms = 0;
  int _occupied = 0;
  List<Map<String, dynamic>> _properties = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      final propsResponse = await client.from('properties').select('id,name').eq('owner_id', user.id);
      final propertyRows = List<Map<String, dynamic>>.from((propsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)));
      final ids = propertyRows.map((e) => e['id'].toString()).toList();
      if (ids.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final roomsResponse = await client.from('rooms').select('status').inFilter('property_id', ids);
      final roomRows = List<Map<String, dynamic>>.from((roomsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)));

      final paymentsResponse = await client.from('payments').select('amount,status').inFilter('property_id', ids);
      final payments = List<Map<String, dynamic>>.from((paymentsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)));

      final expensesResponse = await client.from('property_expenses').select('amount').eq('owner_id', user.id);
      final expenses = List<Map<String, dynamic>>.from((expensesResponse as List).map((e) => Map<String, dynamic>.from(e as Map)));

      if (!mounted) return;
      setState(() {
        _properties = propertyRows;
        _rooms = roomRows.length;
        _occupied = roomRows.where((r) => r['status'] == 'Ocupada').length;
        _expected = payments.where((p) => p['status'] != 'cancelled').fold(0, (sum, p) => sum + _num(p['amount']));
        _collected = payments.where((p) => p['status'] == 'paid').fold(0, (sum, p) => sum + _num(p['amount']));
        _expenses = expenses.fold(0, (sum, e) => sum + _num(e['amount']));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addExpense() async {
    if (_properties.isEmpty) return;
    final amount = TextEditingController();
    final concept = TextEditingController();
    String propertyId = _properties.first['id'].toString();
    String category = 'Mantenimiento';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Registrar gasto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: propertyId,
                  decoration: const InputDecoration(labelText: 'Piso'),
                  items: _properties.map((p) => DropdownMenuItem(value: p['id'].toString(), child: Text(p['name']?.toString() ?? 'Piso'))).toList(),
                  onChanged: (v) => setLocalState(() => propertyId = v ?? propertyId),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const ['Comunidad','Electricidad','Agua','Internet','Seguro','Reparaciones','Limpieza','Mantenimiento','Otros'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setLocalState(() => category = v ?? category),
                ),
                const SizedBox(height: 10),
                TextField(controller: concept, decoration: const InputDecoration(labelText: 'Concepto')),
                const SizedBox(height: 10),
                TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Importe €')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(amount.text.trim().replaceAll(',', '.'));
                if (value == null || value <= 0) return;
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) return;
                await Supabase.instance.client.from('property_expenses').insert({
                  'property_id': propertyId,
                  'owner_id': user.id,
                  'category': category,
                  'concept': concept.text.trim(),
                  'amount': value,
                  'expense_date': DateTime.now().toIso8601String().split('T').first,
                });
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    amount.dispose();
    concept.dispose();
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final occupancy = _rooms == 0 ? 0 : ((_occupied / _rooms) * 100).round();
    final result = _collected - _expenses;
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(backgroundColor: CohabiColors.background, elevation: 0, title: const Text('Rentabilidad', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  _card('Ingresos previstos', '${_expected.toStringAsFixed(0)} €', Icons.event_note_rounded, CohabiColors.blue),
                  const SizedBox(height: 10),
                  _card('Ingresos cobrados', '${_collected.toStringAsFixed(0)} €', Icons.payments_outlined, CohabiColors.turquoise),
                  const SizedBox(height: 10),
                  _card('Gastos registrados', '${_expenses.toStringAsFixed(0)} €', Icons.receipt_long_outlined, Colors.orange),
                  const SizedBox(height: 10),
                  _card('Resultado', '${result.toStringAsFixed(0)} €', Icons.trending_up_rounded, result >= 0 ? CohabiColors.success : Colors.redAccent),
                  const SizedBox(height: 10),
                  _card('Ocupación actual', '$occupancy%', Icons.donut_large_rounded, CohabiColors.purple),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: CohabiColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gasto'),
      ),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 5, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }

  double _num(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

  Widget _card(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: CohabiColors.border)),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w700))),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        ]),
      );
}
