import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';

class OwnerAvailabilitySheet extends StatefulWidget {
  const OwnerAvailabilitySheet({
    super.key,
  });

  @override
  State<OwnerAvailabilitySheet> createState() =>
      _OwnerAvailabilitySheetState();
}

class _OwnerAvailabilitySheetState
    extends State<OwnerAvailabilitySheet> {
  // ============================================================
  // CALENDARIO
  // ============================================================

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  final Set<DateTime> _selectedDays = {
    DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ),
  };

  // Días que tienen disponibilidad guardada.
  final Set<DateTime> _savedDays = {};

  // Slots concretos guardados por día.
  //
  // Ejemplo:
  // 26/08/2026:
  // 09:00-09:30
  // 09:30-10:00
  final Map<DateTime, Set<String>> _savedSlotsByDay = {};

  // Últimos días que acabamos de guardar.
  // Sirve para dejar el horario visualmente en verde
  // justo después del guardado.
  final Set<DateTime> _lastSavedDays = {};

  // ============================================================
  // RANGOS
  // ============================================================

  final List<_AvailabilityRange> _ranges = [
    _AvailabilityRange(
      startMinutes: 9 * 60,
      endMinutes: 12 * 60,
    ),
  ];

  String? _saveError;
  bool _isSaving = false;
  bool _savedSuccessfully = false;

  @override
  void initState() {
    super.initState();

    _loadSavedAvailability();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFF),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHandle(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    _buildCalendarCard(),

                    const SizedBox(height: 16),

                    _buildAvailabilityCard(),

                    const SizedBox(height: 16),

                    _buildInfoCard(),

                    const SizedBox(height: 20),

                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HANDLE
  // ============================================================

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 8,
      ),
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFDADDEA),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  // ============================================================
  // CABECERA
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CohabiColors.purple.withValues(
                  alpha: 0.16,
                ),
                CohabiColors.turquoise.withValues(
                  alpha: 0.10,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: CohabiColors.purple,
            size: 29,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi disponibilidad',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Selecciona uno o varios días y dinos '
                    'entre qué horas puedes recibir visitas.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        InkWell(
          onTap: () {
            Navigator.of(context).pop(false);
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: CohabiColors.border,
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: CohabiColors.navy,
              size: 23,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CALENDARIO
  // ============================================================

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        16,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: CohabiColors.purple,
                ),
              ),

              Expanded(
                child: Text(
                  _monthTitle(_visibleMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: CohabiColors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              _WeekLabel('LUN'),
              _WeekLabel('MAR'),
              _WeekLabel('MIÉ'),
              _WeekLabel('JUE'),
              _WeekLabel('VIE'),
              _WeekLabel('SÁB'),
              _WeekLabel('DOM'),
            ],
          ),

          const SizedBox(height: 10),

          _buildCalendarGrid(),

          const SizedBox(height: 14),

          const Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _LegendItem(
                color: CohabiColors.purple,
                label: 'Seleccionado',
              ),

              _LegendItem(
                color: CohabiColors.turquoise,
                label: 'Hoy',
              ),

              _LegendItem(
                color: Color(0xFFE3F8F3),
                label: 'Guardado',
                borderColor: Color(0xFF19B89F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    final leadingEmptyDays =
        firstDay.weekday - 1;

    final totalCells =
        leadingEmptyDays + daysInMonth;

    final rows =
    (totalCells / 7).ceil();

    return Column(
      children: List.generate(
        rows,
            (rowIndex) {
          return Row(
            children: List.generate(
              7,
                  (columnIndex) {
                final cellIndex =
                    (rowIndex * 7) +
                        columnIndex;

                final dayNumber =
                    cellIndex -
                        leadingEmptyDays +
                        1;

                if (dayNumber < 1 ||
                    dayNumber > daysInMonth) {
                  return const Expanded(
                    child: SizedBox(
                      height: 46,
                    ),
                  );
                }

                final date = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  dayNumber,
                );

                return Expanded(
                  child: _buildDay(date),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDay(DateTime date) {
    final cleanDate =
    _cleanDate(date);

    final today =
    _cleanDate(
      DateTime.now(),
    );

    final isPast =
    cleanDate.isBefore(today);

    final selected =
    _containsDate(
      _selectedDays,
      cleanDate,
    );

    final isToday =
    _sameDay(
      cleanDate,
      today,
    );

    final isSaved =
    _containsDate(
      _savedDays,
      cleanDate,
    );

    Color background =
        Colors.transparent;

    Color textColor =
    isPast
        ? const Color(0xFFBFC4D5)
        : CohabiColors.navy;
    BoxBorder? border;

// ==========================================================
// GUARDADO -> VERDE
// ==========================================================

    if (isSaved && !selected) {
      background = const Color(0xFF19B89F);
      textColor = Colors.white;

      border = isToday
          ? Border.all(
        color: CohabiColors.turquoise,
        width: 2,
      )
          : null;
    }

// ==========================================================
// HOY, PERO TODAVÍA NO GUARDADO -> TURQUESA
// ==========================================================

    else if (isToday && !selected) {
      background = CohabiColors.turquoise;
      textColor = Colors.white;
      border = null;
    }

// ==========================================================
// SELECCIONANDO AHORA -> MORADO
// ==========================================================

    if (selected) {
      background = CohabiColors.purple;
      textColor = Colors.white;

      border = isToday
          ? Border.all(
        color: CohabiColors.turquoise,
        width: 2,
      )
          : null;
    }

    return InkWell(
      onTap: isPast
          ? null
          : () {
        setState(() {
          _savedSuccessfully =
          false;

          _lastSavedDays.clear();

          final alreadySelected =
          _containsDate(
            _selectedDays,
            cleanDate,
          );

          if (alreadySelected) {
            _selectedDays
                .removeWhere(
                  (item) =>
                  _sameDay(
                    item,
                    cleanDate,
                  ),
            );
          } else {
            _selectedDays.add(
              cleanDate,
            );
          }
        });
      },
      borderRadius:
      BorderRadius.circular(11),
      child: Container(
        height: 42,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius:
          BorderRadius.circular(11),
          border: border,
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight:
            selected ||
                isToday ||
                isSaved
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPONIBILIDAD
  // ============================================================

  Widget _buildAvailabilityCard() {
    final selectedCount =
        _selectedDays.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedCount == 0
                      ? _savedSuccessfully
                      ? 'Disponibilidad guardada'
                      : 'Selecciona uno o varios días'
                      : selectedCount == 1
                      ? '1 día seleccionado'
                      : '$selectedCount días seleccionados',
                  style: TextStyle(
                    color:
                    _savedSuccessfully &&
                        selectedCount == 0
                        ? const Color(
                      0xFF078E80,
                    )
                        : CohabiColors.navy,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              if (_selectedDays.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDays.clear();

                      _savedSuccessfully =
                      false;

                      _lastSavedDays.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color:
                    Color(0xFFFF6674),
                  ),
                  label: const Text(
                    'Limpiar',
                    style: TextStyle(
                      color:
                      Color(0xFFFF6674),
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            _savedSuccessfully &&
                selectedCount == 0
                ? 'Los días y horarios en verde ya están configurados.'
                : 'Estas horas se aplicarán a todos los días seleccionados.',
            style: const TextStyle(
              color:
              CohabiColors.textSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          ...List.generate(
            _ranges.length,
                (index) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 11,
                ),
                child:
                _buildRangeRow(
                  index,
                ),
              );
            },
          ),

          const SizedBox(height: 2),

          OutlinedButton.icon(
            onPressed: () {
              _markAsEdited();
              _addRange();
            },
            icon: const Icon(
              Icons.add_rounded,
              size: 20,
            ),
            label: const Text(
              'Añadir otro horario',
            ),
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              CohabiColors.purple,
              side: BorderSide(
                color:
                CohabiColors.purple
                    .withValues(
                  alpha: 0.45,
                ),
              ),
              minimumSize:
              const Size.fromHeight(
                48,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              textStyle:
              const TextStyle(
                fontWeight:
                FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeRow(
      int index,
      ) {
    final range =
    _ranges[index];

    final isSaved =
    _rangeIsSaved(
      range,
    );

    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 220,
      ),
      padding:
      const EdgeInsets.fromLTRB(
        12,
        12,
        8,
        12,
      ),
      decoration: BoxDecoration(
        color: isSaved
            ? const Color(
          0xFFE8FAF6,
        )
            : const Color(
          0xFFF9F7FF,
        ),
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: isSaved
              ? const Color(
            0xFF19B89F,
          ).withValues(
            alpha: 0.55,
          )
              : CohabiColors.purple
              .withValues(
            alpha: 0.12,
          ),
          width:
          isSaved ? 1.3 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isSaved)
            const Padding(
              padding:
              EdgeInsets.only(
                left: 2,
                right: 5,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                    Color(0xFF19B89F),
                    size: 17,
                  ),

                  SizedBox(width: 6),

                  Text(
                    'Horario guardado',
                    style: TextStyle(
                      color:
                      Color(0xFF078E80),
                      fontSize: 10.5,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child:
                _buildTimeButton(
                  title: 'Desde',
                  minutes:
                  range.startMinutes,
                  saved: isSaved,
                  onTap: () async {
                    final selected =
                    await _pickTime(
                      initialMinutes:
                      range.startMinutes,
                      maximumMinutes:
                      range.endMinutes -
                          30,
                    );

                    if (selected ==
                        null) {
                      return;
                    }

                    setState(() {
                      _markAsEdited();

                      range.startMinutes =
                          selected;

                      if (range.endMinutes <=
                          range.startMinutes) {
                        range.endMinutes =
                            range.startMinutes +
                                30;
                      }
                    });
                  },
                ),
              ),

              const Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Icon(
                  Icons
                      .arrow_forward_rounded,
                  color: CohabiColors
                      .textSecondary,
                  size: 18,
                ),
              ),

              Expanded(
                child:
                _buildTimeButton(
                  title: 'Hasta',
                  minutes:
                  range.endMinutes,
                  saved: isSaved,
                  onTap: () async {
                    final selected =
                    await _pickTime(
                      initialMinutes:
                      range.endMinutes,
                      minimumMinutes:
                      range.startMinutes +
                          30,
                    );

                    if (selected ==
                        null) {
                      return;
                    }

                    setState(() {
                      _markAsEdited();

                      range.endMinutes =
                          selected;
                    });
                  },
                ),
              ),

              const SizedBox(width: 4),

              if (_ranges.length > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _markAsEdited();

                      _ranges.removeAt(
                        index,
                      );
                    });
                  },
                  tooltip:
                  'Eliminar horario',
                  icon: const Icon(
                    Icons
                        .delete_outline_rounded,
                    color:
                    Color(0xFFFF6674),
                    size: 21,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required String title,
    required int minutes,
    required VoidCallback onTap,
    required bool saved,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: saved
              ? const Color(
            0xFFF3FCF9,
          )
              : Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: saved
                ? const Color(
              0xFF19B89F,
            ).withValues(
              alpha: 0.35,
            )
                : CohabiColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: saved
                    ? const Color(
                  0xFF078E80,
                )
                    : CohabiColors
                    .textSecondary,
                fontSize: 9.5,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(height: 3),

            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: saved
                      ? const Color(
                    0xFF19B89F,
                  )
                      : CohabiColors
                      .purple,
                  size: 16,
                ),

                const SizedBox(width: 5),

                Text(
                  _formatMinutes(
                    minutes,
                  ),
                  style: TextStyle(
                    color: saved
                        ? const Color(
                      0xFF078E80,
                    )
                        : CohabiColors
                        .navy,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECTOR DE HORA
  // ============================================================

  Future<int?> _pickTime({
    required int initialMinutes,
    int minimumMinutes = 8 * 60,
    int maximumMinutes = 22 * 60,
  }) {
    final options =
    <int>[];

    for (
    int minutes = 8 * 60;
    minutes <= 22 * 60;
    minutes += 30
    ) {
      if (minutes >=
          minimumMinutes &&
          minutes <=
              maximumMinutes) {
        options.add(minutes);
      }
    }

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor:
      Colors.transparent,
      builder: (
          pickerContext,
          ) {
        return Container(
          constraints:
          const BoxConstraints(
            maxHeight: 520,
          ),
          decoration:
          const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(
              top:
              Radius.circular(26),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),

                Container(
                  width: 42,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color: const Color(
                      0xFFDADDEA,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      999,
                    ),
                  ),
                ),

                const Padding(
                  padding:
                  EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    10,
                  ),
                  child: Text(
                    'Selecciona una hora',
                    style: TextStyle(
                      color:
                      CohabiColors
                          .navy,
                      fontSize: 18,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),
                ),

                Flexible(
                  child:
                  ListView.separated(
                    shrinkWrap: true,
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      18,
                      4,
                      18,
                      20,
                    ),
                    itemCount:
                    options.length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 6,
                    ),
                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final minutes =
                      options[index];

                      final selected =
                          minutes ==
                              initialMinutes;

                      return InkWell(
                        onTap: () {
                          Navigator.of(
                            pickerContext,
                          ).pop(
                            minutes,
                          );
                        },
                        borderRadius:
                        BorderRadius
                            .circular(
                          13,
                        ),
                        child:
                        Container(
                          height: 48,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal:
                            16,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            selected
                                ? const Color(
                              0xFFF1ECFF,
                            )
                                : const Color(
                              0xFFFAFBFF,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              13,
                            ),
                            border:
                            Border.all(
                              color: selected
                                  ? CohabiColors
                                  .purple
                                  .withValues(
                                alpha:
                                0.25,
                              )
                                  : CohabiColors
                                  .border,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .schedule_rounded,
                                color:
                                CohabiColors
                                    .purple,
                                size: 19,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Text(
                                _formatMinutes(
                                  minutes,
                                ),
                                style:
                                const TextStyle(
                                  color:
                                  CohabiColors
                                      .navy,
                                  fontSize:
                                  15,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),

                              const Spacer(),

                              if (selected)
                                const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color:
                                  CohabiColors
                                      .turquoise,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            const BoxDecoration(
              color:
              Color(0xFFF2EDFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color:
              CohabiColors.purple,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Cohabi creará citas cada 30 minutos',
                  style: TextStyle(
                    color:
                    CohabiColors
                        .navy,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Si indicas que estás libre de 17:00 a 19:00, '
                      'el candidato podrá elegir 17:00, 17:30, '
                      '18:00 o 18:30.',
                  style: TextStyle(
                    color:
                    CohabiColors
                        .textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTONES INFERIORES
  // ============================================================

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
            _isSaving
                ? null
                : () {
              Navigator.of(
                context,
              ).pop(
                false,
              );
            },
            style:
            OutlinedButton.styleFrom(
              minimumSize:
              const Size.fromHeight(
                52,
              ),
              foregroundColor:
              CohabiColors.navy,
              side: BorderSide(
                color:
                CohabiColors.border,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 220,
            ),
            height: 52,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                15,
              ),
              gradient:
              _savedSuccessfully
                  ? const LinearGradient(
                colors: [
                  Color(
                    0xFF1BBFA6,
                  ),
                  Color(
                    0xFF0BAA93,
                  ),
                ],
              )
                  : const LinearGradient(
                colors: [
                  CohabiColors
                      .purple,
                  Color(
                    0xFF347FF4,
                  ),
                  CohabiColors
                      .turquoise,
                ],
              ),
            ),
            child: Material(
              color:
              Colors.transparent,
              child: InkWell(
                onTap: _isSaving
                    ? null
                    : _saveAvailability,
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                    width: 21,
                    height: 21,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2.4,
                      color:
                      Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      Icon(
                        _savedSuccessfully
                            ? Icons
                            .check_circle_rounded
                            : Icons
                            .check_rounded,
                        color:
                        Colors.white,
                        size: 19,
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      Text(
                        _savedSuccessfully
                            ? 'Disponibilidad guardada'
                            : 'Guardar disponibilidad',
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          12.5,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AÑADIR HORARIO
  // ============================================================

  void _addRange() {
    final last =
        _ranges.last;

    int newStart =
        last.endMinutes + 30;

    if (newStart >=
        22 * 60) {
      newStart =
          17 * 60;
    }

    int newEnd =
        newStart + (2 * 60);

    if (newEnd >
        22 * 60) {
      newEnd =
          22 * 60;
    }

    if (newEnd <=
        newStart) {
      newEnd =
          newStart + 30;
    }

    setState(() {
      _ranges.add(
        _AvailabilityRange(
          startMinutes:
          newStart,
          endMinutes:
          newEnd,
        ),
      );
    });
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> _saveAvailability() async {
    if (_isSaving) return;

    if (_selectedDays.isEmpty) {
      await _showResultDialog(
        success: false,
        message: 'Selecciona al menos un día.',
      );
      return;
    }

    if (_ranges.isEmpty) {
      await _showResultDialog(
        success: false,
        message: 'Añade al menos un horario.',
      );
      return;
    }

    for (final range in _ranges) {
      if (range.endMinutes <= range.startMinutes) {
        await _showResultDialog(
          success: false,
          message:
          'La hora final debe ser posterior a la hora de inicio.',
        );
        return;
      }

      if ((range.endMinutes - range.startMinutes) < 30) {
        await _showResultDialog(
          success: false,
          message:
          'Cada horario debe durar al menos 30 minutos.',
        );
        return;
      }
    }

    if (_rangesOverlap()) {
      await _showResultDialog(
        success: false,
        message:
        'Hay horarios que se solapan. Revísalos antes de guardar.',
      );
      return;
    }

    // Copiamos los días ANTES de tocar el estado visual.
    final daysToSave = _selectedDays
        .map(
          (day) => DateTime(
        day.year,
        day.month,
        day.day,
      ),
    )
        .toSet();

    setState(() {
      _isSaving = true;
      _savedSuccessfully = false;
      _saveError = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'No hay ningún propietario autenticado.',
        );
      }

      final rows = <Map<String, dynamic>>[];

      final visualSlots =
      <DateTime, Set<String>>{};

      // ==========================================================
      // GENERAMOS LOS SLOTS REALES DE 30 MINUTOS
      // ==========================================================

      for (final day in daysToSave) {
        visualSlots[day] = <String>{};

        for (final range in _ranges) {
          for (
          int minutes = range.startMinutes;
          minutes + 30 <= range.endMinutes;
          minutes += 30
          ) {
            final startAt = DateTime(
              day.year,
              day.month,
              day.day,
              minutes ~/ 60,
              minutes % 60,
            );

            final endAt = startAt.add(
              const Duration(minutes: 30),
            );

            rows.add({
              'owner_id': user.id,
              'start_at':
              startAt.toUtc().toIso8601String(),
              'end_at':
              endAt.toUtc().toIso8601String(),
              'is_available': true,
            });

            visualSlots[day]!.add(
              '${_formatMinutes(minutes)}-'
                  '${_formatMinutes(minutes + 30)}',
            );
          }
        }
      }

      if (rows.isEmpty) {
        throw Exception(
          'No se han podido generar horarios.',
        );
      }

      // ==========================================================
      // BORRAMOS LA DISPONIBILIDAD LIBRE ANTERIOR
      // DE LOS DÍAS QUE ESTAMOS EDITANDO
      // ==========================================================

      for (final day in daysToSave) {
        final dayStart = DateTime(
          day.year,
          day.month,
          day.day,
        );

        final nextDay = dayStart.add(
          const Duration(days: 1),
        );

        await supabase
            .from('owner_availability_slots')
            .delete()
            .eq('owner_id', user.id)
            .eq('is_available', true)
            .gte(
          'start_at',
          dayStart.toUtc().toIso8601String(),
        )
            .lt(
          'start_at',
          nextDay.toUtc().toIso8601String(),
        );
      }

      // ==========================================================
      // GUARDAMOS
      // ==========================================================

      await supabase
          .from('owner_availability_slots')
          .upsert(
        rows,
        onConflict:
        'owner_id,start_at,end_at',
      );

      if (!mounted) return;

      // ==========================================================
      // ÉXITO:
      // MORADO -> VERDE
      // ==========================================================

      setState(() {
        _isSaving = false;
        _savedSuccessfully = true;

        for (final day in daysToSave) {
          final cleanDay = _cleanDate(day);

          _savedDays.add(cleanDay);

          _savedSlotsByDay[cleanDay] =
          Set<String>.from(
            visualSlots[day] ?? <String>{},
          );
        }

        _lastSavedDays
          ..clear()
          ..addAll(daysToSave);

        // CLAVE:
        // ya no están siendo editados.
        _selectedDays.clear();
      });

      // Confirmación visible dentro del propio calendario.
      await _showResultDialog(
        success: true,
        message:
        daysToSave.length == 1
            ? 'Disponibilidad guardada correctamente.'
            : 'Disponibilidad guardada correctamente para '
            '${daysToSave.length} días.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _savedSuccessfully = false;
      });

      debugPrint(
        'ERROR GUARDANDO DISPONIBILIDAD: $error',
      );

      await _showResultDialog(
        success: false,
        message:
        'No se pudo guardar la disponibilidad.\n\n$error',
      );
    }
  }
  // ============================================================
  // CARGAR DISPONIBILIDAD YA GUARDADA
  // ============================================================

  Future<void>
  _loadSavedAvailability() async {
    try {
      final supabase =
          Supabase.instance
              .client;

      final user =
          supabase
              .auth
              .currentUser;

      if (user == null) {
        return;
      }

      final now =
      DateTime.now();

      final response =
      await supabase
          .from(
        'owner_availability_slots',
      )
          .select(
        'start_at,end_at,is_available',
      )
          .eq(
        'owner_id',
        user.id,
      )
          .eq(
        'is_available',
        true,
      )
          .gte(
        'start_at',
        DateTime(
          now.year,
          now.month,
          now.day,
        )
            .toUtc()
            .toIso8601String(),
      )
          .order(
        'start_at',
        ascending:
        true,
      );

      final data =
      List<Map<String, dynamic>>
          .from(
        response,
      );

      final loadedDays =
      <DateTime>{};

      final loadedSlots =
      <DateTime, Set<String>>{};

      for (final row
      in data) {
        final startValue =
        row['start_at'];

        final endValue =
        row['end_at'];

        if (startValue == null ||
            endValue == null) {
          continue;
        }

        final start =
        DateTime.parse(
          startValue.toString(),
        ).toLocal();

        final end =
        DateTime.parse(
          endValue.toString(),
        ).toLocal();

        final day =
        _cleanDate(
          start,
        );

        loadedDays.add(
          day,
        );

        loadedSlots.putIfAbsent(
          day,
              () => <String>{},
        );

        final startMinutes =
            start.hour * 60 +
                start.minute;

        final endMinutes =
            end.hour * 60 +
                end.minute;

        loadedSlots[day]!.add(
          '${_formatMinutes(startMinutes)}-'
              '${_formatMinutes(endMinutes)}',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _savedDays
          ..clear()
          ..addAll(
            loadedDays,
          );

        _savedSlotsByDay
          ..clear()
          ..addAll(
            loadedSlots,
          );
      });
    } catch (error) {
      debugPrint(
        'Error cargando disponibilidad: $error',
      );
    }
  }

  // ============================================================
  // COMPROBAR SI UN RANGO YA ESTÁ GUARDADO
  // ============================================================

  bool _rangeIsSaved(
      _AvailabilityRange range,
      ) {
    Set<DateTime> daysToCheck;

    // Si está seleccionando días, comprobamos esos días.
    if (_selectedDays.isNotEmpty) {
      daysToCheck =
          _selectedDays;
    }
    // Justo después de guardar, comprobamos los últimos guardados.
    else if (_lastSavedDays.isNotEmpty) {
      daysToCheck =
          _lastSavedDays;
    } else {
      return false;
    }

    for (final day
    in daysToCheck) {
      final cleanDay =
      _cleanDate(day);

      final savedSlots =
      _savedSlotsByDay[
      cleanDay
      ];

      if (savedSlots == null) {
        return false;
      }

      for (
      int minutes =
          range.startMinutes;
      minutes + 30 <=
          range.endMinutes;
      minutes += 30
      ) {
        final signature =
            '${_formatMinutes(minutes)}-'
            '${_formatMinutes(minutes + 30)}';

        if (!savedSlots.contains(
          signature,
        )) {
          return false;
        }
      }
    }

    return true;
  }

  // ============================================================
  // MARCAR EDICIÓN
  // ============================================================

  void _markAsEdited() {
    _savedSuccessfully =
    false;

    _lastSavedDays.clear();
  }

  // ============================================================
  // MESES
  // ============================================================

  void _previousMonth() {
    final now =
    DateTime.now();

    final previous =
    DateTime(
      _visibleMonth.year,
      _visibleMonth.month - 1,
    );

    final currentMonth =
    DateTime(
      now.year,
      now.month,
    );

    if (previous.isBefore(
      currentMonth,
    )) {
      return;
    }

    setState(() {
      _visibleMonth =
          previous;
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth =
          DateTime(
            _visibleMonth.year,
            _visibleMonth.month + 1,
          );
    });
  }

  // ============================================================
  // VALIDACIÓN
  // ============================================================

  bool _rangesOverlap() {
    final sorted =
    [..._ranges]
      ..sort(
            (a, b) =>
            a.startMinutes
                .compareTo(
              b.startMinutes,
            ),
      );

    for (
    int i = 0;
    i <
        sorted.length - 1;
    i++
    ) {
      if (sorted[i]
          .endMinutes >
          sorted[i + 1]
              .startMinutes) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  BoxDecoration
  _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(
        20,
      ),
      border: Border.all(
        color:
        CohabiColors.border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black
              .withValues(
            alpha: 0.025,
          ),
          blurRadius: 16,
          offset:
          const Offset(
            0,
            6,
          ),
        ),
      ],
    );
  }

  DateTime _cleanDate(
      DateTime date,
      ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _sameDay(
      DateTime first,
      DateTime second,
      ) {
    return first.year ==
        second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

  bool _containsDate(
      Set<DateTime> dates,
      DateTime target,
      ) {
    return dates.any(
          (item) =>
          _sameDay(
            item,
            target,
          ),
    );
  }

  String _formatMinutes(
      int totalMinutes,
      ) {
    final hours =
        totalMinutes ~/ 60;

    final minutes =
        totalMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }

  String _monthTitle(
      DateTime date,
      ) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${months[date.month - 1]} '
        '${date.year}';
  }
  Future<void> _showResultDialog({
    required bool success,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: success
                      ? const Color(0xFFE3F8F3)
                      : const Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success
                      ? Icons.check_rounded
                      : Icons.error_outline_rounded,
                  color: success
                      ? const Color(0xFF078E80)
                      : const Color(0xFFE5484D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? '¡Todo listo!'
                      : 'No se ha podido guardar',
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                success ? 'Perfecto' : 'Entendido',
                style: TextStyle(
                  color: success
                      ? const Color(0xFF078E80)
                      : CohabiColors.purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
          behavior:
          SnackBarBehavior
              .floating,
        ),
      );
  }
}

// ============================================================
// MODELO DE RANGO HORARIO
// ============================================================

class _AvailabilityRange {
  int startMinutes;
  int endMinutes;

  _AvailabilityRange({
    required this.startMinutes,
    required this.endMinutes,
  });
}

// ============================================================
// DÍAS SEMANA
// ============================================================

class _WeekLabel
    extends StatelessWidget {
  final String text;

  const _WeekLabel(
      this.text,
      );

  @override
  Widget build(
      BuildContext context,
      ) {
    return Expanded(
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          color: CohabiColors
              .textSecondary,
          fontSize: 9.5,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================
// LEYENDA
// ============================================================

class _LegendItem
    extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration:
          BoxDecoration(
            color: color,
            borderRadius:
            BorderRadius.circular(
              5,
            ),
            border:
            borderColor ==
                null
                ? null
                : Border.all(
              color:
              borderColor!,
            ),
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          label,
          style:
          const TextStyle(
            color: CohabiColors
                .textSecondary,
            fontSize: 10,
            fontWeight:
            FontWeight.w500,
          ),
        ),
      ],
    );
  }
}