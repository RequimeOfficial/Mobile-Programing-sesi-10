import 'package:flutter/material.dart';

import '../models/catatan.dart';
import '../services/catatan_storage.dart';
import '../utils/format_tanggal.dart';
import '../widgets/kartu_catatan.dart';
import 'form_catatan_page.dart';

class BerandaPage extends StatefulWidget {
  final CatatanStorage storage;
  final bool temaGelap;
  final VoidCallback onGantiTema;
  final DateTime? sekarang;

  const BerandaPage({
    super.key,
    required this.storage,
    required this.temaGelap,
    required this.onGantiTema,
    this.sekarang,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<Catatan> _daftar = [];
  bool _memuat = true;
  String _kataCari = '';

  DateTime get _sekarang => widget.sekarang ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final data = await widget.storage.muatCatatan();
    if (!mounted) return;
    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  Future<void> _simpan() async {
    _daftar.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    await widget.storage.simpanCatatan(_daftar);
  }

  Future<void> _bukaForm([Catatan? catatan]) async {
    final hasil = await Navigator.push<Catatan>(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(catatan: catatan, sekarang: _sekarang),
      ),
    );
    if (hasil == null) return;

    setState(() {
      final index = _daftar.indexWhere((c) => c.id == hasil.id);
      if (index >= 0) {
        _daftar[index] = hasil;
      } else {
        _daftar.add(hasil);
      }
    });
    await _simpan();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(catatan == null
            ? 'Catatan berhasil disimpan'
            : 'Catatan berhasil diperbarui'),
      ),
    );
  }

  Future<void> _hapus(Catatan catatan) async {
    final index = _daftar.indexOf(catatan);
    setState(() => _daftar.remove(catatan));
    await _simpan();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('"${catatan.judul}" dihapus'),
          action: SnackBarAction(
            label: 'BATAL',
            onPressed: () async {
              setState(() => _daftar.insert(index, catatan));
              await _simpan();
            },
          ),
        ),
      );
  }

  List<Catatan> get _hasilCari {
    if (_kataCari.isEmpty) return _daftar;
    final q = _kataCari.toLowerCase();
    return _daftar
        .where((c) =>
            c.judul.toLowerCase().contains(q) || c.isi.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _hasilCari;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Harian'),
        actions: [
          IconButton(
            tooltip: widget.temaGelap ? 'Tema terang' : 'Tema gelap',
            icon: Icon(widget.temaGelap ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onGantiTema,
          ),
        ],
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _HeaderTanggal(sekarang: _sekarang, jumlah: _daftar.length),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari catatan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _kataCari = v.trim()),
                ),
                const SizedBox(height: 16),
                if (daftar.isEmpty)
                  _KosongView(sedangMencari: _kataCari.isNotEmpty)
                else
                  ...daftar.map(
                    (c) => Dismissible(
                      key: ValueKey(c.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                      onDismissed: (_) => _hapus(c),
                      child: KartuCatatan(
                        catatan: c,
                        sekarang: _sekarang,
                        onTap: () => _bukaForm(c),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.edit_note),
        label: const Text('Tulis Catatan'),
      ),
    );
  }
}

class _HeaderTanggal extends StatelessWidget {
  final DateTime sekarang;
  final int jumlah;

  const _HeaderTanggal({required this.sekarang, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [skema.primary, skema.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ini',
                  style: TextStyle(color: skema.onPrimary.withValues(alpha: .8)),
                ),
                const SizedBox(height: 4),
                Text(
                  FormatTanggal.lengkap(sekarang),
                  style: TextStyle(
                    color: skema.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: skema.onPrimary.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$jumlah',
                  style: TextStyle(
                    color: skema.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'catatan',
                  style: TextStyle(color: skema.onPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KosongView extends StatelessWidget {
  final bool sedangMencari;

  const _KosongView({required this.sedangMencari});

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            sedangMencari ? Icons.search_off : Icons.menu_book_outlined,
            size: 72,
            color: skema.outline,
          ),
          const SizedBox(height: 12),
          Text(
            sedangMencari ? 'Catatan tidak ditemukan' : 'Belum ada catatan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            sedangMencari
                ? 'Coba kata kunci lain'
                : 'Tekan tombol "Tulis Catatan" untuk mulai menulis',
            style: TextStyle(color: skema.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
