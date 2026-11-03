import 'package:flutter/material.dart';

import '../models/catatan.dart';
import '../utils/format_tanggal.dart';

/// Halaman untuk menulis catatan baru atau mengubah catatan lama.
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;
  final DateTime? sekarang;

  const FormCatatanPage({super.key, this.catatan, this.sekarang});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final _judulController =
      TextEditingController(text: widget.catatan?.judul);
  late final _isiController = TextEditingController(text: widget.catatan?.isi);
  late DateTime _tanggal =
      widget.catatan?.tanggal ?? widget.sekarang ?? DateTime.now();
  late String _suasana = widget.catatan?.suasana ?? 'Biasa';

  bool get _modeEdit => widget.catatan != null;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dipilih == null) return;
    setState(() {
      _tanggal = DateTime(
        dipilih.year,
        dipilih.month,
        dipilih.day,
        _tanggal.hour,
        _tanggal.minute,
      );
    });
  }

  Future<void> _pilihJam() async {
    final dipilih = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tanggal),
    );
    if (dipilih == null) return;
    setState(() {
      _tanggal = DateTime(
        _tanggal.year,
        _tanggal.month,
        _tanggal.day,
        dipilih.hour,
        dipilih.minute,
      );
    });
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    final hasil = _modeEdit
        ? widget.catatan!.copyWith(
            judul: judul, isi: isi, tanggal: _tanggal, suasana: _suasana)
        : Catatan(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            judul: judul,
            isi: isi,
            tanggal: _tanggal,
            suasana: _suasana,
          );
    Navigator.pop(context, hasil);
  }

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Ubah Catatan' : 'Catatan Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              color: skema.secondaryContainer,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Tanggal'),
                    subtitle: Text(FormatTanggal.lengkap(_tanggal)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pilihTanggal,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Jam'),
                    subtitle: Text(FormatTanggal.jam(_tanggal)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pilihJam,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Suasana hati', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: daftarSuasana.entries
                  .map(
                    (e) => ChoiceChip(
                      label: Text('${e.value} ${e.key}'),
                      selected: _suasana == e.key,
                      onSelected: (_) => setState(() => _suasana = e.key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('input_judul'),
              controller: _judulController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('input_isi'),
              controller: _isiController,
              minLines: 6,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Apa yang terjadi hari ini?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi catatan wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Catatan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
