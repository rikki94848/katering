import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/local_storage.dart';
import '../../state/session.dart';

import '../admin/admin_home.dart';
import '../client/client_home.dart';
import '../common/pending_approval_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _auth.login(_email.text.trim(), _pass.text);

      final s = await LocalStorage.loadSession();
      if (!mounted) return;

      if (s == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil, tapi session tidak tersimpan'),
          ),
        );
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

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => next),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // navy
                    Color(0xFF6D28D9), // purple
                    Color(0xFF06B6D4), // cyan
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            // Soft white overlay biar konten jelas
            Container(color: Colors.white.withValues(alpha: .88)),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                children: [
                  const SizedBox(height: 6),

                  // Header / Brand card (LOGO BARU DI SINI)
                  _GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CateringLogoBadge(size: 62),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bigmo Katering',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pesan paket harian dengan cepat, praktis, dan rapi.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Form Card
                  _GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Masuk',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gunakan akun yang sudah terdaftar.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .60),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.mail_outline),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: .70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: .10),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: .10),
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Email wajib diisi'
                                : null,
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _pass,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: .70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: .10),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: .10),
                                ),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Password wajib diisi'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Gradient button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF6D28D9),
                                      cs.primary,
                                      const Color(0xFF06B6D4),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.login,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Masuk',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Belum punya akun? Daftar',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'Tips: Jika akun client belum di-approve admin, kamu akan masuk ke halaman pending.',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: .55),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: .76),
        border: Border.all(color: Colors.white.withValues(alpha: .58)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: .08),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// =====================
/// LOGO BADGE (BUATAN SENDIRI, TANPA ASSET)
/// =====================
class CateringLogoBadge extends StatelessWidget {
  final double size;
  final Color color;

  const CateringLogoBadge({
    super.key,
    this.size = 64,
    this.color = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CateringLogoPainter(color: color),
        child: Padding(
          padding: EdgeInsets.only(
            top: size * 0.18,
            left: 6,
            right: 6,
            bottom: 6,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Catering',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: size * 0.22,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'QUALITY FOOD',
                style: TextStyle(
                  color: color.withValues(alpha: .82),
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.09,
                  letterSpacing: 1.1,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CateringLogoPainter extends CustomPainter {
  final Color color;

  _CateringLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;

    final ring = Paint()
      ..color = color.withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10;

    final innerRing = Paint()
      ..color = color.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05;

    final fill = Paint()
      ..color = Colors.white.withValues(alpha: .65)
      ..style = PaintingStyle.fill;

    // Base circle
    canvas.drawCircle(c, r * 0.98, fill);
    canvas.drawCircle(c, r * 0.90, ring);
    canvas.drawCircle(c, r * 0.76, innerRing);

    // Utensils (fork left, spoon right)
    _drawFork(canvas, size);
    _drawSpoon(canvas, size);

    // Chef hat on top
    _drawChefHat(canvas, size);

    // Stars bottom
    _drawStars(canvas, size);
  }

  void _drawFork(Canvas canvas, Size s) {
    final r = s.shortestSide / 2;
    final paint = Paint()..color = color.withValues(alpha: .90);

    // handle
    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(r * 0.28, r * 0.90, r * 0.09, r * 0.55),
      Radius.circular(r * 0.05),
    );
    canvas.drawRRect(handle, paint);

    // neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r * 0.285, r * 0.80, r * 0.08, r * 0.13),
        Radius.circular(r * 0.04),
      ),
      paint,
    );

    // prongs
    final prongW = r * 0.018;
    final prongH = r * 0.18;
    final startX = r * 0.295;
    final topY = r * 0.62;
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + i * prongW * 1.6, topY, prongW, prongH),
          Radius.circular(prongW),
        ),
        paint,
      );
    }
  }

  void _drawSpoon(Canvas canvas, Size s) {
    final r = s.shortestSide / 2;
    final paint = Paint()..color = color.withValues(alpha: .90);

    // handle
    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(r * 1.58, r * 0.90, r * 0.09, r * 0.55),
      Radius.circular(r * 0.05),
    );
    canvas.drawRRect(handle, paint);

    // neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r * 1.585, r * 0.80, r * 0.08, r * 0.13),
        Radius.circular(r * 0.04),
      ),
      paint,
    );

    // head oval
    final oval = Rect.fromCenter(
      center: Offset(r * 1.625, r * 0.66),
      width: r * 0.20,
      height: r * 0.25,
    );
    canvas.drawOval(oval, paint);
  }

  void _drawChefHat(Canvas canvas, Size s) {
    final r = s.shortestSide / 2;
    final fill = Paint()
      ..color = color.withValues(alpha: .92)
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = color.withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03;

    // cloud bumps
    final bumpCenters = [
      Offset(r * 0.80, r * 0.35),
      Offset(r * 1.00, r * 0.28),
      Offset(r * 1.20, r * 0.35),
    ];
    for (final bc in bumpCenters) {
      canvas.drawCircle(bc, r * 0.14, fill);
    }

    // base hat
    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(r * 0.73, r * 0.38, r * 0.54, r * 0.16),
      Radius.circular(r * 0.08),
    );
    canvas.drawRRect(base, fill);
    canvas.drawRRect(base, stroke);

    // small brim
    final brim = RRect.fromRectAndRadius(
      Rect.fromLTWH(r * 0.78, r * 0.52, r * 0.44, r * 0.09),
      Radius.circular(r * 0.07),
    );
    canvas.drawRRect(brim, fill);
  }

  void _drawStars(Canvas canvas, Size s) {
    final r = s.shortestSide / 2;
    final p = Paint()..color = color.withValues(alpha: .85);

    void star(Offset c, double rad) {
      final path = Path();
      const pts = 5;
      for (int i = 0; i < pts * 2; i++) {
        final isOuter = i.isEven;
        final rr = isOuter ? rad : rad * 0.45;
        final a = (i * (3.1415926 / pts)) - 3.1415926 / 2;
        final x = c.dx + rr * Math.cos(a);
        final y = c.dy + rr * Math.sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, p);
    }

    star(Offset(r * 0.92, r * 1.55), r * 0.05);
    star(Offset(r * 1.00, r * 1.60), r * 0.05);
    star(Offset(r * 1.08, r * 1.55), r * 0.05);
  }

  @override
  bool shouldRepaint(covariant _CateringLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Minimal math helper (tanpa import dart:math)
class Math {
  static double cos(double x) => _cos(x);
  static double sin(double x) => _sin(x);

  // Approximations (cukup untuk gambar kecil)
  static double _cos(double x) {
    // Taylor small approximation (good enough for icon)
    final x2 = x * x;
    return 1 - x2 / 2 + (x2 * x2) / 24;
    // Note: ini cukup buat bintang kecil, kalau mau presisi bisa pakai dart:math.
  }

  static double _sin(double x) {
    final x2 = x * x;
    return x - (x * x2) / 6 + (x * x2 * x2) / 120;
  }
}
