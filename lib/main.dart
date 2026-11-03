import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/beranda_page.dart';
import 'services/catatan_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Memuat data nama hari & bulan berbahasa Indonesia untuk paket intl.
  await initializeDateFormatting('id_ID');
  final temaGelap = await CatatanStorage().muatTemaGelap();
  runApp(CatatanHarianApp(temaGelapAwal: temaGelap));
}

class CatatanHarianApp extends StatefulWidget {
  final bool temaGelapAwal;
  final CatatanStorage? storage;
  final DateTime? sekarang;

  const CatatanHarianApp({
    super.key,
    this.temaGelapAwal = false,
    this.storage,
    this.sekarang,
  });

  @override
  State<CatatanHarianApp> createState() => _CatatanHarianAppState();
}

class _CatatanHarianAppState extends State<CatatanHarianApp> {
  late bool _temaGelap = widget.temaGelapAwal;
  late final CatatanStorage _storage = widget.storage ?? CatatanStorage();

  Future<void> _gantiTema() async {
    setState(() => _temaGelap = !_temaGelap);
    await _storage.simpanTemaGelap(_temaGelap);
  }

  ThemeData _tema(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        ),
        useMaterial3: true,
        // Font emoji untuk ikon suasana hati.
        fontFamilyFallback: const ['Noto Color Emoji'],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Harian',
      debugShowCheckedModeBanner: false,
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      themeMode: _temaGelap ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BerandaPage(
        storage: _storage,
        temaGelap: _temaGelap,
        onGantiTema: _gantiTema,
        sekarang: widget.sekarang,
      ),
    );
  }
}
