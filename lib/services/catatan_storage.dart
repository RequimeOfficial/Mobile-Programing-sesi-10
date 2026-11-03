import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/catatan.dart';

/// Penyimpanan lokal menggunakan paket shared_preferences.
///
/// Daftar catatan disimpan sebagai satu string JSON, sedangkan
/// pengaturan tema disimpan sebagai nilai boolean.
class CatatanStorage {
  static const _kunciCatatan = 'daftar_catatan';
  static const _kunciTemaGelap = 'tema_gelap';

  Future<List<Catatan>> muatCatatan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kunciCatatan);
    if (data == null || data.isEmpty) return [];

    final list = jsonDecode(data) as List<dynamic>;
    final hasil = list
        .map((e) => Catatan.fromJson(e as Map<String, dynamic>))
        .toList();
    hasil.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return hasil;
  }

  Future<void> simpanCatatan(List<Catatan> daftar) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(daftar.map((c) => c.toJson()).toList());
    await prefs.setString(_kunciCatatan, data);
  }

  Future<bool> muatTemaGelap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kunciTemaGelap) ?? false;
  }

  Future<void> simpanTemaGelap(bool gelap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kunciTemaGelap, gelap);
  }
}
