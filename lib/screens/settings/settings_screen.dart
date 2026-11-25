import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../../l10n/app_locale.dart';
import '../../models/kundali/kundali_chart_style.dart';
import '../../services/kundali/kundali_preferences_service.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../theme/app_theme.dart';
import '../kundali/kundali_chart_style_screen.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _use24Hour = false;
  String _defaultRashi = 'Mesha';
  SavedAppLocation? _location;
  KundaliChartStyle? _chartStyle;

  static const _rashis = <String>[
    'Mesha', 'Vrishabha', 'Mithuna', 'Karka', 'Simha', 'Kanya',
    'Tula', 'Vrishchika', 'Dhanu', 'Makara', 'Kumbha', 'Meena',
  ];

  static const _timeZones = <String>[
    'Asia/Kolkata', 'Asia/Dubai', 'Asia/Singapore', 'Europe/London',
    'Europe/Paris', 'America/New_York', 'America/Los_Angeles', 'Australia/Sydney',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await Future.wait<dynamic>([
      AppPreferencesService.use24HourTime(),
      AppPreferencesService.defaultRashi(),
      AppPreferencesService.defaultLocation(),
      KundaliPreferencesService.getChartStyle(),
    ]);
    if (!mounted) return;
    setState(() {
      _use24Hour = values[0] as bool;
      _defaultRashi = values[1] as String;
      _location = values[2] as SavedAppLocation;
      _chartStyle = values[3] as KundaliChartStyle?;
      _loading = false;
    });
  }

  Future<void> _selectChartStyle() async {
    final result = await Navigator.of(context).push<KundaliChartStyle>(
      MaterialPageRoute(builder: (_) => KundaliChartStyleScreen(currentStyle: _chartStyle)),
    );
    if (result != null && mounted) setState(() => _chartStyle = result);
  }

  Future<void> _selectLanguage() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LanguageSelectionScreen()));
    if (mounted) setState(() {});
  }

  Future<void> _setTimeFormat(bool value) async {
    await AppPreferencesService.setUse24HourTime(value);
    if (mounted) setState(() => _use24Hour = value);
  }

  Future<void> _selectRashi() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => _ChoiceSheet(
        title: context.tr('default_rashi'),
        children: _rashis.map((rashi) => ListTile(
          title: Text(_rashiLabel(rashi)),
          trailing: _defaultRashi == rashi ? const Icon(Icons.check_circle, color: AppTheme.plum) : null,
          onTap: () => Navigator.pop(sheet, rashi),
        )).toList(),
      ),
    );
    if (selected == null) return;
    await AppPreferencesService.setDefaultRashi(selected);
    if (mounted) setState(() => _defaultRashi = selected);
  }

  String _rashiLabel(String value) {
    const labels = {
      'Mesha': 'Aries · Mesha', 'Vrishabha': 'Taurus · Vrishabha',
      'Mithuna': 'Gemini · Mithuna', 'Karka': 'Cancer · Karka',
      'Simha': 'Leo · Simha', 'Kanya': 'Virgo · Kanya',
      'Tula': 'Libra · Tula', 'Vrishchika': 'Scorpio · Vrishchika',
      'Dhanu': 'Sagittarius · Dhanu', 'Makara': 'Capricorn · Makara',
      'Kumbha': 'Aquarius · Kumbha', 'Meena': 'Pisces · Meena',
    };
    return labels[value] ?? value;
  }

  Future<void> _editLocation() async {
    final current = _location ?? await AppPreferencesService.defaultLocation();
    final controller = TextEditingController(text: current.name);
    var zone = current.timeZoneId;
    var busy = false;
    String? error;
    final result = await showModalBottomSheet<SavedAppLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => StatefulBuilder(builder: (ctx, update) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: const BoxDecoration(color: Color(0xFFFFFCF8), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('default_location'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 6),
                Text(context.tr('location_description'), style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                const SizedBox(height: 14),
                TextField(controller: controller, autofocus: true, textCapitalization: TextCapitalization.words, decoration: InputDecoration(hintText: context.tr('location_hint'), prefixIcon: const Icon(Icons.location_on_outlined))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: zone,
                  decoration: InputDecoration(labelText: context.tr('time_zone')),
                  items: _timeZones.map((value) => DropdownMenuItem(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) { if (value != null) update(() => zone = value); },
                ),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 11))),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.plum),
                    onPressed: busy ? null : () async {
                      if (controller.text.trim().isEmpty) { update(() => error = context.tr('enter_location')); return; }
                      update(() { busy = true; error = null; });
                      try {
                        final matches = await Geocoding().locationFromAddress(controller.text.trim());
                        if (matches.isEmpty) throw StateError('not found');
                        if (sheet.mounted) Navigator.pop(sheet, SavedAppLocation(
                          name: controller.text.trim(),
                          latitude: matches.first.latitude,
                          longitude: matches.first.longitude,
                          timeZoneId: zone,
                        ));
                      } catch (_) {
                        update(() { busy = false; error = context.tr('location_not_found'); });
                      }
                    },
                    child: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(context.tr('save_location')),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
    controller.dispose();
    if (result == null) return;
    await AppPreferencesService.setDefaultLocation(result);
    if (mounted) setState(() => _location = result);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = AppLocale.locale.value.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.plum))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _section(context.tr('app_preferences')),
                _group([
                  _SettingTile(icon: Icons.language_rounded, title: context.tr('language'), subtitle: _languageName(languageCode), value: '›', onTap: _selectLanguage),
                  _SettingTile(icon: Icons.schedule_rounded, title: context.tr('time_format'), subtitle: context.tr('time_format_description'), value: _use24Hour ? '24-hour' : '12-hour', onTap: () => _showTimeFormat()),
                ]),
                const SizedBox(height: 18),
                _section(context.tr('kundali_preferences')),
                _group([
                  _SettingTile(icon: Icons.grid_view_rounded, title: context.tr('chart_style'), subtitle: context.tr('chart_style_description'), value: _chartStyle?.label ?? context.tr('not_selected'), onTap: _selectChartStyle),
                ]),
                const SizedBox(height: 18),
                _section(context.tr('panchang_preferences')),
                _group([
                  _SettingTile(icon: Icons.location_on_outlined, title: context.tr('default_location'), subtitle: _location?.name ?? '', value: '›', onTap: _editLocation),
                  _SettingTile(icon: Icons.public_rounded, title: context.tr('time_zone'), subtitle: _location?.timeZoneId ?? '', value: '›', onTap: _editLocation),
                ]),
                const SizedBox(height: 18),
                _section(context.tr('horoscope_preferences')),
                _group([
                  _SettingTile(icon: Icons.auto_awesome_rounded, title: context.tr('default_rashi'), subtitle: context.tr('default_rashi_description'), value: _rashiLabel(_defaultRashi), onTap: _selectRashi),
                ]),
                const SizedBox(height: 18),
                _section(context.tr('about')),
                _group([
                  _SettingTile(icon: Icons.info_outline_rounded, title: context.tr('about_app'), subtitle: context.tr('about_description'), value: '›', onTap: _showAbout),
                ]),
                const SizedBox(height: 16),
                Text(context.tr('settings_footer'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
              ],
            ),
    );
  }

  String _languageName(String code) => switch (code) { 'hi' => 'हिन्दी', 'gu' => 'ગુજરાતી', _ => 'English' };

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(left: 3, bottom: 9),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: AppTheme.muted)),
  );

  Widget _group(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFEFEAF2))),
    child: Column(children: [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1) const Divider(height: 1, indent: 54, endIndent: 14, color: Color(0xFFF0ECF2)),
      ],
    ]),
  );

  Future<void> _showTimeFormat() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => _ChoiceSheet(title: context.tr('time_format'), children: [
        ListTile(title: Text(context.tr('twelve_hour')), trailing: !_use24Hour ? const Icon(Icons.check_circle, color: AppTheme.plum) : null, onTap: () => Navigator.pop(sheet, false)),
        ListTile(title: Text(context.tr('twenty_four_hour')), trailing: _use24Hour ? const Icon(Icons.check_circle, color: AppTheme.plum) : null, onTap: () => Navigator.pop(sheet, true)),
      ]),
    );
    if (result != null) _setTimeFormat(result);
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Astrology',
      applicationVersion: '1.0.0+1',
      applicationIcon: const Icon(Icons.auto_awesome, color: AppTheme.plum, size: 32),
      children: [Text(context.tr('about_description'))],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onTap});
  final IconData icon;
  final String title, subtitle, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
    leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF3EDF9), borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: AppTheme.plum)),
    title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(value, style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w700)), const SizedBox(width: 4), const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.muted)]),
    onTap: onTap,
  );
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
    decoration: const BoxDecoration(color: Color(0xFFFFFCF8), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 10), child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink))),
      ...children,
    ])),
  );
}
