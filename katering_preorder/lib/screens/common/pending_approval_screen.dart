import 'package:flutter/material.dart';
import '../../services/local_storage.dart';
import 'about_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  final String name;
  const PendingApprovalScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menunggu Approval'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            icon: const Icon(Icons.info_outline),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo $name, akun kamu sudah terdaftar.'),
            const SizedBox(height: 8),
            const Text('Silakan tunggu admin melakukan approval, lalu login kembali.'),
            const Spacer(),
            OutlinedButton(
              onPressed: () async {
                await LocalStorage.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              },
              child: const Text('Keluar'),
            )
          ],
        ),
      ),
    );
  }
}
