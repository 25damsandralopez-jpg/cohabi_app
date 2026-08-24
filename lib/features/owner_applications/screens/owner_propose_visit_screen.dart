import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/owner_applications_service.dart';

class OwnerProposeVisitScreen extends StatefulWidget {
  final String applicationId;
  final String candidateName;
  final String propertyName;
  final int roomNumber;

  const OwnerProposeVisitScreen({
    super.key,
    required this.applicationId,
    required this.candidateName,
    required this.propertyName,
    required this.roomNumber,
  });

  @override
  State<OwnerProposeVisitScreen> createState() =>
      _OwnerProposeVisitScreenState();
}

class _OwnerProposeVisitScreenState extends State<OwnerProposeVisitScreen> {
  final _service = OwnerApplicationsService();

  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  final List<DateTime> _slots = [];
  bool _saving = false;

  DateTime get _now => DateTime.now();

  String _two(int value) => value.toString().padLeft(2, '0');

  String _date(DateTime value) =>
      '${_two(value.day)}/${_two(value.month)}/${value.year}';

  String _time(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';

  void _addSlot() {
    final slot = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (!slot.isAfter(_now)) {
      _showError('La fecha y hora deben estar en el futuro.');
      return;
    }

    if (_slots.any((e) => e.isAtSameMomentAs(slot))) {
      _showError('Ese horario ya está añadido.');
      return;
    }

    if (_slots.length >= 6) {
      _showError('Puedes proponer un máximo de 6 horarios.');
      return;
    }

    setState(() {
      _slots.add(slot);
      _slots.sort();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _send() async {
    if (_slots.isEmpty || _saving) {
      if (_slots.isEmpty) _showError('Añade al menos un horario.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.proposeVisit(widget.applicationId, _slots);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Propuesta de visita enviada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError('No se pudo enviar la propuesta: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text(
          'Proponer visita',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CohabiColors.navy,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: CohabiColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.candidateName,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.propertyName} · Habitación ${widget.roomNumber}',
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CohabiColors.border),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDay,
              firstDate: DateTime(_now.year, _now.month, _now.day),
              lastDate: _now.add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() => _selectedDay = date);
              },
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Hora',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (selected != null) {
                setState(() => _selectedTime = selected);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CohabiColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: CohabiColors.purple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: CohabiColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _addSlot,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Añadir horario'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CohabiColors.purple,
              side: const BorderSide(color: CohabiColors.purple),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            'Horarios propuestos',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          if (_slots.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CohabiColors.border),
              ),
              child: const Text(
                'Todavía no has añadido ningún horario.',
                style: TextStyle(color: CohabiColors.textSecondary),
              ),
            )
          else
            ..._slots.map(
              (slot) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CohabiColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      color: CohabiColors.turquoise,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_date(slot)} · ${_time(slot)}',
                        style: const TextStyle(
                          color: CohabiColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _slots.remove(slot)),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: CohabiColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saving ? null : _send,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: const Text('Enviar propuesta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CohabiColors.turquoise,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
