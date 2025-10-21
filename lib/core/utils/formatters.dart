// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final sign = amount < 0 ? '- ' : '';
  final abs = amount.abs();
  final formatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');
  return '$sign${formatter.format(abs)}';
}

double parseCurrency(String value) {
  var cleaned = value.replaceAll('S/', '').replaceAll(' ', '');
  cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleaned) ?? 0.0;
}

// ---- Shim de compatibilidad (nuestro código usa parseMoney) ----
double parseMoney(String value) => parseCurrency(value);

// ✅ SIN DateFormat para fechas numéricas → nunca lanza excepciones
String formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString().padLeft(4, '0');
  return '$dd/$mm/$yyyy';
}

DateTime parseDate(String s) {
  try {
    final parts = s.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  } catch (_) {
    return DateTime.now();
  }
}

int getDaysPastDue(DateTime due) {
  final today = DateTime.now();
  final onlyDate = DateTime(today.year, today.month, today.day);
  final onlyDue = DateTime(due.year, due.month, due.day);
  final diff = onlyDate.difference(onlyDue).inDays;
  return diff > 0 ? diff : 0;
}
