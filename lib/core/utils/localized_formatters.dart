import 'package:intl/intl.dart';

abstract final class LocalizedFormatters {
  static String timer(Duration duration, String locale) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final minutes = safe.inMinutes;
    final seconds = safe.inSeconds.remainder(60);
    final formatter = NumberFormat('00', locale);
    return '${formatter.format(minutes)}:${formatter.format(seconds)}';
  }

  static String decimal(num value, String locale, {int digits = 1}) =>
      NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: digits,
      ).format(value);
}
