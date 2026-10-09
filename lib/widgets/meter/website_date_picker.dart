import 'package:flutter/material.dart';

class WebsiteDatePicker extends StatefulWidget {
  final DateTime initialDate, firstDate, lastDate;
  const WebsiteDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });
  @override
  State<WebsiteDatePicker> createState() => _WebsiteDatePickerState();
}

enum _CalendarView { dates, months, years }

class _WebsiteDatePickerState extends State<WebsiteDatePicker> {
  late DateTime _selected, _month;
  var _view = _CalendarView.dates;
  @override
  void initState() {
    super.initState();
    _selected = _clamp(widget.initialDate);
    _month = DateTime(_selected.year, _selected.month);
  }

  DateTime _clamp(DateTime d) => d.isBefore(widget.firstDate)
      ? widget.firstDate
      : d.isAfter(widget.lastDate)
      ? widget.lastDate
      : DateTime(d.year, d.month, d.day);
  bool _allowed(DateTime d) =>
      !d.isBefore(widget.firstDate) && !d.isAfter(widget.lastDate);
  void _yearSelected(int year) {
    final month = _selected.month;
    final day = _selected.day.clamp(1, DateTime(year, month + 1, 0).day);
    setState(() {
      _selected = _clamp(DateTime(year, month, day));
      _month = DateTime(year, month);
      _view = _CalendarView.months;
    });
  }

  void _monthSelected(int month) {
    final day = _selected.day.clamp(1, DateTime(_month.year, month + 1, 0).day);
    setState(() {
      _selected = _clamp(DateTime(_month.year, month, day));
      _month = DateTime(_selected.year, _selected.month);
      _view = _CalendarView.dates;
    });
  }

  void _changeMonth(int amount) {
    final next = DateTime(_month.year, _month.month + amount);
    final first = DateTime(widget.firstDate.year, widget.firstDate.month);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month);
    if (!next.isBefore(first) && !next.isAfter(last)) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              color: c.primary,
              child: Text(
                '${_selected.day.toString().padLeft(2, '0')}-'
                '${_selected.month.toString().padLeft(2, '0')}-'
                '${_selected.year}',
                style: TextStyle(
                  color: c.onPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _header(c),
            if (_view == _CalendarView.dates) _dateGrid(c),
            if (_view == _CalendarView.months) _monthGrid(c),
            if (_view == _CalendarView.years) _yearGrid(c),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, DateTime(1900, 1, 1)),
                    child: const Text('ALL DATES'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ColorScheme c) {
    final title = _view == _CalendarView.years
        ? '${_month.year - 6} - ${_month.year + 5}'
        : '${_monthName(_month.month)} ${_month.year}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(
                () => _view = _view == _CalendarView.years
                    ? _CalendarView.dates
                    : _CalendarView.years,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (_view == _CalendarView.dates) ...[
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateGrid(ColorScheme c) {
    final first = DateTime(_month.year, _month.month, 1);
    final count = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = <Widget>[
      for (final x in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
        Center(
          child: Text(x, style: TextStyle(color: c.onSurfaceVariant)),
        ),
      for (var i = 0; i < first.weekday % 7; i++) const SizedBox.shrink(),
    ];
    for (var day = 1; day <= count; day++) {
      final d = DateTime(_month.year, _month.month, day);
      final selected =
          d.year == _selected.year &&
          d.month == _selected.month &&
          d.day == _selected.day;
      final enabled = _allowed(d);
      cells.add(
        GestureDetector(
          onTap: enabled ? () => setState(() => _selected = d) : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.primary : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: selected
                    ? c.onPrimary
                    : enabled
                    ? c.onSurface
                    : c.onSurface.withValues(alpha: .35),
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: cells,
      ),
    );
  }

  Widget _monthGrid(ColorScheme c) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final m = index + 1;
        final enabled =
            _allowed(DateTime(_month.year, m, 1)) ||
            _allowed(DateTime(_month.year, m + 1, 0));
        final selected = m == _selected.month && _month.year == _selected.year;
        return InkWell(
          onTap: enabled ? () => _monthSelected(m) : null,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? c.primary : null,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _monthName(m, short: true),
                style: TextStyle(
                  color: selected
                      ? c.onPrimary
                      : enabled
                      ? c.onSurface
                      : c.onSurface.withValues(alpha: .35),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  Widget _yearGrid(ColorScheme c) {
    final start = ((_month.year - 6) ~/ 12) * 12;
    return SizedBox(
      height: 230,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        itemCount: 24,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          final y = start + index;
          final enabled =
              y >= widget.firstDate.year && y <= widget.lastDate.year;
          final selected = y == _selected.year;
          return InkWell(
            onTap: enabled ? () => _yearSelected(y) : null,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? c.primary : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '$y',
                  style: TextStyle(
                    color: selected
                        ? c.onPrimary
                        : enabled
                        ? c.onSurface
                        : c.onSurface.withValues(alpha: .35),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _monthName(int month, {bool short = false}) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final n = names[month - 1];
    return short && n.length > 3 ? n.substring(0, 3) : n;
  }
}
