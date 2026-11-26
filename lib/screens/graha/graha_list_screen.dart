import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';
import 'graha_data.dart';
import 'graha_detail_screen.dart';

class GrahaListScreen extends StatefulWidget {
  const GrahaListScreen({super.key});

  @override
  State<GrahaListScreen> createState() => _GrahaListScreenState();
}

class _GrahaListScreenState extends State<GrahaListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocale.locale.value.languageCode;
    final query = _search.text.trim().toLowerCase();
    final visible = grahas.where((graha) {
      return query.isEmpty ||
          graha.english.toLowerCase().contains(query) ||
          graha.sanskrit.toLowerCase().contains(query) ||
          graha.hindi.contains(query) ||
          graha.gujarati.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('all_grahas'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 18),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(19),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF302544), Color(0xFF7656A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('navagraha'),
                                  style: const TextStyle(
                                    color: Color(0xFFFFDCA0),
                                    fontSize: 10,
                                    letterSpacing: 1.7,
                                    fontWeight: FontWeight.w800,
                                  )),
                              const SizedBox(height: 8),
                              Text(context.tr('all_grahas'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.12,
                                    fontWeight: FontWeight.w800,
                                  )),
                              const SizedBox(height: 8),
                              Text(context.tr('graha_list_subtitle'),
                                  style: const TextStyle(
                                    color: Color(0xFFE7DDF5),
                                    fontSize: 11,
                                    height: 1.4,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('☉', style: TextStyle(
                          color: Color(0xFFFFDCA0), fontSize: 62,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: context.tr('search_grahas'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${visible.length} / 9 ${context.tr('graha_count')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(context.tr('no_grahas_found'))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: .88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _GrahaCard(
                    graha: visible[index],
                    language: language,
                  ),
                  childCount: visible.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GrahaCard extends StatelessWidget {
  const _GrahaCard({required this.graha, required this.language});

  final GrahaInfo graha;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GrahaDetailScreen(graha: graha),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECE6F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: graha.color.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(graha.symbol, style: TextStyle(
                      fontSize: 29, color: graha.color,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_outward_rounded,
                      size: 16, color: AppTheme.muted),
                ],
              ),
              const Spacer(),
              Text(grahaDisplayName(graha, language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  )),
              const SizedBox(height: 3),
              Text(graha.sanskrit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.plum,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 7),
              Text(context.tr(graha.summaryKey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: AppTheme.muted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
