import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

import '../rashi/rashi_data.dart';
import '../rashi/rashi_info.dart';
import '../../theme/app_theme.dart';
import '../../services/settings/app_preferences_service.dart';

class DailyHoroscopeScreen extends StatefulWidget {
  const DailyHoroscopeScreen({super.key});
  @override
  State<DailyHoroscopeScreen> createState() => _DailyHoroscopeScreenState();
}

class _DailyHoroscopeScreenState extends State<DailyHoroscopeScreen> {
  int _selectedRashi = 0;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadDefaultRashi();
  }

  Future<void> _loadDefaultRashi() async {
    final value = await AppPreferencesService.defaultRashi();
    const order = ['Mesha', 'Vrishabha', 'Mithuna', 'Karka', 'Simha', 'Kanya', 'Tula', 'Vrishchika', 'Dhanu', 'Makara', 'Kumbha', 'Meena'];
    final index = order.indexOf(value);
    if (mounted && index >= 0) setState(() => _selectedRashi = index);
  }
  static const _guidance = <int, List<String>>{
    1: ['Channel your enthusiasm into one clear priority. A measured first step can be more useful than rushing into several plans.', 'Keep conversations direct but patient. Listening fully can help avoid misunderstandings.', 'Review small expenses before making an impulse purchase.'],
    2: ['Steady progress is worth more than quick results. Give an ongoing task the attention it deserves.', 'A thoughtful gesture can strengthen a close bond. Make space for another point of view.', 'Focus on practical choices and avoid spending only for convenience.'],
    3: ['Curiosity can lead to a useful idea. Write down your thoughts and choose one to develop.', 'A clear message can resolve confusion. Ask questions rather than making assumptions.', 'Compare information carefully before committing to a purchase.'],
    4: ['A calm routine can help you feel organised. Complete one pending responsibility first.', 'Warm, honest communication can make relationships feel more supportive.', 'Keep room in your budget for household or personal needs.'],
    5: ['Let creativity support your work, while staying open to feedback.', 'Appreciation does not always need grand gestures. Give attention to the people who matter.', 'Balance generosity with a realistic spending limit.'],
    6: ['A practical checklist can help you make progress. Avoid perfecting every detail.', 'Offer help where it is welcome, but remember to express your own needs.', 'Review details and compare options before a financial decision.'],
    7: ['Cooperation can make a shared task easier. Decide what matters most first.', 'Fairness and honest conversation can restore balance in a relationship.', 'Think about long-term value rather than appearance when reviewing expenses.'],
    8: ['A focused approach can help with a complicated task. Keep information organised.', 'Trust grows through consistency. Share your thoughts at a comfortable pace.', 'Understand the details before making a financial commitment.'],
    9: ['Learning or exploring a new perspective may refresh your plans. Pair big ideas with a practical step.', 'Shared interests can bring people closer. Be considerate of different expectations.', 'Keep plans realistic and check details before committing money.'],
    10: ['Patience and structure can support steady progress. Break large responsibilities into steps.', 'Reliability matters, but make time for warmth and appreciation.', 'A long-term view can help you prioritise saving.'],
    11: ['An original idea may benefit from collaboration. Explain your thinking clearly.', 'Respect for each other’s independence can strengthen a connection.', 'Review unfamiliar offers carefully and avoid pressure-based decisions.'],
    12: ['Give imagination a practical direction. Organising your thoughts can bring clarity.', 'Empathy is valuable, and clear boundaries help keep relationships balanced.', 'Keep financial plans simple and check the facts before spending.'],
  };
  RashiInfo get _rashi => rashis[_selectedRashi];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) setState(() => _selectedDate = DateUtils.dateOnly(picked));
  }
  void _changeDate(int days) => setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('daily_horoscope'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        _introCard(context),
        const SizedBox(height: 22),
        Text(context.tr('choose_your_rashi'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 4),
        Text(context.tr('select_sign_guidance'), style: TextStyle(fontSize: 10, color: AppTheme.muted)),
        const SizedBox(height: 13),
        SizedBox(height: 106, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: rashis.length, separatorBuilder: (_, __) => const SizedBox(width: 9), itemBuilder: (context, index) {
          final item = rashis[index]; final selected = index == _selectedRashi;
          return GestureDetector(onTap: () => setState(() => _selectedRashi = index), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 76, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6), decoration: BoxDecoration(color: selected ? AppTheme.plum : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? AppTheme.plum : const Color(0xFFEDE7E1))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(item.symbol, style: TextStyle(fontSize: 25, color: selected ? Colors.white : AppTheme.plum)),
            const SizedBox(height: 5),
            Text(switch (AppLocale.locale.value.languageCode) { 'hi' => item.hindi, 'gu' => item.gujarati, _ => item.english }, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppTheme.ink)),
            Text(item.english, style: TextStyle(fontSize: 9, color: selected ? const Color(0xFFE9DFF8) : AppTheme.muted)),
          ])));
        })),
        const SizedBox(height: 22),
        _dateSelector(isToday),
        const SizedBox(height: 18),
        Row(children: [
          Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF1EAFE), borderRadius: BorderRadius.circular(15)), child: Text(_rashi.symbol, style: const TextStyle(fontSize: 27, color: AppTheme.plum))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${switch (AppLocale.locale.value.languageCode) { 'hi' => _rashi.hindi, 'gu' => _rashi.gujarati, _ => _rashi.english }} • ${_rashi.english}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            Text('Ruled by ${_rashi.ruler}', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF3DF), borderRadius: BorderRadius.circular(20)), child: Text(_rashi.element.split(' ').first, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9B6B25)))),
        ]),
        const SizedBox(height: 14),
        _readingCard('🌤️', context.tr('overall'), '${_rashi.summary} ${_rashi.personality}', const Color(0xFFFFF4DF)),
        const SizedBox(height: 10),
        _readingCard('💼', context.tr('career_work'), _guidance[_rashi.number]![0], const Color(0xFFEAF3FF)),
        const SizedBox(height: 10),
        _readingCard('💗', context.tr('love_relationships'), _guidance[_rashi.number]![1], const Color(0xFFFFEDF0)),
        const SizedBox(height: 10),
        _readingCard('💰', context.tr('money_finance'), _guidance[_rashi.number]![2], const Color(0xFFEAF5ED)),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFF2EDF9), borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ⓘ', style: TextStyle(fontSize: 18, color: AppTheme.plum)), SizedBox(width: 10),
          Expanded(child: Text('These are general, sign-based reflections, not predictions calculated from live planetary transits or your personal birth chart.', style: TextStyle(fontSize: 11, height: 1.5, color: AppTheme.ink))),
        ])),
      ])),
    );
  }

  Widget _introCard(BuildContext context) => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(23)), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(context.tr('your_daily_cosmic_note'), style: TextStyle(color: Color(0xFFE9DFF8), fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
      SizedBox(height: 8), Text(context.tr('horoscope_intro'), style: TextStyle(color: Colors.white, fontSize: 21, height: 1.2, fontWeight: FontWeight.w800)),
      SizedBox(height: 6), Text(context.tr('horoscope_choose_moon'), style: TextStyle(color: Color(0xFFE9DFF8), fontSize: 10)),
    ])), SizedBox(width: 12), Text('✨', style: TextStyle(fontSize: 52)),
  ]));

  Widget _dateSelector(bool isToday) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEDE7E1))), child: Row(children: [
    IconButton(onPressed: () => _changeDate(-1), icon: const Icon(Icons.chevron_left_rounded), visualDensity: VisualDensity.compact),
    Expanded(child: GestureDetector(onTap: _pickDate, child: Column(children: [
      Text(isToday ? context.tr('today') : _weekday(_selectedDate).toUpperCase(), style: const TextStyle(fontSize: 9, letterSpacing: 1.1, color: AppTheme.muted, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2), Text(_dateLabel(_selectedDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
    ]))),
    IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.plum, size: 19), visualDensity: VisualDensity.compact),
    IconButton(onPressed: () => _changeDate(1), icon: const Icon(Icons.chevron_right_rounded), visualDensity: VisualDensity.compact),
  ]));

  Widget _readingCard(String emoji, String title, String body, Color tint) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF0EBE5))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Text(emoji, style: const TextStyle(fontSize: 19))),
    const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 5), Text(body, style: const TextStyle(fontSize: 11, height: 1.5, color: AppTheme.muted)),
    ])),
  ]));
  String _dateLabel(DateTime date) => '${_month(date.month)} ${date.day}, ${date.year}';
  String _month(int month) => AppLocale.text('month_$month');
  String _weekday(DateTime date) => AppLocale.text('weekday_${date.weekday}');
}
