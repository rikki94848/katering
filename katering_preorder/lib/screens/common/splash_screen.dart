import 'package:flutter/material.dart';
import '../../services/local_storage.dart';
import '../../state/session.dart';

import '../auth/login_screen.dart';
import '../admin/admin_home.dart';
import '../client/client_home.dart';
import 'pending_approval_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // biar ada sedikit waktu tampil splash (halus)
    await Future.delayed(const Duration(milliseconds: 5000));

    final s = await LocalStorage.loadSession();

    if (!mounted) return;

    // kalau belum login
    if (s == null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final approvedRaw = s['approved'];
    final approved = (approvedRaw == true) || (approvedRaw == 1);

    final session = Session(
      token: s['token'],
      role: s['role'],
      approved: approved,
      name: s['name'],
    );

    Widget next;
    if (session.role == 'client' && session.approved == false) {
      next = PendingApprovalScreen(name: session.name);
    } else if (session.role == 'admin') {
      next = AdminHome(session: session);
    } else {
      next = ClientHome(session: session);
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B1020),
                  Color(0xFF5B21B6),
                  Color(0xFF06B6D4),
                  Color(0xFF22C55E),
                ],
                stops: [0.0, 0.45, 0.78, 1.0],
              ),
            ),
          ),

          // Glow blobsF
          Positioned(
            top: -80,
            left: -60,
            child: _GlowBlob(
              color: Colors.white.withValues(alpha: .18),
              size: 230,
            ),
          ),
          Positioned(
            bottom: -90,
            right: -70,
            child: _GlowBlob(
              color: Colors.white.withValues(alpha: .14),
              size: 270,
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Logo" sederhana (tanpa asset)
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6D28D9),
                          Color(0xFF06B6D4),
                          Color(0xFF22C55E),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: Colors.black.withValues(alpha: .25),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Bigmo katering',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Memuat aplikasi...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}
