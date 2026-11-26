import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

import '../../theme/app_theme.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../models/panchang_data.dart';
import '../../services/panchang_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

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
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  final _placeController = TextEditingController();
  bool _showNotice = false;
  bool _calculating = false;
  PanchangLocation? _location;
  PanchangData? _panchang;
  String? _calculationError;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    final saved = await AppPreferencesService.defaultLocation();
    if (!mounted) return;
    setState(() => _location = PanchangLocation(name: saved.name, latitude: saved.latitude, longitude: saved.longitude, timeZoneId: saved.timeZoneId));
    if (_placeController.text.trim().isEmpty) _placeController.text = saved.name;
  }

  @override
  void dispose() { _placeController.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1))), lastDate: DateTime.now().add(const Duration(days: 730)));
    if (picked != null) setState(() { _selectedDate = DateUtils.dateOnly(picked); _showNotice = false; _panchang = null; _calculationError = null; });
  }

  Future<void> _calculate() async {
    final location = _location;
    if (location == null || _calculating) return;
    setState(() { _calculating = true; _calculationError = null; _panchang = null; _showNotice = true; });
    try {
      final data = await Future<PanchangData>(() => PanchangService.calculate(date: _selectedDate, location: location));
      if (!mounted) return;
      setState(() => _panchang = data);
    } catch (error) {
      if (!mounted) return;
      setState(() => _calculationError = error.toString());
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  String _localTime(DateTime value) {
    final data = _panchang;
    if (data == null) return '';
    final local = tz.TZDateTime.from(value, tz.getLocation(data.location.timeZoneId));
    final minute = local.minute.toString().padLeft(2, '0');
    if (AppPreferencesService.cachedUse24HourTime) return '${local.hour.toString().padLeft(2, '0')}:$minute';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final activity = _activities[_selectedActivity];
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('muhurat'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        _hero(context),
        const SizedBox(height: 22),
        Text(context.tr('muhurat_question'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 4),
        Text(context.tr('choose_activity_help'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
        const SizedBox(height: 13),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _activities.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.42), itemBuilder: (context, index) {
          final item = _activities[index]; final selected = index == _selectedActivity;
          return Material(color: selected ? const Color(0xFFF2EDF9) : Colors.white, borderRadius: BorderRadius.circular(17), child: InkWell(onTap: () => setState(() { _selectedActivity = index; _showNotice = false; }), borderRadius: BorderRadius.circular(17), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? AppTheme.plum : const Color(0xFFEDE7E1), width: selected ? 1.4 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [Text(item.emoji, style: const TextStyle(fontSize: 23)), const Spacer(), if (selected) const Icon(Icons.check_circle_rounded, color: AppTheme.plum, size: 17)]),
            const SizedBox(height: 8), Text(context.tr(item.title), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 3), Text(context.tr(item.subtitle), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, height: 1.35, color: AppTheme.muted)),
          ]))));
        }),
        const SizedBox(height: 22),
        Text(context.tr('preferred_date_place'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 12),
        _dateField(),
        const SizedBox(height: 11),
        TextField(controller: _placeController, textCapitalization: TextCapitalization.words, keyboardType: TextInputType.streetAddress, decoration: InputDecoration(prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.plum, size: 20), hintText: context.tr('event_location'), hintStyle: const TextStyle(fontSize: 11, color: AppTheme.muted), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEDE7E1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEDE7E1))))),
        const SizedBox(height: 16),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: _calculating ? null : _calculate, icon: _calculating ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.auto_awesome_rounded, size: 18), label: Text(context.tr('explore_muhurat'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), style: FilledButton.styleFrom(backgroundColor: AppTheme.plum, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
        if (_showNotice) ...[const SizedBox(height: 16), if (_calculating) const Center(child:CircularProgressIndicator(color:AppTheme.plum)) else if (_calculationError != null) _errorCard() else if (_panchang != null) _calculatedCard(activity)],
        const SizedBox(height: 18), _howItWorks(),
      ])),
    );
  }

  Widget _hero(BuildContext context) => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF526F8E), Color(0xFF344C6A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(23)), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('auspicious_moments'), style: TextStyle(color: Color(0xFFDCE8F5), fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
      SizedBox(height: 8), Text(context.tr('choose_time_tradition'), style: TextStyle(color: Colors.white, fontSize: 20, height: 1.2, fontWeight: FontWeight.w800)),
      SizedBox(height: 6), Text(context.tr('explore_muhurat_guidance'), style: TextStyle(color: Color(0xFFDCE8F5), fontSize: 10)),
    ])), SizedBox(width: 12), Text('🕉️', style: TextStyle(fontSize: 48)),
  ]));

  Widget _dateField() => InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEDE7E1))), child: Row(children: [
    const Icon(Icons.calendar_month_rounded, color: AppTheme.plum, size: 20), const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('selected_date'), style: TextStyle(fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.w800, color: AppTheme.muted)),
      const SizedBox(height: 3), Text(_dateLabel(_selectedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
    ])), const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.muted),
  ])));

  Widget _errorCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(14)),
    child: Text('Could not calculate Panchang for this date and location. $_calculationError', style: const TextStyle(fontSize:10,color:Color(0xFF9B3F3F))),
  );

  Widget _calculatedCard(_MuhuratActivity activity) {
    final data = _panchang!;
    final favourable = <PanchangPeriod>[...data.choghadiyaDay, ...data.choghadiyaNight]
      .where((p) => ['Amrit','Shubh','Labh','Char'].contains(p.name))
      .where((p) => p.end.isBefore(data.rahuKaal.start) || p.start.isAfter(data.rahuKaal.end))
      .toList();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(17),border: Border.all(color: const Color(0xFFEAE5EF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
        Text(context.tr(activity.title),style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800,color:AppTheme.ink)),
        const SizedBox(height:3),
        Text(data.location.name+' · '+_dateLabel(_selectedDate),style:const TextStyle(fontSize:10,color:AppTheme.muted)),
        const Divider(height:18),
        for(final item in data.elements.where((e)=>['Tithi','Nakshatra','Yoga','Karana'].contains(e.name)))
          Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[
            Expanded(child:Text(item.name,style:const TextStyle(fontSize:10,color:AppTheme.muted))),
            Text(item.value,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:AppTheme.ink)),
          ])),
        const Divider(height:18),
        Text('Potentially supportive Choghadiya windows',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppTheme.plum)),
        const SizedBox(height:5),
        if(favourable.isEmpty) const Text('No windows passed this simple screen.',style:TextStyle(fontSize:10,color:AppTheme.muted))
        else for(final period in favourable.take(12))
          Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Row(children:[
            Expanded(child:Text(period.name,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700))),
            Text(_localTime(period.start)+' – '+_localTime(period.end),style:const TextStyle(fontSize:10,color:AppTheme.ink)),
          ])),
        const SizedBox(height:8),
        Text('Rahu Kaal: ${_localTime(data.rahuKaal.start)} – ${_localTime(data.rahuKaal.end)}',style:const TextStyle(fontSize:10,color:Color(0xFF9B5A3D),fontWeight:FontWeight.w700)),
        const SizedBox(height:9),
        const Text('This is a local Panchang and Choghadiya screening, not a complete event-specific Muhurat. Marriage, Griha Pravesh and other ceremonies require additional regional rules, Tara Bala, Chandra Bala, Lagna and family tradition. Verify with a knowledgeable practitioner before fixing an important ceremony.',style:TextStyle(fontSize:9.5,height:1.5,color:AppTheme.muted)),
      ]),
    );
  }


  Widget _howItWorks() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF0EBE5))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(context.tr('what_is_considered'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
    const SizedBox(height: 10),
    _factor('🌙', context.tr('tithi_paksha'), 'Lunar day and waxing / waning phase'),
    _factor('⭐', context.tr('nakshatra_yoga'), context.tr('lunar_mansion_daily_combination')),
    _factor('☀️', context.tr('local_sunrise_weekday'), context.tr('calculated_selected_location')),
    _factor('⏳', context.tr('rahu_other_periods'), context.tr('periods_avoided')),
  ]));

  Widget _factor(String emoji, String title, String subtitle) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      Text(subtitle, style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
    ])),
  ]));
  String _dateLabel(DateTime date) => '${_month(date.month)} ${date.day}, ${date.year}';
  String _month(int month) => AppLocale.text('month_$month');
}

class _MuhuratActivity {
  const _MuhuratActivity(this.emoji, this.title, this.subtitle);
  final String emoji, title, subtitle;
}
