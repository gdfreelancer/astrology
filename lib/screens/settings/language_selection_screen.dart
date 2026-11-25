import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const _languages = <({String code, String name, String nativeName, String subtitle})>[
    (code: 'en', name: 'English', nativeName: 'English', subtitle: 'Continue in English'),
    (code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', subtitle: 'हिन्दी में जारी रखें'),
    (code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', subtitle: 'ગુજરાતીમાં ચાલુ રાખો'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = AppLocale.locale.value.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('language'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8062B5), Color(0xFF60468F)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌐', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 12),
                Text(context.tr('choose_language'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(context.tr('language_description'), style: const TextStyle(color: Color(0xFFEDE5F8), fontSize: 12, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._languages.map((language) {
            final isSelected = selected == language.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () async {
                    await AppLocale.setLanguage(language.code);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: isSelected ? AppTheme.plum : const Color(0xFFEAE5EF), width: isSelected ? 1.6 : 1),
                      color: isSelected ? const Color(0xFFF7F2FC) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: const Color(0xFFF2ECF8), borderRadius: BorderRadius.circular(13)),
                          child: Text(language.code.toUpperCase(), style: const TextStyle(color: AppTheme.plum, fontSize: 13, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.nativeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                              const SizedBox(height: 3),
                              Text(language.subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                        Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? AppTheme.plum : AppTheme.muted),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(context.tr('language_applies_everywhere'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
        ],
      ),
    );
  }
}
