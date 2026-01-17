import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _auth.register(_name.text.trim(), _email.text.trim(), _pass.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil daftar. Tunggu approval admin, lalu login.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daftar gagal: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            // Background gradient kompleks
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B1020), // dark navy
                    Color(0xFF5B21B6), // purple
                    Color(0xFF06B6D4), // cyan
                    Color(0xFF22C55E), // green accent
                  ],
                  stops: [0.0, 0.45, 0.78, 1.0],
                ),
              ),
            ),

            // glow blobs (biar keliatan premium)
            Positioned(
              top: -80,
              left: -60,
              child: _GlowBlob(
                color: Colors.white.withValues(alpha: .18),
                size: 220,
              ),
            ),
            Positioned(
              bottom: -90,
              right: -70,
              child: _GlowBlob(
                color: Colors.white.withValues(alpha: .14),
                size: 260,
              ),
            ),

            // overlay putih halus supaya konten kontras
            Container(color: Colors.white.withValues(alpha: .86)),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                children: [
                  // top bar (back + title)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Daftar Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // badge kecil
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6D28D9), Color(0xFF06B6D4)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                                color: Colors.black.withValues(alpha: .10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buat akun client',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Setelah daftar, akun perlu di-approve admin sebelum bisa login.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Data akun',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Isi nama, email, dan password dengan benar.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .60),
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              cs,
                              label: 'Nama',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Nama wajib diisi';
                              if (s.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              cs,
                              label: 'Email',
                              icon: Icons.mail_outline,
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Email wajib diisi';
                              if (!s.contains('@') || !s.contains('.')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _pass,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                _loading ? null : _register(),
                            decoration: _inputDecoration(
                              cs,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (v) {
                              final s = (v ?? '');
                              if (s.isEmpty) return 'Password wajib diisi';
                              if (s.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
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
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6D28D9),
                                      Color(0xFF06B6D4),
                                      Color(0xFF22C55E),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Daftar',
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

                          Text(
                            'Dengan mendaftar, kamu setuju mengikuti proses approval oleh admin.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .55),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 4),

                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text(
                              'Sudah punya akun? Masuk',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
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

  InputDecoration _inputDecoration(
    ColorScheme cs, {
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: .10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: .10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: cs.primary.withValues(alpha: .85),
          width: 1.6,
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
