import 'package:flutter/material.dart';
import '../../services/api_config.dart';
import '../extra/map_screen.dart'; // <--- Import Map Screen

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
            // --- JUDUL & DESKRIPSI ---
            const Center(
              child: Icon(
                Icons.restaurant_menu,
                size: 60,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Katering Pre-Order App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi mobile untuk pemesanan katering berbasis pre-order yang '
              'memungkinkan client melakukan pemesanan dan admin mengelola paket, '
              'pesanan, serta approval user.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // --- FITUR MAP (DIPINDAHKAN KESINI) ---
            // Ini menjawab poin soal tentang fitur Map
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.map, color: Color(0xFF7C3AED)),
                ),
                title: const Text(
                  "Lokasi Dapur Kami",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Cek lokasi fisik katering via Google Maps",
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
              ),
            ),

            // --------------------------------------
            const SizedBox(height: 24),
            const Divider(),

            // --- IDENTITAS MAHASISWA (Sesuai Data Kamu) ---
            const Text(
              'Developer Team:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _DevCard(name: 'Rikki Subagja', npm: '152022055'),
            _DevCard(name: 'Aji Rahman Nugraha', npm: '152022060'),
            _DevCard(name: 'Ananda Permana Mulyadi', npm: '152022085'),

            const SizedBox(height: 16),
            const Divider(),

            // --- TEKNOLOGI ---
            const Text(
              'Teknologi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _TechItem('Flutter (Mobile App)'),
            const _TechItem('Node.js Express (Backend API)'),
            const _TechItem('MySQL (Database)'),
            const _TechItem('REST API JSON'),

            const SizedBox(height: 16),
            const Divider(),

            // --- API INFO ---
            const Text(
              'API Config:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Backend:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SelectableText(
              ApiConfig.baseUrl,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Public API:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SelectableText(
              ApiConfig.mealDbDoc,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'UAS Pemrograman Mobile\nSemester Ganjil 2025/2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget Helper biar kodingan di atas rapi
class _DevCard extends StatelessWidget {
  final String name;
  final String npm;
  const _DevCard({required this.name, required this.npm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7C3AED),
          radius: 16,
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text("NPM: $npm", style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String label;
  const _TechItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
