/// Model data satu catatan harian.
class Catatan {
  final String id;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String suasana;

  const Catatan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.suasana = 'Biasa',
  });

  Catatan copyWith({
    String? judul,
    String? isi,
    DateTime? tanggal,
    String? suasana,
  }) {
    return Catatan(
      id: id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      suasana: suasana ?? this.suasana,
    );
  }

  /// Diubah ke Map agar bisa disimpan sebagai JSON di shared_preferences.
  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'isi': isi,
        'tanggal': tanggal.toIso8601String(),
        'suasana': suasana,
      };

  factory Catatan.fromJson(Map<String, dynamic> json) => Catatan(
        id: json['id'] as String,
        judul: json['judul'] as String,
        isi: json['isi'] as String,
        tanggal: DateTime.parse(json['tanggal'] as String),
        suasana: (json['suasana'] as String?) ?? 'Biasa',
      );
}

/// Pilihan suasana hati beserta emoji-nya.
const Map<String, String> daftarSuasana = {
  'Senang': '😄',
  'Biasa': '🙂',
  'Lelah': '😴',
  'Sedih': '😢',
  'Semangat': '🔥',
};
