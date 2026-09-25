import 'package:intl/intl.dart';

/// Formats [duration] as `m:ss`, or `h:mm:ss` when it is an hour or longer.
String formatDuration(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '$minutes:$seconds';
}

/// Formats a 0.0–1.0 [value] as a locale-aware percentage, e.g. `75%`.
String formatPercent(double value, String locale) =>
    NumberFormat.percentPattern(locale).format(value);

/// Wraps [text] in Unicode isolate marks (FSI ... PDI) so text in another
/// script can't reorder what's around it, e.g. an Arabic name followed by
/// "4 lessons" in the English UI.
String bidiIsolate(String text) => '\u2068$text\u2069';
