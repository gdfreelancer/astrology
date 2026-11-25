import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_locale.dart';
import '../../models/panchang_data.dart';
import '../../services/panchang_service.dart';
import '../../theme/app_theme.dart';

class LunarEventsScreen extends StatefulWidget {
  const LunarEventsScreen({
    super.key,
    required this.date,
    required this.location,
  });
  final DateTime date;
  final PanchangLocation location;

  @override
  State<LunarEventsScreen> createState() => _LunarEventsScreenState();
}

class _LunarEventsScreenState extends State<LunarEventsScreen> {
  late DateTime _from;
  late List<PanchangLunarEvent> _events;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _from = DateTime(widget.date.year, widget.date.month, widget.date.day);
    _events = PanchangService.upcomingLunarEvents(
      from: _from,
      location: widget.location,
      days: 90,
    );
  }

  List<PanchangLunarEvent> get _visibleEvents => _events.where((event) {
    if (_filter == 'lunar') return event.categoryKey != 'solar_ingress';
    if (_filter == 'solar') return event.categoryKey == 'solar_ingress';
    return true;
  }).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final localNoon = tz.TZDateTime(
      tz.getLocation(widget.location.timeZoneId),
      _from.year, _from.month, _from.day, 12,
    );
    final illumination = PanchangService.lunarIllumination(localNoon);
    final phaseKey = PanchangService.lunarPhaseKey(localNoon);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('lunar_events'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26375D), Color(0xFF55447F)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.nightlight_round, color: Color(0xFFFFE3A8), size: 25),
                const SizedBox(width: 9),
                Expanded(child: Text(context.tr('moon_phase_on_date'),
                  style: const TextStyle(color: Color(0xFFDCD6ED), fontSize: 10))),
              ]),
              const SizedBox(height: 9),
              Text(context.tr(phaseKey),
                style: const TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('${illumination.toStringAsFixed(1)}% ${context.tr('moon_illumination')}',
                style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 12,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: illumination / 100,
                  minHeight: 7,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFDFA0)),
                ),
              ),
              const SizedBox(height: 9),
              Text(widget.location.name,
                style: const TextStyle(color: Color(0xFFDCD6ED), fontSize: 9)),
            ]),
          ),
          const SizedBox(height: 17),
          Text(context.tr('next_90_day_events'),
            style: const TextStyle(color: AppTheme.ink, fontSize: 15,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'all', label: Text(context.tr('event_filter_all'))),
              ButtonSegment(value: 'lunar', label: Text(context.tr('event_filter_lunar'))),
              ButtonSegment(value: 'solar', label: Text(context.tr('event_filter_solar'))),
            ],
            selected: {_filter},
            onSelectionChanged: (value) => setState(() => _filter = value.first),
          ),
          const SizedBox(height: 12),
          if (_visibleEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Text(context.tr('no_lunar_events'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
            ),
          for (final event in _visibleEvents)
            _LunarEventTile(event: event, timeZoneId: widget.location.timeZoneId),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(context.tr('lunar_events_disclaimer'),
              style: const TextStyle(color: Color(0xFF795D36), fontSize: 10,
                height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _LunarEventTile extends StatelessWidget {
  const _LunarEventTile({required this.event, required this.timeZoneId});
  final PanchangLunarEvent event;
  final String timeZoneId;

  @override
  Widget build(BuildContext context) {
    final local = tz.TZDateTime.from(event.time, tz.getLocation(timeZoneId));
    final solar = event.categoryKey == 'solar_ingress';
    final title = context.tr(event.titleKey);
    final detail = event.rashiIndex == null
        ? context.tr(event.detailKey)
        : context.tr(event.detailKey).replaceAll(
            '{rashi}', context.tr(_rashiKeys[event.rashiIndex!]));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE7F0)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 39, height: 42,
          decoration: BoxDecoration(
            color: solar ? const Color(0xFFFFF2E0) : const Color(0xFFF1ECF8),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(solar ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: solar ? const Color(0xFFAA783C) : AppTheme.plum, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 11,
            fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(detail, style: const TextStyle(color: AppTheme.muted, fontSize: 9,
            height: 1.35)),
          const SizedBox(height: 5),
          Text(context.tr(event.categoryKey),
            style: TextStyle(color: solar ? const Color(0xFFAA783C) : AppTheme.plum,
              fontSize: 8, fontWeight: FontWeight.w800)),
        ])),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppTheme.ink, fontSize: 10,
              fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(_time(local), style: const TextStyle(color: AppTheme.muted,
            fontSize: 9, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  static String _time(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    if (AppLocale.text('time_format_24') == 'time_format_24') {
      return '${value.hour.toString().padLeft(2, '0')}:$minute';
    }
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  static const _rashiKeys = [
    'p_mesha','p_vrishabha','p_mithuna','p_karka','p_simha','p_kanya',
    'p_tula','p_vrishchika','p_dhanu','p_makara','p_kumbha','p_meena',
  ];
}
