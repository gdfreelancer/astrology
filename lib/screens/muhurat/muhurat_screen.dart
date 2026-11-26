import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../models/panchang_data.dart';
import '../../services/muhurat_service.dart';

class MuhuratScreen extends StatefulWidget {
  const MuhuratScreen({super.key});
  @override
  State<MuhuratScreen> createState() => _MuhuratScreenState();
}

class _MuhuratScreenState extends State<MuhuratScreen> {
  static const _activities = <_MuhuratActivity>[
    _MuhuratActivity('💍', 'activity_marriage', 'activity_marriage_desc'),
    _MuhuratActivity('🏡', 'activity_griha_pravesh', 'activity_griha_pravesh_desc'),
    _MuhuratActivity('🚗', 'activity_vehicle', 'activity_vehicle_desc'),
    _MuhuratActivity('🏪', 'activity_business', 'activity_business_desc'),
    _MuhuratActivity('🍼', 'activity_naming', 'activity_naming_desc'),
    _MuhuratActivity('🏠', 'activity_property', 'activity_property_desc'),
    _MuhuratActivity('🧳', 'activity_journey', 'activity_journey_desc'),
    _MuhuratActivity('📚', 'activity_learning', 'activity_learning_desc'),
  ];

  int _selectedActivity = 0;
  late int _selectedYear;
  final _placeController = TextEditingController();
  PanchangLocation? _location;
  List<MuhuratCandidate> _candidates = const [];
  bool _loadingLocation = true;
  bool _calculating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    timezone_data.initializeTimeZones();
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    try {
      final saved = await AppPreferencesService.defaultLocation();
      if (!mounted) return;
      setState(() {
        _location = PanchangLocation(name: saved.name, latitude: saved.latitude, longitude: saved.longitude, timeZoneId: saved.timeZoneId);
        _placeController.text = saved.name;
        _loadingLocation = false;
      });
      await _loadDates();
    } catch (error) {
      if (!mounted) return;
      setState(() { _loadingLocation = false; _error = error.toString(); });
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _loadDates() async {
    final location = _location;
    if (location == null || _calculating) return;
    setState(() { _calculating = true; _error = null; _candidates = const []; });
    try {
      final now = DateTime.now();
      final dates = await MuhuratService.findDates(
        from: DateTime(now.year, now.month, now.day),
        through: DateTime(_selectedYear + 1, 12, 31),
        location: location,
        activityKey: _activities[_selectedActivity].title,
      );
      if (!mounted) return;
      setState(() => _candidates = dates);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  void _selectActivity(int index) {
    if (_selectedActivity == index) return;
    setState(() => _selectedActivity = index);
    _loadDates();
  }

  void _selectYear(int year) {
    if (_selectedYear != year) setState(() => _selectedYear = year);
  }

  String _time(DateTime value) {
    final location = _location;
    if (location == null) return '';
    final local = tz.TZDateTime.from(value, tz.getLocation(location.timeZoneId));
    final minute = local.minute.toString().padLeft(2, '0');
    if (AppPreferencesService.cachedUse24HourTime) return '${local.hour.toString().padLeft(2, '0')}:$minute';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _weekday(int index) => context.tr([
    'weekday_sunday', 'weekday_monday', 'weekday_tuesday', 'weekday_wednesday',
    'weekday_thursday', 'weekday_friday', 'weekday_saturday',
  ][index]);

  String _month(int month) => AppLocale.text('month_$month');

  @override
  Widget build(BuildContext context) {
    final yearDates = _candidates.where((item) => item.date.year == _selectedYear).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('muhurat'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        _hero(),
        const SizedBox(height: 22),
        Text(context.tr('muhurat_question'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 4),
        Text(context.tr('choose_activity_help'), style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
        const SizedBox(height: 13),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _activities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.42),
          itemBuilder: (context, index) {
            final item = _activities[index]; final selected = index == _selectedActivity;
            return Material(
              color: selected ? const Color(0xFFF2EDF9) : Colors.white,
              borderRadius: BorderRadius.circular(17),
              child: InkWell(
                onTap: () => _selectActivity(index), borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? AppTheme.plum : const Color(0xFFEDE7E1), width: selected ? 1.4 : 1)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(children: [Text(item.emoji, style: const TextStyle(fontSize: 23)), const Spacer(), if (selected) const Icon(Icons.check_circle_rounded, color: AppTheme.plum, size: 17)]),
                    const SizedBox(height: 8),
                    Text(context.tr(item.title), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    const SizedBox(height: 3),
                    Text(context.tr(item.subtitle), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, height: 1.35, color: AppTheme.muted)),
                  ]),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        Text(context.tr('muhurat_dates_for'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 5),
        Text(context.tr('muhurat_years_description'), style: const TextStyle(fontSize: 10, height: 1.45, color: AppTheme.muted)),
        const SizedBox(height: 12),
        TextField(
          controller: _placeController, readOnly: true,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('muhurat_location_settings_hint')))),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.plum, size: 20),
            hintText: context.tr('event_location'), filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEDE7E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEDE7E1))),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          for (final year in [_selectedYear, _selectedYear + 1])
            Padding(padding: const EdgeInsets.only(right: 9), child: ChoiceChip(
              label: Text('$year'), selected: _selectedYear == year, onSelected: (_) => _selectYear(year),
              selectedColor: const Color(0xFFF2EDF9),
              labelStyle: TextStyle(color: _selectedYear == year ? AppTheme.plum : AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 12),
              side: BorderSide(color: _selectedYear == year ? AppTheme.plum : const Color(0xFFEDE7E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )),
          const Spacer(),
          if (!_calculating && !_loadingLocation) IconButton(onPressed: _loadDates, icon: const Icon(Icons.refresh_rounded, color: AppTheme.plum)),
        ]),
        const SizedBox(height: 5),
        if (_loadingLocation || _calculating) _loadingCard()
        else if (_error != null) _errorCard()
        else if (yearDates.isEmpty) _emptyCard()
        else ...[
          Row(children: [
            Text(context.tr('muhurat_candidate_days'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const Spacer(),
            Text('${yearDates.length} ${context.tr('dates_found')}', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          ]),
          const SizedBox(height: 10),
          for (final candidate in yearDates) _candidateCard(candidate),
        ],
        const SizedBox(height: 12),
        _disclaimer(),
        const SizedBox(height: 18),
        _howItWorks(),
      ])),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF526F8E), Color(0xFF344C6A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(23)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('auspicious_moments'), style: const TextStyle(color: Color(0xFFDCE8F5), fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(context.tr('muhurat_annual_title'), style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.2, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(context.tr('muhurat_annual_subtitle'), style: const TextStyle(color: Color(0xFFDCE8F5), fontSize: 10)),
      ])),
      const SizedBox(width: 12), const Text('🕉️', style: TextStyle(fontSize: 48)),
    ]),
  );

  Widget _loadingCard() => Container(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: Column(children: [
      const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.plum)),
      const SizedBox(height: 12),
      Text(context.tr('calculating_annual_muhurat'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ink)),
      const SizedBox(height: 4),
      Text(context.tr('muhurat_scan_wait'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
    ]),
  );

  Widget _errorCard() => Container(
    padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(14)),
    child: Text('${context.tr('muhurat_calculation_error')} $_error', style: const TextStyle(fontSize: 10, color: Color(0xFF9B3F3F))),
  );

  Widget _emptyCard() => Container(
    padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: Column(children: [
      const Icon(Icons.event_busy_rounded, size: 27, color: AppTheme.muted), const SizedBox(height: 8),
      Text(context.tr('no_muhurat_dates'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 4),
      Text(context.tr('no_muhurat_dates_hint'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, height: 1.4, color: AppTheme.muted)),
    ]),
  );

  Widget _candidateCard(MuhuratCandidate candidate) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE5EF))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 43, height: 43, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFF2EDF9), borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${candidate.date.day}', style: const TextStyle(fontSize: 17, height: 1, fontWeight: FontWeight.w900, color: AppTheme.plum)),
            const SizedBox(height: 3),
            Text(_month(candidate.date.month).substring(0, 3), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.plum)),
          ]),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_weekday(candidate.weekdayIndex)}, ${candidate.date.day} ${_month(candidate.date.month)} ${candidate.date.year}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          const SizedBox(height: 4),
          Text('${candidate.tithi} · ${candidate.nakshatra}', style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
        ])),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF43866B), size: 18),
      ]),
      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFF0EBE5))),
      Text(context.tr('available_time_windows'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.plum)),
      const SizedBox(height: 7),
      Wrap(spacing: 7, runSpacing: 7, children: candidate.windows.map((window) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFF7F5FA), borderRadius: BorderRadius.circular(9)),
        child: Text('${window.name}  ${_time(window.start)} – ${_time(window.end)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.ink)),
      )).toList()),
    ]),
  );

  Widget _disclaimer() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFFFF8ED), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF2E6D3))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, color: Color(0xFF9B7041), size: 17), const SizedBox(width: 8),
      Expanded(child: Text(context.tr('muhurat_annual_disclaimer'), style: const TextStyle(fontSize: 9, height: 1.5, color: Color(0xFF806B51)))),
    ]),
  );

  Widget _howItWorks() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF0EBE5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('what_is_considered'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 10),
      _factor('🌙', context.tr('tithi_paksha'), context.tr('muhurat_filter_tithi')),
      _factor('⭐', context.tr('nakshatra_yoga'), context.tr('muhurat_filter_nakshatra')),
      _factor('☀️', context.tr('local_sunrise_weekday'), context.tr('calculated_selected_location')),
      _factor('⏳', context.tr('rahu_other_periods'), context.tr('periods_avoided')),
    ]),
  );

  Widget _factor(String emoji, String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        Text(subtitle, style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
      ])),
    ]),
  );
}

class _MuhuratActivity {
  const _MuhuratActivity(this.emoji, this.title, this.subtitle);
  final String emoji;
  final String title;
  final String subtitle;
}
