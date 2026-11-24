import 'package:flutter/material.dart';

import '../../data/baby_names_data.dart';
import '../../models/birth_chart_result.dart';
import '../../theme/app_theme.dart';

class BabyNamesScreen extends StatefulWidget {
  const BabyNamesScreen({super.key, required this.result});

  final BirthChartResult result;

  @override
  State<BabyNamesScreen> createState() => _BabyNamesScreenState();
}

class _BabyNamesScreenState extends State<BabyNamesScreen> {
  String _genderFilter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final prefix = widget.result.namingSyllable.toLowerCase();
    final filtered = babyNames.where((entry) {
      final startsWithSound = entry.name.toLowerCase().startsWith(prefix);
      final genderMatches = _genderFilter == 'All' || entry.gender == _genderFilter;
      final queryMatches = _query.isEmpty ||
          entry.name.toLowerCase().contains(_query.toLowerCase()) ||
          entry.meaning.toLowerCase().contains(_query.toLowerCase());
      return startsWithSound && genderMatches && queryMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('‹', style: TextStyle(fontSize: 32, height: 1, color: AppTheme.plum)),
        ),
        title: const Text('Suggested Baby Names', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
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
                const Text('🪷', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Names inspired by the stars', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Text('Starting sound: ${widget.result.namingSyllable}', style: const TextStyle(color: Color(0xFFFFE3A8), fontSize: 13, fontWeight: FontWeight.w800)),
                      Text('${widget.result.nakshatra} · Pada ${widget.result.pada}', style: const TextStyle(color: Color(0xFFE9DFF8), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(hintText: 'Search name or meaning', prefixText: '⌕  '),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            children: ['All', 'Boy', 'Girl'].map((filter) => ChoiceChip(
              label: Text(filter),
              selected: _genderFilter == filter,
              onSelected: (_) => setState(() => _genderFilter = filter),
              selectedColor: const Color(0xFFEDE5F8),
              backgroundColor: Colors.white,
              side: BorderSide(color: _genderFilter == filter ? AppTheme.plum : const Color(0xFFEAE5EF)),
              labelStyle: TextStyle(color: _genderFilter == filter ? AppTheme.plum : AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700),
              showCheckmark: false,
            )).toList(),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Expanded(child: Text('Name ideas', style: TextStyle(color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w800))),
              Text('${filtered.length} names', style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAE5EF))),
              child: Column(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text('No matching names in this starter collection', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                  const SizedBox(height: 5),
                  Text('Try another filter or search. Names should begin with the recommended sound “${widget.result.namingSyllable}”.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.5)),
                ],
              ),
            )
          else
            ...filtered.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE5EF))),
              child: Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(color: const Color(0xFFF2ECFA), borderRadius: BorderRadius.circular(13)),
                    alignment: Alignment.center,
                    child: Text(entry.name.characters.first, style: const TextStyle(color: AppTheme.plum, fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name, style: const TextStyle(color: AppTheme.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(entry.meaning, style: const TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.35)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.gender, style: const TextStyle(color: AppTheme.plum, fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            )),
          const SizedBox(height: 8),
          const Text('Name collection is a starter list. Meanings and regional spellings can vary; please verify your preferred name before finalising it.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 10, height: 1.5)),
        ],
      ),
    );
  }
}
