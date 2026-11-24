import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/kundali/kundali_chart_style.dart';
import '../../services/birth_chart_service.dart';
import '../../services/kundali/kundali_preferences_service.dart';
import '../../theme/app_theme.dart';
import 'kundali_chart_style_screen.dart';
import 'kundali_result_screen.dart';

class CreateKundaliScreen extends StatefulWidget {
  const CreateKundaliScreen({super.key});

  @override
  State<CreateKundaliScreen> createState() => _CreateKundaliScreenState();
}

class _CreateKundaliScreenState extends State<CreateKundaliScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _timeZoneId;
  String _gender = 'Not specified';
  Location? _location;
  KundaliChartStyle? _chartStyle;
  bool _loadingPreference = true;
  bool _findingPlace = false;
  bool _calculating = false;
  String? _placeError;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _loadChartPreference();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _loadChartPreference() async {
    try {
      var style = await KundaliPreferencesService.getChartStyle();
      if (!mounted) return;
      if (style == null) {
        style = await Navigator.of(context).push<KundaliChartStyle>(
          MaterialPageRoute(builder: (_) => const KundaliChartStyleScreen()),
        );
      }
      if (!mounted) return;
      setState(() {
        _chartStyle = style;
        _loadingPreference = false;
      });
      if (style == null) {
        Navigator.of(context).maybePop();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPreference = false);
      _showMessage('Could not load your chart preference. Please try again.');
    }
  }

  Future<void> _changeChartStyle() async {
    final style = await Navigator.of(context).push<KundaliChartStyle>(
      MaterialPageRoute(builder: (_) => KundaliChartStyleScreen(currentStyle: _chartStyle)),
    );
    if (style != null && mounted) setState(() => _chartStyle = style);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (value != null) setState(() => _birthDate = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Select exact local birth time',
    );
    if (value != null) setState(() => _birthTime = value);
  }

  Future<void> _pickTimeZone() async {
    final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _TimeZoneDialog(zones: zones, selected: _timeZoneId),
    );
    if (selected != null) setState(() => _timeZoneId = selected);
  }

  Future<void> _findPlace() async {
    final query = _placeController.text.trim();
    if (query.isEmpty) {
      setState(() => _placeError = 'Enter the city, state and country.');
      return;
    }
    setState(() {
      _findingPlace = true;
      _placeError = null;
      _location = null;
    });
    try {
      final matches = await Geocoding().locationFromAddress(query);
      if (!mounted) return;
      if (matches.isEmpty) {
        setState(() => _placeError = 'Place not found. Add the state and country and try again.');
      } else {
        setState(() {
          _location = matches.first;
          _placeError = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _placeError = 'Could not find this place. Check your connection and retry.');
    } finally {
      if (mounted) setState(() => _findingPlace = false);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _birthTime == null || _timeZoneId == null) {
      _showMessage('Select the birth date, exact time and time zone.');
      return;
    }
    if (_location == null) {
      _showMessage('Find and confirm the birth place before continuing.');
      return;
    }
    final style = _chartStyle;
    if (style == null) {
      _showMessage('Choose a Kundali chart style first.');
      return;
    }

    setState(() => _calculating = true);
    try {
      final result = BirthChartService.calculate(
        birthDate: _birthDate!,
        hour: _birthTime!.hour,
        minute: _birthTime!.minute,
        timeZoneId: _timeZoneId!,
        placeName: _placeController.text.trim(),
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        gender: _gender,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => KundaliResultScreen(
          name: _nameController.text.trim(),
          chartStyle: style,
          birthResult: result,
        ),
      ));
    } catch (_) {
      if (mounted) _showMessage('Unable to calculate this chart. Verify the birth time zone and details.');
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  void _showMessage(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), behavior: SnackBarBehavior.floating));
  }

  String _dateText() => _birthDate == null
      ? 'Select date of birth'
      : '${_birthDate!.day.toString().padLeft(2, '0')} / ${_birthDate!.month.toString().padLeft(2, '0')} / ${_birthDate!.year}';

  @override
  Widget build(BuildContext context) {
    if (_loadingPreference) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.plum)));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Kundali', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Change chart style',
            onPressed: _changeChartStyle,
            icon: const Icon(Icons.tune_rounded, color: AppTheme.plum),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Row(
                  children: [
                    const Text('🪷', style: TextStyle(fontSize: 39)),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Birth details', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Enter accurate birth information to prepare your chart.', style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 10, height: 1.45)),
                        const SizedBox(height: 9),
                        Row(children: [
                          const Icon(Icons.dashboard_customize_rounded, color: Color(0xFFFFE3A8), size: 14),
                          const SizedBox(width: 5),
                          Text('${_chartStyle?.label ?? 'Chart style'} chart', style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 10, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 7),
                          GestureDetector(onTap: _changeChartStyle, child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 10, decoration: TextDecoration.underline))),
                        ]),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Personal information'),
              const SizedBox(height: 12),
              _Label('Full name (optional)'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Enter name', Icons.person_outline_rounded),
              ),
              const SizedBox(height: 14),
              _Label('Gender'),
              Wrap(spacing: 8, children: [
                for (final value in ['Not specified', 'Male', 'Female'])
                  ChoiceChip(
                    label: Text(value),
                    selected: _gender == value,
                    onSelected: (_) => setState(() => _gender = value),
                    selectedColor: const Color(0xFFEDE5F8),
                    side: BorderSide(color: _gender == value ? AppTheme.plum : const Color(0xFFEAE5EF)),
                    labelStyle: TextStyle(fontSize: 11, color: _gender == value ? AppTheme.plum : AppTheme.muted, fontWeight: FontWeight.w700),
                    showCheckmark: false,
                  ),
              ]),
              const SizedBox(height: 22),
              const _SectionTitle('Birth date and time'),
              const SizedBox(height: 12),
              _Label('Date of birth'),
              _TapField(value: _dateText(), placeholder: _birthDate == null, icon: Icons.calendar_month_rounded, onTap: _pickDate),
              const SizedBox(height: 13),
              _Label('Exact local birth time'),
              _TapField(
                value: _birthTime?.format(context) ?? 'Select exact birth time',
                placeholder: _birthTime == null,
                icon: Icons.schedule_rounded,
                onTap: _pickTime,
              ),
              const SizedBox(height: 7),
              const Text('Use the time recorded at the place of birth, not your current location.', style: TextStyle(color: AppTheme.muted, fontSize: 10)),
              const SizedBox(height: 22),
              const _SectionTitle('Birth location'),
              const SizedBox(height: 12),
              _Label('City, state and country'),
              TextFormField(
                controller: _placeController,
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter the birth place.' : null,
                decoration: _decoration('e.g. Junagadh, Gujarat, India', Icons.location_on_outlined),
                onChanged: (_) => setState(() { _location = null; _placeError = null; }),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 45,
                child: OutlinedButton.icon(
                  onPressed: _findingPlace ? null : _findPlace,
                  icon: _findingPlace
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded, size: 17),
                  label: Text(_findingPlace ? 'Finding place…' : 'Find and confirm place', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.plum, side: const BorderSide(color: Color(0xFFD9CDEB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                ),
              ),
              if (_placeError != null) ...[
                const SizedBox(height: 7),
                Text(_placeError!, style: const TextStyle(color: Color(0xFFB94C4C), fontSize: 10)),
              ],
              if (_location != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF438466)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Location confirmed · ${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}', style: const TextStyle(color: Color(0xFF438466), fontSize: 10, fontWeight: FontWeight.w700))),
                ]),
              ],
              const SizedBox(height: 14),
              _Label('Birth time zone'),
              _TapField(
                value: _timeZoneId ?? 'Select time zone',
                placeholder: _timeZoneId == null,
                icon: Icons.public_rounded,
                onTap: _pickTimeZone,
              ),
              const SizedBox(height: 7),
              const Text('Choose the time zone that applied at the birth place and date. Historical daylight-saving changes matter.', style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.45)),
              const SizedBox(height: 25),
              SizedBox(
                height: 55,
                child: FilledButton(
                  onPressed: _calculating ? null : _create,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.plum, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _calculating
                      ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Generate Kundali  →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Birth time, coordinates and time zone are essential for an accurate Lagna and house chart. The current calculation preview is limited to verified Sun/Moon data.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppTheme.plum, size: 19),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppTheme.plum, width: 1.4)),
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
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.zones.where((zone) => zone.toLowerCase().contains(query.toLowerCase())).take(120).toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Column(children: [
          const Padding(padding: EdgeInsets.fromLTRB(18, 19, 18, 8), child: Align(alignment: Alignment.centerLeft, child: Text('Select birth time zone', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'Search city or time zone', prefixIcon: Icon(Icons.search_rounded)))),
          Expanded(child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, index) {
              final zone = filtered[index];
              return ListTile(
                dense: true,
                title: Text(zone, style: const TextStyle(fontSize: 12)),
                trailing: widget.selected == zone ? const Icon(Icons.check_circle_rounded, color: AppTheme.plum, size: 18) : null,
                onTap: () => Navigator.of(context).pop(zone),
              );
            },
          )),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800));
}

class _Label extends StatelessWidget {
  const _Label(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(value, style: const TextStyle(color: AppTheme.ink, fontSize: 11, fontWeight: FontWeight.w700)));
}

class _TapField extends StatelessWidget {
  const _TapField({required this.value, required this.placeholder, required this.icon, required this.onTap});
  final String value;
  final bool placeholder;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 53,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEAE5EF))),
        child: Row(children: [
          Icon(icon, size: 19, color: AppTheme.plum),
          const SizedBox(width: 11),
          Expanded(child: Text(value, style: TextStyle(fontSize: 11, color: placeholder ? AppTheme.muted : AppTheme.ink, fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.plum),
        ]),
      ),
    ),
  );
}
