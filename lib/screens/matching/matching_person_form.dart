import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_locale.dart';
import '../../models/birth_chart_result.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../services/birth_chart_service.dart';
import '../../theme/app_theme.dart';

class MatchingPersonForm extends StatefulWidget {
  const MatchingPersonForm({super.key, required this.role, required this.accent});

  final String role;
  final Color accent;

  @override
  State<MatchingPersonForm> createState() => MatchingPersonFormState();
}

class MatchingPersonFormState extends State<MatchingPersonForm>
    with AutomaticKeepAliveClientMixin<MatchingPersonForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _place = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  String? _zone;
  bool _busy = false;
  String? _error;

  String get name => _name.text.trim();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<BirthChartResult?> calculate() async {
    if (!_formKey.currentState!.validate()) return null;
    if (_date == null || _time == null || _zone == null) {
      setState(() => _error = context.tr('birth_time_zone_help'));
      return null;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final places = await Geocoding().locationFromAddress(_place.text.trim());
      if (places.isEmpty) throw StateError('No matching place found');
      final location = places.first;
      final result = BirthChartService.calculate(
        birthDate: _date!,
        hour: _time!.hour,
        minute: _time!.minute,
        timeZoneId: _zone!,
        placeName: _place.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        gender: widget.role,
      );
      return result;
    } catch (_) {
      if (mounted) setState(() => _error = context.tr('place_not_found'));
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: context.tr('date_of_birth'),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: context.tr('exact_time_of_birth'),
      builder: (dialogContext, child) => MediaQuery(
        data: MediaQuery.of(dialogContext).copyWith(alwaysUse24HourFormat: AppPreferencesService.cachedUse24HourTime),
        child: child!,
      ),
    );
    if (value != null) setState(() => _time = value);
  }

  Future<void> _pickZone() async {
    final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _ZoneDialog(zones: zones, selected: _zone),
    );
    if (value != null) setState(() => _zone = value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: widget.accent.withValues(alpha: .28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 39, height: 39, decoration: BoxDecoration(color: widget.accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(widget.role == 'Bride' ? Icons.female_rounded : Icons.male_rounded, color: widget.accent)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.role == 'Bride' ? context.tr('bride_details') : context.tr('groom_details'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              Text(context.tr('birth_information'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
            ])),
          ]),
          const SizedBox(height: 16),
          _label(context, context.tr('full_name')),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            validator: (value) => value == null || value.trim().isEmpty ? 'Enter the ${widget.role.toLowerCase()} name.' : null,
            decoration: _input(context, context.tr('enter_name'), Icons.person_outline_rounded),
          ),
          const SizedBox(height: 12),
          _label(context, context.tr('date_of_birth')),
          _tap(value: _date == null ? context.tr('select_date_of_birth') : '${_date!.day.toString().padLeft(2,'0')} / ${_date!.month.toString().padLeft(2,'0')} / ${_date!.year}', icon: Icons.calendar_month_rounded, placeholder: _date == null, onTap: _pickDate),
          const SizedBox(height: 12),
          _label(context, context.tr('exact_time_of_birth')),
          _tap(value: _formatTime(context, _time), icon: Icons.schedule_rounded, placeholder: _time == null, onTap: _pickTime),
          const SizedBox(height: 12),
          _label(context, context.tr('place_of_birth')),
          TextFormField(
            controller: _place,
            textCapitalization: TextCapitalization.words,
            validator: (value) => value == null || value.trim().isEmpty ? context.tr('enter_birth_place') : null,
            decoration: _input(context, context.tr('location_hint'), Icons.location_on_outlined),
          ),
          const SizedBox(height: 12),
          _label(context, context.tr('birth_time_zone')),
          _tap(value: _zone ?? context.tr('select_time_zone'), icon: Icons.public_rounded, placeholder: _zone == null, onTap: _pickZone),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Color(0xFFB94C4C), fontSize: 10, height: 1.4)),
          ],
          if (_busy) ...[
            const SizedBox(height: 10),
            const Row(children: [SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('Verifying birth location…', style: TextStyle(fontSize: 10, color: AppTheme.muted))]),
          ],
        ]),
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay? value) {
    if (value == null) return context.tr('select_local_birth_time');
    if (AppPreferencesService.cachedUse24HourTime) return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return value.format(context);
  }

  Widget _label(BuildContext context, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ink)),
  );

  InputDecoration _input(BuildContext context, String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: widget.accent, size: 18),
    filled: true,
    fillColor: const Color(0xFFFFFCF8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: widget.accent, width: 1.3)),
  );

  Widget _tap({required String value, required IconData icon, required bool placeholder, required VoidCallback onTap}) => Material(
    color: const Color(0xFFFFFCF8),
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFEAE5EF))),
        child: Row(children: [
          Icon(icon, size: 18, color: widget.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: TextStyle(fontSize: 11, color: placeholder ? AppTheme.muted : AppTheme.ink, fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 19),
        ]),
      ),
    ),
  );
}

class _ZoneDialog extends StatefulWidget {
  const _ZoneDialog({required this.zones, required this.selected});
  final List<String> zones;
  final String? selected;

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final matches = widget.zones.where((e) => e.toLowerCase().contains(query.toLowerCase())).take(100).toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), child: Align(alignment: Alignment.centerLeft, child: Text(context.tr('birth_time_zone'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: TextField(onChanged: (value) => setState(() => query = value), decoration: InputDecoration(hintText: context.tr('search_city_timezone'), prefixIcon: const Icon(Icons.search_rounded)))),
          Expanded(child: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (_, i) => ListTile(
              dense: true,
              title: Text(matches[i], style: const TextStyle(fontSize: 11)),
              trailing: matches[i] == widget.selected ? const Icon(Icons.check_rounded, color: AppTheme.plum) : null,
              onTap: () => Navigator.of(context).pop(matches[i]),
            ),
          )),
        ]),
      ),
    );
  }
}
