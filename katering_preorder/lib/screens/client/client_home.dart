import 'package:flutter/material.dart';
import '../../state/session.dart';
import '../../services/local_storage.dart';
import '../common/about_screen.dart';
import 'packages_screen.dart';
import 'my_orders_screen.dart';
import 'public_menu_screen.dart';
import '../extra/firebase_monitor_screen.dart';

class ClientHome extends StatefulWidget {
  final Session session;
  const ClientHome({super.key, required this.session});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _idx = 0;

  static const _tabs = [
    _TabMeta(
      label: 'Paket',
      icon: Icons.restaurant_menu_rounded,
      activeIcon: Icons.restaurant_menu,
    ),
    _TabMeta(
      label: 'Pesanan',
      icon: Icons.receipt_long_rounded,
      activeIcon: Icons.receipt_long,
    ),
    _TabMeta(
      label: 'Inspirasi',
      icon: Icons.public_rounded,
      activeIcon: Icons.public,
    ),
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu akan logout dari aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await LocalStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.session.name;
    final pages = [
      PackagesScreen(session: widget.session),
      MyOrdersScreen(session: widget.session),
      const PublicMenuScreen(),
    ];

    final meta = _tabs[_idx];

    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Kirim nama user yg login ke halaman chat
              builder: (_) => ChatScreen(userName: widget.session.name),
            ),
          );
        },
        backgroundColor: const Color(0xFF7C3AED), // Ungu (sesuai tema)
        foregroundColor: Colors.white, // Ikon warna putih
        elevation: 4, // Efek bayangan
        tooltip: 'Live Chat',
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      body: Stack(
        children: [
          // Background gradient (halus)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF06B6D4),
                  Color(0xFF22C55E),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Overlay putih biar konten readable
          Container(color: Colors.white.withValues(alpha: .86)),

          SafeArea(
            child: Column(
              children: [
                // ===== Custom Gradient AppBar =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _GlassCard(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white.withValues(alpha: .18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .22),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_greeting()},',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .92),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // pill status tab
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.white.withValues(alpha: .18),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: .22,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        meta.activeIcon,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        meta.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          IconButton(
                            tooltip: 'About',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AboutScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Logout',
                            onPressed: _confirmLogout,
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== Body page with animation =====
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    child: _GlassCard(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: KeyedSubtree(
                          key: ValueKey(_idx),
                          child: pages[_idx],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ===== Bottom nav floating glass =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _GlassCard(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: NavigationBar(
              selectedIndex: _idx,
              onDestinationSelected: (v) => setState(() => _idx = v),
              height: 62,
              backgroundColor: Colors.transparent,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Paket',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pesanan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.public_rounded),
                  selectedIcon: Icon(Icons.public),
                  label: 'Inspirasi',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabMeta({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: .72),
        border: Border.all(color: Colors.white.withValues(alpha: .55)),
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
