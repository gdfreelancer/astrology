import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

import '../../theme/app_theme.dart';
import '../../widgets/rashi_artwork.dart';
import 'rashi_data.dart';
import 'rashi_detail_screen.dart';
import 'rashi_info.dart';

class RashiListScreen extends StatefulWidget {
  const RashiListScreen({super.key});

  @override
  State<RashiListScreen> createState() => _RashiListScreenState();
}

class _RashiListScreenState extends State<RashiListScreen> {
  final _search = TextEditingController();
  String _element = 'All';

  static const _filters = ['All', 'Fire (Agni)', 'Earth (Prithvi)', 'Air (Vayu)', 'Water (Jala)'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = rashis.where((r) {
      final matches = query.isEmpty || r.english.toLowerCase().contains(query) ||
          r.sanskrit.toLowerCase().contains(query) || r.gujarati.contains(query) || r.hindi.contains(query);
      return matches && (_element == 'All' || r.element == _element);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('all_rashis'), style: TextStyle(fontWeight: FontWeight.w800))),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            sliver: SliverToBoxAdapter(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    gradient: const LinearGradient(colors: [Color(0xFF35264F), Color(0xFF7255A5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(context.tr('explore_astrology'), style: TextStyle(color: Color(0xFFFFDCA0), fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text(context.tr('all_rashis'), style: TextStyle(color: Colors.white, fontSize: 24, height: 1.12, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text(context.tr('traditional_rashi_details'), style: TextStyle(color: Color(0xFFE7DDF5), fontSize: 10)),
                    ])),
                    const Text('☼', style: TextStyle(fontSize: 70, color: Color(0xFFFFDCA0))),
                  ]),
                ),
                const SizedBox(height: 17),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: context.tr('default_rashi'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 37,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 7),
                    itemBuilder: (context, i) {
                      final value = _filters[i];
                      final selected = _element == value;
                      return ChoiceChip(
                        label: Text(value == 'All' ? context.tr('all_rashis') : value.split(' ').first),
                        selected: selected,
                        onSelected: (_) => setState(() => _element = value),
                        selectedColor: AppTheme.plum.withValues(alpha: .14),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: selected ? AppTheme.plum : const Color(0xFFEAE5EF)),
                        labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? AppTheme.plum : AppTheme.muted),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 9),
                Text('${visible.length} / 12 ${context.tr('rashi_count')}', style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(context.tr('no_rashis_found'))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 13, mainAxisSpacing: 13, childAspectRatio: .78),
                delegate: SliverChildBuilderDelegate((context, i) => _RashiCard(rashi: visible[i]), childCount: visible.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _RashiCard extends StatelessWidget {
  const _RashiCard({required this.rashi});
  final RashiInfo rashi;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RashiDetailScreen(rashi: rashi))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          flex: 7,
          child: Stack(fit: StackFit.expand, children: [
            RashiArtwork(rashi: rashi, borderRadius: BorderRadius.zero),
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
              child: Text(rashi.number.toString().padLeft(2, '0'), style: const TextStyle(color: Color(0xFFFFE4B0), fontSize: 9, fontWeight: FontWeight.w800)),
            )),
          ]),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rashi.gujarati, style: const TextStyle(fontSize: 10, color: AppTheme.plum, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(rashi.sanskrit, style: const TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w800)),
              const Spacer(),
              Row(children: [
                Expanded(child: Text(rashi.english, style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600))),
                Text(rashi.symbol, style: const TextStyle(fontSize: 18, color: AppTheme.plum)),
              ]),
            ]),
          ),
        ),
      ]),
    ),
  );
}
