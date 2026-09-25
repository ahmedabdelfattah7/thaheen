/// Course content in Arabic and English. Arabic is the fallback, so a missing
/// English translation still shows something sensible.
class LocalizedText {
  const LocalizedText({required this.ar, this.en = ''});

  /// Accepts a plain string (Arabic only, as in the original catalog shape)
  /// or `{"ar": "...", "en": "..."}`.
  factory LocalizedText.fromJson(Object? json) => switch (json) {
    final String text => LocalizedText(ar: text),
    {'ar': final String ar, 'en': final String en} => LocalizedText(
      ar: ar,
      en: en,
    ),
    {'ar': final String ar} => LocalizedText(ar: ar),
    _ => throw FormatException('Expected text or {"ar", "en"}, got $json'),
  };

  static const empty = LocalizedText(ar: '');

  final String ar;
  final String en;

  bool get isEmpty => ar.isEmpty && en.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// The text for [languageCode] ('ar' or 'en').
  String of(String languageCode) =>
      languageCode == 'en' && en.isNotEmpty ? en : ar;

  /// Case-insensitive search in both languages.
  bool contains(String query) {
    final q = query.toLowerCase();
    return ar.toLowerCase().contains(q) || en.toLowerCase().contains(q);
  }
}
