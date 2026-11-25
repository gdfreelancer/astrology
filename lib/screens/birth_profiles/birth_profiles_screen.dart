import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_locale.dart';
import '../../models/birth_profile.dart';
import '../../services/birth_profile_service.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../theme/app_theme.dart';

class BirthProfilesScreen extends StatefulWidget {
  const BirthProfilesScreen({super.key});

  @override
  State<BirthProfilesScreen> createState() => _BirthProfilesScreenState();
}

class _BirthProfilesScreenState extends State<BirthProfilesScreen> {
  List<BirthProfile> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _load();
  }

  Future<void> _load() async {
    final values = await BirthProfileService.getAll();
    if (!mounted) return;
    setState(() {
      _profiles = values;
      _loading = false;
    });
  }

  Future<void> _edit([BirthProfile? profile]) async {
    final saved = await Navigator.of(context).push<BirthProfile>(
      MaterialPageRoute(
        builder: (_) => _BirthProfileEditor(profile: profile),
      ),
    );
    if (saved == null) return;
    await BirthProfileService.save(saved);
    await _load();
  }

  Future<void> _delete(BirthProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(context.tr('delete_birth_profile')),
        content: Text(context.tr('delete_birth_profile_confirm')
            .replaceAll('{name}', profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB94C4C)),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await BirthProfileService.delete(profile.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('birth_profiles'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        backgroundColor: AppTheme.plum,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('add_profile')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.plum))
          : _profiles.isEmpty
              ? _EmptyProfiles(onAdd: () => _edit())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
                  itemCount: _profiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: const Color(0xFFEFEAF2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EAF9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppTheme.plum),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profile.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.ink)),
                                const SizedBox(height: 4),
                                Text(
                                  '${profile.birthDate.day.toString().padLeft(2, '0')}/${profile.birthDate.month.toString().padLeft(2, '0')}/${profile.birthDate.year} · ${profile.formattedTime}',
                                  style: const TextStyle(
                                      fontSize: 10, color: AppTheme.muted),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  profile.placeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.muted),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _edit(profile);
                              if (value == 'delete') _delete(profile);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                  value: 'edit',
                                  child: Text(context.tr('edit'))),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: Text(context.tr('delete'))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                    color: Color(0xFFF1EAF9), shape: BoxShape.circle),
                child: const Icon(Icons.person_add_alt_1_rounded,
                    size: 34, color: AppTheme.plum),
              ),
              const SizedBox(height: 17),
              Text(context.tr('no_birth_profiles'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              const SizedBox(height: 7),
              Text(context.tr('birth_profiles_description'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, height: 1.5, color: AppTheme.muted)),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.tr('add_profile')),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.plum),
              ),
            ],
          ),
        ),
      );
}

class _BirthProfileEditor extends StatefulWidget {
  const _BirthProfileEditor({this.profile});
  final BirthProfile? profile;

  @override
  State<_BirthProfileEditor> createState() => _BirthProfileEditorState();
}

class _BirthProfileEditorState extends State<_BirthProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _place;
  DateTime? _date;
  TimeOfDay? _time;
  String? _zone;
  String _gender = 'Not specified';
  Location? _location;
  bool _resolving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p?.name ?? '');
    _place = TextEditingController(text: p?.placeName ?? '');
    _date = p?.birthDate;
    _time = p == null ? null : TimeOfDay(hour: p.hour, minute: p.minute);
    _zone = p?.timeZoneId;
    _gender = p?.gender ?? 'Not specified';
    if (p != null) {
      _location = Location(
        latitude: p.latitude,
        longitude: p.longitude,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
            alwaysUse24HourFormat: AppPreferencesService.cachedUse24HourTime),
        child: child!,
      ),
    );
    if (value != null) setState(() => _time = value);
  }

  Future<void> _pickZone() async {
    final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    final value = await showDialog<String>(
      context: context,
      builder: (dialog) => _TimeZoneDialog(zones: zones, selected: _zone),
    );
    if (value != null) setState(() => _zone = value);
  }

  Future<void> _resolvePlace() async {
    if (_place.text.trim().isEmpty) {
      setState(() => _error = context.tr('enter_birth_place'));
      return;
    }
    setState(() {
      _resolving = true;
      _error = null;
      _location = null;
    });
    try {
      final matches = await Geocoding().locationFromAddress(_place.text.trim());
      if (matches.isEmpty) throw StateError('No matching location');
      if (!mounted) return;
      setState(() => _location = matches.first);
    } catch (_) {
      if (mounted) setState(() => _error = context.tr('place_not_found'));
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null || _zone == null || _location == null) {
      setState(() => _error = context.tr('complete_birth_profile_details'));
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(BirthProfile(
      id: widget.profile?.id ?? now.microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      gender: _gender,
      birthDate: _date!,
      hour: _time!.hour,
      minute: _time!.minute,
      placeName: _place.text.trim(),
      latitude: _location!.latitude,
      longitude: _location!.longitude,
      timeZoneId: _zone!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(widget.profile == null
            ? 'add_profile'
            : 'edit_birth_profile')),
        actions: [
          TextButton(
            onPressed: _resolving ? null : _save,
            child: Text(context.tr('save'),
                style: const TextStyle(
                    color: AppTheme.plum, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            _fieldLabel(context.tr('profile_name')),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.tr('enter_profile_name')
                  : null,
              decoration: _decoration(context.tr('profile_name_hint'),
                  Icons.person_outline_rounded),
            ),
            const SizedBox(height: 15),
            _fieldLabel(context.tr('gender')),
            Wrap(spacing: 8, children: [
              for (final item in [
                ('Not specified', context.tr('not_specified')),
                ('Male', context.tr('male')),
                ('Female', context.tr('female')),
                ('Other', context.tr('other')),
              ])
                ChoiceChip(
                  label: Text(item.$2),
                  selected: _gender == item.$1,
                  onSelected: (_) => setState(() => _gender = item.$1),
                  showCheckmark: false,
                  selectedColor: const Color(0xFFEDE5F8),
                ),
            ]),
            const SizedBox(height: 19),
            _fieldLabel(context.tr('date_of_birth')),
            _picker(_date == null
                ? context.tr('select_date_of_birth')
                : '${_date!.day.toString().padLeft(2, '0')} / ${_date!.month.toString().padLeft(2, '0')} / ${_date!.year}', Icons.calendar_month_rounded, _pickDate),
            const SizedBox(height: 14),
            _fieldLabel(context.tr('exact_time_of_birth')),
            _picker(_time == null
                ? context.tr('select_local_birth_time')
                : AppPreferencesService.cachedUse24HourTime
                    ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                    : _time!.format(context), Icons.schedule_rounded, _pickTime),
            const SizedBox(height: 14),
            _fieldLabel(context.tr('place_of_birth')),
            TextFormField(
              controller: _place,
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.tr('enter_birth_place')
                  : null,
              onChanged: (_) => setState(() {
                _location = null;
                _error = null;
              }),
              decoration: _decoration(
                  context.tr('birth_location_hint'), Icons.location_on_outlined),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _resolving ? null : _resolvePlace,
              icon: _resolving
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.location_searching_rounded),
              label: Text(context.tr('verify_birth_place')),
            ),
            if (_location != null)
              Text(
                '${context.tr('location_verified')} · ${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF438466),
                    fontWeight: FontWeight.w700),
              ),
            const SizedBox(height: 14),
            _fieldLabel(context.tr('birth_time_zone')),
            _picker(_zone ?? context.tr('select_time_zone'),
                Icons.public_rounded, _pickZone),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFB94C4C))),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _resolving ? null : _save,
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.plum,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: Text(context.tr('save_profile'),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(value,
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.ink,
                fontWeight: FontWeight.w700)),
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.plum, size: 19),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
      );

  Widget _picker(String value, IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAE5EF))),
            child: Row(children: [
              Icon(icon, color: AppTheme.plum, size: 19),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.ink))),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.muted),
            ]),
          ),
        ),
      );
}

class _TimeZoneDialog extends StatefulWidget {
  const _TimeZoneDialog({required this.zones, required this.selected});
  final List<String> zones;
  final String? selected;

  @override
  State<_TimeZoneDialog> createState() => _TimeZoneDialogState();
}

class _TimeZoneDialogState extends State<_TimeZoneDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = widget.zones
        .where((z) => z.toLowerCase().contains(_query.toLowerCase()))
        .take(120)
        .toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(17),
            child: Text(context.tr('select_birth_time_zone'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                  hintText: context.tr('search_city_or_timezone'),
                  prefixIcon: const Icon(Icons.search_rounded)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(matches[i],
                    style: const TextStyle(fontSize: 11)),
                trailing: matches[i] == widget.selected
                    ? const Icon(Icons.check_rounded, color: AppTheme.plum)
                    : null,
                onTap: () => Navigator.pop(context, matches[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
