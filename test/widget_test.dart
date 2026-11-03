import 'package:catatan_harian/main.dart';
import 'package:catatan_harian/models/catatan.dart';
import 'package:catatan_harian/services/catatan_storage.dart';
import 'package:catatan_harian/utils/format_tanggal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sekarang = DateTime(2026, 11, 3, 9, 30);

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Paket intl', () {
    test('format tanggal berbahasa Indonesia', () {
      expect(FormatTanggal.lengkap(sekarang), 'Selasa, 3 November 2026');
      expect(FormatTanggal.singkat(sekarang), '3 Nov 2026');
      expect(FormatTanggal.jam(sekarang), '09.30');
    });

    test('label relatif hari ini / kemarin', () {
      expect(FormatTanggal.relatif(sekarang, sekarang: sekarang), 'Hari ini');
      expect(
        FormatTanggal.relatif(DateTime(2026, 11, 2), sekarang: sekarang),
        'Kemarin',
      );
      expect(
        FormatTanggal.relatif(DateTime(2026, 10, 28), sekarang: sekarang),
        '28 Okt 2026',
      );
    });
  });

  group('Paket shared_preferences', () {
    test('catatan tersimpan dan dimuat kembali', () async {
      final storage = CatatanStorage();
      await storage.simpanCatatan([
        Catatan(id: '1', judul: 'Lama', isi: 'a', tanggal: DateTime(2026, 1, 1)),
        Catatan(id: '2', judul: 'Baru', isi: 'b', tanggal: DateTime(2026, 2, 1)),
      ]);

      final hasil = await CatatanStorage().muatCatatan();
      expect(hasil.length, 2);
      expect(hasil.first.judul, 'Baru'); // urut terbaru dulu
    });

    test('pengaturan tema gelap tersimpan', () async {
      final storage = CatatanStorage();
      expect(await storage.muatTemaGelap(), isFalse);
      await storage.simpanTemaGelap(true);
      expect(await storage.muatTemaGelap(), isTrue);
    });
  });

  group('Aplikasi', () {
    testWidgets('menampilkan tanggal hari ini dan keadaan kosong',
        (tester) async {
      await tester.pumpWidget(CatatanHarianApp(sekarang: sekarang));
      await tester.pumpAndSettle();

      expect(find.text('Catatan Harian'), findsOneWidget);
      expect(find.text('Selasa, 3 November 2026'), findsOneWidget);
      expect(find.text('Belum ada catatan'), findsOneWidget);
    });

    testWidgets('menambah catatan lalu tersimpan ke shared_preferences',
        (tester) async {
      // Ukuran layar ponsel (400 x 900) agar seluruh form terlihat.
      tester.view.physicalSize = const Size(1200, 2700);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(CatatanHarianApp(sekarang: sekarang));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tulis Catatan'));
      await tester.pumpAndSettle();
      expect(find.text('Catatan Baru'), findsOneWidget);

      // Validasi: simpan tanpa isi harus ditolak.
      await tester.ensureVisible(find.text('Simpan Catatan'));
      await tester.tap(find.text('Simpan Catatan'));
      await tester.pumpAndSettle();
      expect(find.text('Judul wajib diisi'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('input_judul')), 'Kuliah');
      await tester.enterText(
          find.byKey(const Key('input_isi')), 'Belajar paket dan plugin');
      await tester.tap(find.text('😄 Senang'));
      await tester.tap(find.text('Simpan Catatan'));
      await tester.pumpAndSettle();

      expect(find.text('Kuliah'), findsOneWidget);
      expect(find.text('Hari ini • 09.30'), findsOneWidget);
      expect(find.text('Catatan berhasil disimpan'), findsOneWidget);

      final tersimpan = await CatatanStorage().muatCatatan();
      expect(tersimpan.single.judul, 'Kuliah');
      expect(tersimpan.single.suasana, 'Senang');
    });

    testWidgets('memuat catatan lama, mencari, dan menghapus',
        (tester) async {
      await CatatanStorage().simpanCatatan([
        Catatan(
            id: '1',
            judul: 'Praktikum',
            isi: 'Flutter',
            tanggal: DateTime(2026, 11, 2, 20)),
        Catatan(
            id: '2',
            judul: 'Olahraga',
            isi: 'Lari pagi',
            tanggal: DateTime(2026, 11, 3, 6)),
      ]);

      await tester.pumpWidget(CatatanHarianApp(sekarang: sekarang));
      await tester.pumpAndSettle();
      expect(find.text('Praktikum'), findsOneWidget);
      expect(find.text('Kemarin • 20.00'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'lari');
      await tester.pumpAndSettle();
      expect(find.text('Praktikum'), findsNothing);
      expect(find.text('Olahraga'), findsOneWidget);

      await tester.drag(find.text('Olahraga'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('"Olahraga" dihapus'), findsOneWidget);

      final tersimpan = await CatatanStorage().muatCatatan();
      expect(tersimpan.map((c) => c.judul), ['Praktikum']);
    });

    testWidgets('tombol tema mengganti dan menyimpan tema gelap',
        (tester) async {
      await tester.pumpWidget(CatatanHarianApp(sekarang: sekarang));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Tema gelap'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Tema terang'), findsOneWidget);
      expect(await CatatanStorage().muatTemaGelap(), isTrue);
    });
  });
}
