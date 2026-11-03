import 'package:intl/intl.dart';

/// Kumpulan format tanggal menggunakan paket intl (locale Indonesia).
class FormatTanggal {
  static const _locale = 'id_ID';

  /// Contoh: Selasa, 3 November 2026
  static String lengkap(DateTime t) =>
      DateFormat('EEEE, d MMMM y', _locale).format(t);

  /// Contoh: 3 Nov 2026
  static String singkat(DateTime t) =>
      DateFormat('d MMM y', _locale).format(t);

  /// Contoh: 14.30
  static String jam(DateTime t) => DateFormat('HH.mm', _locale).format(t);

  /// Contoh: Selasa
  static String hari(DateTime t) => DateFormat('EEEE', _locale).format(t);

  /// Label relatif: "Hari ini", "Kemarin", atau tanggal singkat.
  static String relatif(DateTime t, {DateTime? sekarang}) {
    final now = sekarang ?? DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final tanggal = DateTime(t.year, t.month, t.day);
    final selisih = hariIni.difference(tanggal).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Kemarin';
    return singkat(t);
  }
}
