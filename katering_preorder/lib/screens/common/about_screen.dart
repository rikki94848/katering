import 'package:flutter/material.dart';
import '../../services/api_config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Aplikasi
            const Text(
              'Katering Pre-Order App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text(
              'Aplikasi mobile untuk pemesanan katering berbasis pre-order yang '
              'memungkinkan client melakukan pemesanan dan admin mengelola paket, '
              'pesanan, serta approval user.',
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Identitas Mahasiswa
            const Text(
              'Dibuat oleh:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text('1. Rikki Subagja\n   NPM: 152022055'),
            const SizedBox(height: 6),
            const Text('2. Aji Rahman Nugraha\n   NPM: 152022060'),
            const SizedBox(height: 6),
            const Text('3. Ananda Permana Mulyadi\n   NPM: 152022085'),

            const SizedBox(height: 16),
            const Divider(),

            // Teknologi
            const Text(
              'Teknologi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text('• Flutter (Mobile App)'),
            const Text('• Node.js Express (Backend API)'),
            const Text('• MySQL (Database)'),
            const Text('• REST API JSON'),

            const SizedBox(height: 16),
            const Divider(),

            // API Info
            const Text(
              'API yang digunakan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text('Backend API:'),
            SelectableText(ApiConfig.baseUrl),

            const SizedBox(height: 10),

            const Text('Public API (TheMealDB):'),
            SelectableText(ApiConfig.mealDbDoc),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'UAS Pemrograman Mobile\nSemester Ganjil 2025/2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
