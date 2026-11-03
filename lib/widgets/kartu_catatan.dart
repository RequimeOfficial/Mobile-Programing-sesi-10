import 'package:flutter/material.dart';

import '../models/catatan.dart';
import '../utils/format_tanggal.dart';

class KartuCatatan extends StatelessWidget {
  final Catatan catatan;
  final DateTime sekarang;
  final VoidCallback onTap;

  const KartuCatatan({
    super.key,
    required this.catatan,
    required this.sekarang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final emoji = daftarSuasana[catatan.suasana] ?? '🙂';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: skema.surfaceContainerHighest.withValues(alpha: .6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: skema.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${catatan.tanggal.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: skema.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      FormatTanggal.hari(catatan.tanggal).substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        color: skema.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            catatan.judul,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      catatan.isi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: skema.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: skema.outline),
                        const SizedBox(width: 4),
                        Text(
                          '${FormatTanggal.relatif(catatan.tanggal, sekarang: sekarang)}'
                          ' • ${FormatTanggal.jam(catatan.tanggal)}',
                          style: TextStyle(fontSize: 12, color: skema.outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
