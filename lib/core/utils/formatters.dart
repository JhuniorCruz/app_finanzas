import 'package:intl/intl.dart';

// Formatea con símbolo S/ y respeta signo negativo.
// Mantiene tu lógica original (signo manual + NumberFormat).
String formatCurrency(double amount) {
  final sign = amount < 0 ? '- ' : '';
  final abs = amount.abs();
  final formatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');
  return '$sign${formatter.format(abs)}';
}

// Parsea textos tipo "S/ 1.234,56" o "1,234.56" -> double
double parseCurrency(String value) {
  var cleaned = value.replaceAll('S/', '').replaceAll(' ', '');
  cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleaned) ?? 0.0;
}

// === Alias para compatibilidad con los views (AddDebtPage usa parseMoney) ===
double parseMoney(String value) => parseCurrency(value);

// Fechas numéricas simples (siempre válidas)
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

// ⚠️ Si ya definiste getDaysPastDue en core/utils/scoring.dart, elimina esta
// función de aquí para evitar choques por "ambiguous import".
// Si prefieres mantenerla aquí, no importes scoring.dart en los archivos que la usen.
