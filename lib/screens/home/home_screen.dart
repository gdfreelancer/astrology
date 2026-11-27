import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_locale.dart';
import '../../models/panchang_data.dart';
import '../../models/birth_profile.dart';
import '../../services/birth_profile_service.dart';
import '../../services/birth_chart_service.dart';
import '../../services/vimshottari_dasha_service.dart';
import '../../services/gochar_service.dart';
import '../../services/kundali_history_service.dart';
import '../../services/panchang_service.dart';
import '../../services/settings/app_preferences_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/feature_card.dart';
import '../baby_name/baby_birth_details_screen.dart';
import '../horoscope/daily_horoscope_screen.dart';
import '../matching/matching_home_screen.dart';
import '../muhurat/muhurat_screen.dart';
import '../panchang/panchang_screen.dart';
import '../kundali/create_kundali_screen.dart';
import '../rashi/rashi_list_screen.dart';
import '../graha/graha_list_screen.dart';
import '../settings/settings_screen.dart';
import '../library/offline_learning_screen.dart';
import '../birth_profiles/profile_comparison_screen.dart';
import '../birth_profiles/birth_profiles_screen.dart';
import '../kundali/transit_calendar_screen.dart';
import '../remedies/remedies_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanchangData? _today;
  bool _loadingPanchang = true;
  String _locationName = 'Ahmedabad, Gujarat, India';
  BirthProfile? _activeProfile;
  String? _dashaSummary;
  String? _gocharSummary;
  bool _loadingProfile = true;
  List<RecentKundaliReport> _recentReports = [];

  @override
  void initState() {
    super.initState();
    timezone_data.initializeTimeZones();
    _loadToday();
    _loadActiveProfile();
    _loadRecentReports();
  }

  Future<void> _loadToday() async {
    if (mounted) {
      setState(() {
        _loadingPanchang = true;
      });
    }
    try {
      final saved = await AppPreferencesService.defaultLocation();
      final zone = tz.getLocation(saved.timeZoneId);
      final now = tz.TZDateTime.now(zone);
      final location = PanchangLocation(
        name: saved.name,
        latitude: saved.latitude,
        longitude: saved.longitude,
        timeZoneId: saved.timeZoneId,
      );
      final data = await Future<PanchangData>(() => PanchangService.calculate(
            date: DateTime(now.year, now.month, now.day),
            location: location,
          ));
      if (!mounted) return;
      setState(() {
        _today = data;
        _locationName = saved.name;
        _loadingPanchang = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingPanchang = false;
      });
    }
  }

  Future<void> _loadActiveProfile() async {
    try {
      final profile = await BirthProfileService.getSelected();
      if (profile == null) {
        if (!mounted) return;
        setState(() {
          _activeProfile = null;
          _dashaSummary = null;
          _gocharSummary = null;
          _loadingProfile = false;
        });
        return;
      }
      final chart = BirthChartService.calculate(
        birthDate: profile.birthDate,
        hour: profile.hour,
        minute: profile.minute,
        second: profile.second,
        timeZoneId: profile.timeZoneId,
        placeName: profile.placeName,
        latitude: profile.latitude,
        longitude: profile.longitude,
        gender: profile.gender,
      );
      final now = tz.TZDateTime.now(tz.getLocation(profile.timeZoneId));
      final timeline = VimshottariDashaService.calculate(
        siderealMoonLongitude: chart.siderealMoonLongitude,
        birthDate: chart.birthLocal,
      );
      final maha = timeline.mahadashaAt(now);
      final antar = timeline.antardashaAt(now);
      final dasha = maha == null
          ? context.tr('no_active_dasha')
          : '${_localizedPlanetName(context, maha.planet)} ${context.tr('current_mahadasha')}${antar == null ? '' : ' · ${_localizedPlanetName(context, antar.planet)} ${context.tr('current_antardasha')}'}';
      final transits = GocharService.positionsAt(now.toUtc());
      final saturn = transits.firstWhere((p) => p.name == 'Saturn');
      final moon = chart.kundaliChart.grahas.firstWhere((p) => p.name == 'Moon');
      final sadeSati = GocharService.sadeSati(
        natalMoonSignIndex: moon.signIndex,
        transitSaturnSignIndex: saturn.signIndex,
      );
      final gochar = sadeSati.isActive
          ? context.tr('dashboard_sade_sati_active')
          : sadeSati.isDhaiya
              ? context.tr('dashboard_dhaiya_active')
              : context.tr('dashboard_sade_sati_inactive');
      if (!mounted) return;
      setState(() {
        _activeProfile = profile;
        _dashaSummary = dasha;
        _gocharSummary = gochar;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _activeProfile = null;
        _loadingProfile = false;
        _dashaSummary = null;
        _gocharSummary = null;
      });
    }
  }

  Future<void> _loadRecentReports() async {
    final reports = await KundaliHistoryService.getRecent();
    if (!mounted) return;
    setState(() => _recentReports = reports);
  }

  void _openRecentReport(RecentKundaliReport report) {
    _open(CreateKundaliScreen(initialProfile: report.profile));
  }

  Widget _buildRecentReports(BuildContext context) {
    if (_recentReports.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: context.tr('recent_kundali_reports')),
        const SizedBox(height: 10),
        for (final report in _recentReports.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _openRecentReport(report),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEAE5EF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, color: AppTheme.plum),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                            const SizedBox(height: 3),
                            Text('${_localizedRashiName(context, report.rashi)} · ${_localizedNakshatraName(context, report.nakshatra)} · ${report.profile.placeName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.plum),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openBirthProfiles() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const BirthProfilesScreen(),
    ));
    if (mounted) await _loadActiveProfile();
  }

  Widget _buildBirthProfileCard(BuildContext context) {
    final profile = _activeProfile;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: _openBirthProfiles,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFEAE5EF)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EAF9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.plum),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('active_birth_profile'),
                        style: const TextStyle(fontSize: 9, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      _loadingProfile
                          ? context.tr('loading')
                          : profile?.name ?? context.tr('no_active_birth_profile'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppTheme.ink, fontWeight: FontWeight.w800),
                    ),
                    if (profile != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${profile.placeName} · ${profile.formattedTime} · ${context.tr('time_accuracy_${profile.timeAccuracy}')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                      ),
                    ],
                  ],
                ),
              ),
              Text(context.tr('manage_birth_profiles'),
                  style: const TextStyle(fontSize: 9, color: AppTheme.plum, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.plum, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologySummary(BuildContext context) {
    if (_activeProfile == null || _loadingProfile) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(child: _DashboardSummaryTile(
          icon: Icons.auto_awesome_rounded,
          title: context.tr('current_dasha_summary'),
          value: _dashaSummary ?? context.tr('no_active_dasha'),
        )),
        const SizedBox(width: 10),
        Expanded(child: _DashboardSummaryTile(
          icon: Icons.public_rounded,
          title: context.tr('gochar_shani'),
          value: _gocharSummary ?? context.tr('dashboard_sade_sati_inactive'),
        )),
      ],
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  String _time(DateTime value) {
    final zoneId = _today?.location.timeZoneId;
    final localTime = zoneId == null
        ? value.toLocal()
        : tz.TZDateTime.from(value, tz.getLocation(zoneId));
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    if (AppPreferencesService.cachedUse24HourTime) {
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(
      _today?.date ?? DateTime.now(),
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('namaste'),
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.saffron,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('home_tagline'),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFFF1E9FA),
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => _open(const SettingsScreen()),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.settings_rounded,
                              color: AppTheme.plum,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  _KundaliBanner(
                    onTap: () => _open(const CreateKundaliScreen()),
                  ),
                  const SizedBox(height: 13),
                  _buildBirthProfileCard(context),
                  const SizedBox(height: 10),
                  _buildAstrologySummary(context),
                  const SizedBox(height: 18),
                  _buildRecentReports(context),
                  const SizedBox(height: 22),
                  _SectionHeading(
                    title: context.tr('today_panchang'),
                    action: context.tr('view_full_panchang'),
                    onTap: () => _open(const PanchangScreen()),
                  ),
                  const SizedBox(height: 10),
                  _buildPanchangCard(context),
                  const SizedBox(height: 23),
                  _SectionHeading(
                    title: context.tr('explore_astrology'),
                    action: context.tr('discover_more'),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: 1.12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      FeatureCard(
                        emoji: '👶',
                        title: context.tr('baby_name_rashi'),
                        description: context.tr('baby_name_desc'),
                        tint: const Color(0xFFFFF0E2),
                        onTap: () => _open(const BabyBirthDetailsScreen()),
                      ),
                      FeatureCard(
                        emoji: '♈',
                        title: context.tr('all_rashis'),
                        description: context.tr('all_rashis_desc'),
                        tint: const Color(0xFFF0EAFE),
                        onTap: () => _open(const RashiListScreen()),
                      ),
                      FeatureCard(
                        emoji: '☉',
                        title: context.tr('all_grahas'),
                        description: context.tr('all_grahas_desc'),
                        tint: const Color(0xFFFFF0D9),
                        onTap: () => _open(const GrahaListScreen()),
                      ),
                      FeatureCard(
                        emoji: '💞',
                        title: context.tr('kundali_matching'),
                        description: context.tr('matching_desc'),
                        tint: const Color(0xFFFFEDEF),
                        onTap: () => _open(const MatchingHomeScreen()),
                      ),
                      FeatureCard(
                        emoji: '✨',
                        title: context.tr('daily_horoscope'),
                        description: context.tr('horoscope_desc'),
                        tint: const Color(0xFFFFF5D9),
                        onTap: () => _open(const DailyHoroscopeScreen()),
                      ),
                      FeatureCard(
                        emoji: '🕉️',
                        title: context.tr('muhurat'),
                        description: context.tr('muhurat_desc'),
                        tint: const Color(0xFFE8F3FA),
                        onTap: () => _open(const MuhuratScreen()),
                      ),
                      FeatureCard(
                        emoji: '🪐',
                        title: 'Transit Calendar',
                        description: 'Upcoming sign changes and retrograde stations',
                        tint: const Color(0xFFE9F3F6),
                        onTap: () => _open(const TransitCalendarScreen()),
                      ),
                      FeatureCard(
                        emoji: '⚖️',
                        title: 'Compare Kundalis',
                        description: 'Compare two saved birth charts offline',
                        tint: const Color(0xFFE8F3FA),
                        onTap: () => _open(const ProfileComparisonScreen()),
                      ),
                      FeatureCard(
                        emoji: '🪷',
                        title: context.tr('remedies'),
                        description: context.tr('remedy_card_desc'),
                        tint: const Color(0xFFF3EEF8),
                        onTap: () => _open(const RemediesHomeScreen()),
                      ),
                      FeatureCard(
                        emoji: '📚',
                        title: 'Learning & Mantras',
                        description: 'Offline lessons, mantra guide and personal diary',
                        tint: const Color(0xFFF0EAFE),
                        onTap: () => _open(const OfflineLearningScreen()),
                      ),
                      FeatureCard(
                        emoji: '📅',
                        title: context.tr('panchang'),
                        description: context.tr('panchang_desc'),
                        tint: const Color(0xFFE9F5EE),
                        onTap: () => _open(const PanchangScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E8),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFF4E5CC)),
                    ),
                    child: Row(
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 25)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('universe_rhythm'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                context.tr('universe_subtitle'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanchangCard(BuildContext context) {
    if (_loadingPanchang) {
      return Container(
        height: 174,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFF0EBE5)),
        ),
        child: const Center(
          child: SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.plum,
            ),
          ),
        ),
      );
    }

    final data = _today;
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFF0EBE5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppTheme.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('panchang_unavailable'),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.muted,
                ),
              ),
            ),
            IconButton(
              tooltip: context.tr('retry'),
              onPressed: _loadToday,
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.plum),
            ),
          ],
        ),
      );
    }

    final tithi = data.element('Tithi').value;
    final nakshatra = data.element('Nakshatra').value;
    final yoga = data.element('Yoga').value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7656A7), Color(0xFF4F3B78)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4F3B78),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFFD995),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('todays_sky'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFDCCFF0),
                size: 13,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  _locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE5DDF1),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PanchangValue(
                  label: context.tr('tithi'),
                  value: tithi,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PanchangValue(
                  label: context.tr('nakshatra'),
                  value: nakshatra,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PanchangValue(
                  label: context.tr('yoga'),
                  value: yoga,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(height: 1, color: const Color(0x35FFFFFF)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeInfo(
                  icon: Icons.wb_twilight_rounded,
                  label: context.tr('sunrise'),
                  value: _time(data.sunrise),
                ),
              ),
              Expanded(
                child: _TimeInfo(
                  icon: Icons.wb_sunny_outlined,
                  label: context.tr('sunset'),
                  value: _time(data.sunset),
                ),
              ),
              Expanded(
                child: _TimeInfo(
                  icon: Icons.schedule_rounded,
                  label: context.tr('rahu_kaal'),
                  value:
                      '${_time(data.rahuKaal.start)} – ${_time(data.rahuKaal.end)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.plum,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PanchangValue extends StatelessWidget {
  const _PanchangValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 0.8,
            color: Color(0xFFD9CBEA),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.25,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFD995), size: 14),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFFD9CBEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KundaliBanner extends StatelessWidget {
  const _KundaliBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.plum,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 160,
          padding: const EdgeInsets.fromLTRB(19, 17, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF8062B5), Color(0xFF60468F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 4,
                top: 0,
                child: Text(
                  '✧',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0x99FFFFFF),
                  ),
                ),
              ),
              const Positioned(
                right: 55,
                bottom: -8,
                child: Text(
                  '☼',
                  style: TextStyle(
                    fontSize: 75,
                    color: Color(0x22FFFFFF),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      context.tr('your_birth_chart'),
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.tr('discover_kundali'),
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('birth_chart_subtitle'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFE9DFF8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        context.tr('create_kundali'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFE3A8),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 21,
                        height: 21,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE3A8),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '→',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1,
                              color: AppTheme.plum,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Positioned(
                right: 16,
                top: 42,
                child: Text('🔮', style: TextStyle(fontSize: 52)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSummaryTile extends StatelessWidget {
  const _DashboardSummaryTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F2FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAE1F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.plum, size: 18),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 9, color: AppTheme.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(value, maxLines: 3, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppTheme.ink, fontWeight: FontWeight.w800, height: 1.25)),
          ],
        ),
      );
}

String _localizedPlanetName(BuildContext context, String name) {
  final key = switch (name) {
    'Sun' => 'planet_sun',
    'Moon' => 'planet_moon',
    'Mars' => 'planet_mars',
    'Mercury' => 'planet_mercury',
    'Jupiter' => 'planet_jupiter',
    'Venus' => 'planet_venus',
    'Saturn' => 'planet_saturn',
    'Rahu' => 'planet_rahu',
    'Ketu' => 'planet_ketu',
    _ => '',
  };
  return key.isEmpty ? name : context.tr(key);
}

String _localizedRashiName(BuildContext context, String name) {
  const keys = {
    'Aries': 'p_mesha',
    'Taurus': 'p_vrishabha',
    'Gemini': 'p_mithuna',
    'Cancer': 'p_karka',
    'Leo': 'p_simha',
    'Virgo': 'p_kanya',
    'Libra': 'p_tula',
    'Scorpio': 'p_vrishchika',
    'Sagittarius': 'p_dhanu',
    'Capricorn': 'p_makara',
    'Aquarius': 'p_kumbha',
    'Pisces': 'p_meena',
  };
  final key = keys[name];
  return key == null ? name : context.tr(key);
}

String _localizedNakshatraName(BuildContext context, String name) {
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final key = 'p_$slug';
  final value = context.tr(key);
  return value == key ? name : value;
}
