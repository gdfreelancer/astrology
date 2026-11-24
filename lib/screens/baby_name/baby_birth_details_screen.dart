import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../services/birth_chart_service.dart';
import '../../theme/app_theme.dart';
import 'rashi_result_screen.dart';

class BabyBirthDetailsScreen extends StatefulWidget {
  const BabyBirthDetailsScreen({super.key});

  @override
  State<BabyBirthDetailsScreen> createState() => _BabyBirthDetailsScreenState();
}

class _BabyBirthDetailsScreenState extends State<BabyBirthDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _timeZoneId;
  String _gender = 'Not specified';
  Location? _location;
  bool _isResolvingPlace = false;
  bool _isCalculating = false;
  bool _timeZonesReady = false;
  String? _placeError;

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _timeZonesReady = true;
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Select local birth time',
    );
    if (selected != null) setState(() => _birthTime = selected);
  }

  Future<void> _chooseTimeZone() async {
    if (!_timeZonesReady) return;
    final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _TimeZonePicker(
        zones: zones,
        selected: _timeZoneId ?? '',
      ),
    );
    if (selected != null) setState(() => _timeZoneId = selected);
  }

  Future<void> _editBirthPlace() async {
    final input = TextEditingController(text: _placeController.text);
    String? error;
    bool searching = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: const BoxDecoration(color: Color(0xFFFFFCF8), borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
            child: SafeArea(
              top: false,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9D1C9), borderRadius: BorderRadius.circular(8)))),
                const SizedBox(height: 22),
                const Text('Where was the baby born?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 6),
                const Text('Enter a city, town or village. Add the state and country for a more accurate match.', style: TextStyle(fontSize: 11, height: 1.45, color: AppTheme.muted)),
                const SizedBox(height: 18),
                TextField(
                  controller: input,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'e.g. Junagadh, Gujarat, India',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.plum),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEAE5EF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.plum, width: 1.4)),
                  ),
                  onSubmitted: (_) async {
                    if (searching || input.text.trim().isEmpty) return;
                    setSheetState(() { searching = true; error = null; });
                    _placeController.text = input.text.trim();
                    final found = await _resolvePlace();
                    if (!mounted) return;
                    if (found != null) { if (sheetContext.mounted) Navigator.of(sheetContext).pop(); }
                    else { setSheetState(() { searching = false; error = _placeError; }); }
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Color(0xFFB94C4C), fontSize: 11)),
                ],
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 52, child: FilledButton(
                  onPressed: searching ? null : () async {
                    if (input.text.trim().isEmpty) { setSheetState(() => error = 'Enter a city, town or village.'); return; }
                    setSheetState(() { searching = true; error = null; });
                    _placeController.text = input.text.trim();
                    final found = await _resolvePlace();
                    if (!mounted) return;
                    if (found != null) { if (sheetContext.mounted) Navigator.of(sheetContext).pop(); }
                    else { setSheetState(() { searching = false; error = _placeError; }); }
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.plum, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: searching ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Find this place', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                )),
              ]),
            ),
          ),
        ),
      ),
    );
    input.dispose();
  }

  Future<Location?> _resolvePlace() async {
    final query = _placeController.text.trim();
    if (query.isEmpty) {
      setState(() => _placeError = 'Enter the city, town or village of birth.');
      return null;
    }

    setState(() {
      _isResolvingPlace = true;
      _placeError = null;
    });

    try {
      final matches = await Geocoding().locationFromAddress(query);
      if (matches.isEmpty) {
        setState(() => _placeError = 'We could not find this place. Try adding the state and country.');
        return null;
      }
      final found = matches.first;
      if (!mounted) return null;
      setState(() {
        _location = found;
        _placeError = null;
      });
      return found;
    } catch (_) {
      if (mounted) {
        setState(() => _placeError = 'Could not look up this place. Check your connection and try again.');
      }
      return null;
    } finally {
      if (mounted) setState(() => _isResolvingPlace = false);
    }
  }

  Future<void> _calculate() async {
    if (_placeController.text.trim().isEmpty) {
      setState(() => _placeError = 'Please select the place of birth.');
      _showMessage('Please select the place of birth.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _birthTime == null || _timeZoneId == null) {
      _showMessage('Please select the birth date, exact birth time and birth time zone.');
      return;
    }

    setState(() => _isCalculating = true);
    try {
      final place = _location ?? await _resolvePlace();
      if (place == null || !mounted) return;

      final result = BirthChartService.calculate(
        birthDate: _birthDate!,
        hour: _birthTime!.hour,
        minute: _birthTime!.minute,
        timeZoneId: _timeZoneId!,
        placeName: _placeController.text.trim(),
        latitude: place.latitude,
        longitude: place.longitude,
        gender: _gender,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RashiResultScreen(result: result),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Unable to calculate birth details. Check the birth time zone and try again.');
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return 'Select date of birth';
    return '${value.day.toString().padLeft(2, '0')} / ${value.month.toString().padLeft(2, '0')} / ${value.year}';
  }

  String _timeLabel(TimeOfDay? value) {
    if (value == null) return 'Select exact birth time';
    return value.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('‹', style: TextStyle(fontSize: 32, height: 1, color: AppTheme.plum)),
        ),
        title: const Text('Baby Name & Rashi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8062B5), Color(0xFF60468F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Text('🍼', style: TextStyle(fontSize: 43)),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('A name written in the stars', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          SizedBox(height: 5),
                          Text('Enter the baby’s birth details to discover the Janma Rashi and naming sound.', style: TextStyle(color: Color(0xFFEDE5F8), fontSize: 11, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const _SectionHeading(number: '01', title: 'Birth information'),
              const SizedBox(height: 13),
              _FieldLabel('Date of birth'),
              _PickerTile(
                iconText: '📅',
                value: _dateLabel(_birthDate),
                isPlaceholder: _birthDate == null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 15),
              _FieldLabel('Exact time of birth'),
              _PickerTile(
                iconText: '🕰️',
                value: _timeLabel(_birthTime),
                isPlaceholder: _birthTime == null,
                onTap: _pickTime,
              ),
              const SizedBox(height: 7),
              const Text('Use the local time recorded at the place of birth.', style: TextStyle(color: AppTheme.muted, fontSize: 10)),
              const SizedBox(height: 23),
              const _SectionHeading(number: '02', title: 'Place and time zone'),
              const SizedBox(height: 13),
              _FieldLabel('Place of birth'),
              _BirthPlaceTile(
                placeName: _placeController.text.trim(),
                isResolving: _isResolvingPlace,
                isMatched: _location != null,
                error: _placeError,
                onTap: _isResolvingPlace ? null : _editBirthPlace,
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
              _FieldLabel('Birth time zone'),
              _PickerTile(
                iconText: '🌐',
                value: _timeZoneId ?? 'Select birth time zone',
                isPlaceholder: _timeZoneId == null,
                onTap: _chooseTimeZone,
                trailing: 'Change',
              ),
              const SizedBox(height: 7),
              const Text('Select the time zone that applied at the birth place and date. This matters for historical daylight-saving changes.', style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.45)),
              const SizedBox(height: 23),
              const _SectionHeading(number: '03', title: 'Baby information'),
              const SizedBox(height: 13),
              _FieldLabel('Gender (optional)'),
              Wrap(
                spacing: 9,
                children: [
                  _GenderChoice(label: 'Not specified', selected: _gender == 'Not specified', onTap: () => setState(() => _gender = 'Not specified')),
                  _GenderChoice(label: 'Boy', selected: _gender == 'Boy', onTap: () => setState(() => _gender = 'Boy')),
                  _GenderChoice(label: 'Girl', selected: _gender == 'Girl', onTap: () => setState(() => _gender = 'Girl')),
                ],
              ),
              const SizedBox(height: 27),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isCalculating ? null : _calculate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.plum,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: _isCalculating
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Calculate Birth Rashi  →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Calculation uses the selected time zone and Lahiri sidereal convention. Results close to a Nakshatra or Pada boundary should be independently verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthPlaceTile extends StatelessWidget {
  const _BirthPlaceTile({required this.placeName, required this.isResolving, required this.isMatched, required this.error, required this.onTap});
  final String placeName;
  final bool isResolving;
  final bool isMatched;
  final String? error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPlace = placeName.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: error != null ? const Color(0xFFB94C4C) : const Color(0xFFEAE5EF))),
            child: Row(children: [
              Container(width: 45, height: 45, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF0EAFE), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.location_on_rounded, color: AppTheme.plum, size: 23)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hasPlace ? placeName : 'Choose birth location', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w800, color: hasPlace ? AppTheme.ink : AppTheme.muted)),
                const SizedBox(height: 4),
                Text(isResolving ? 'Finding location…' : isMatched ? 'Location successfully matched' : 'City, town or village', style: TextStyle(fontSize: 10, color: isMatched ? const Color(0xFF438466) : AppTheme.muted, fontWeight: isMatched ? FontWeight.w700 : FontWeight.w400)),
              ])),
              const SizedBox(width: 8),
              if (isResolving) const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2))
              else Text(hasPlace ? 'Change' : 'Select', style: const TextStyle(color: AppTheme.plum, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ),
      if (error != null) ...[const SizedBox(height: 6), Text(error!, style: const TextStyle(color: Color(0xFFB94C4C), fontSize: 11))],
      if (isMatched) ...[const SizedBox(height: 7), const Text('Coordinates verified for birth-chart calculation.', style: TextStyle(color: Color(0xFF438466), fontSize: 10))],
    ]);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.number, required this.title});
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(color: const Color(0xFFF0EAFE), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: AppTheme.plum, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.ink, fontWeight: FontWeight.w700)),
      );
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.iconText,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
    this.trailing,
  });
  final String iconText;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFEAE5EF))),
            child: Row(
              children: [
                Text(iconText, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: isPlaceholder ? AppTheme.muted : AppTheme.ink, fontWeight: FontWeight.w600))),
                Text(trailing ?? '›', style: const TextStyle(color: AppTheme.plum, fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFEDE5F8),
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? AppTheme.plum : const Color(0xFFEAE5EF)),
        labelStyle: TextStyle(color: selected ? AppTheme.plum : AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

class _TimeZonePicker extends StatefulWidget {
  const _TimeZonePicker({required this.zones, required this.selected});
  final List<String> zones;
  final String selected;

  @override
  State<_TimeZonePicker> createState() => _TimeZonePickerState();
}

class _TimeZonePickerState extends State<_TimeZonePicker> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.zones.where((zone) => zone.toLowerCase().contains(query.toLowerCase())).take(100).toList();
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(alignment: Alignment.centerLeft, child: Text('Select birth time zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(hintText: 'Search city or time zone', prefixText: '⌕  '),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final zone = filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(zone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    trailing: zone == widget.selected ? const Text('✓', style: TextStyle(color: AppTheme.plum, fontWeight: FontWeight.w800)) : null,
                    onTap: () => Navigator.of(context).pop(zone),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
