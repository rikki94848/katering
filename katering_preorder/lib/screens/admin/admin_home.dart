import 'package:flutter/material.dart';

import '../../state/session.dart';
import '../../services/local_storage.dart';
import '../common/about_screen.dart';
import 'pending_users_screen.dart';
import 'manage_packages_screen.dart';
import 'admin_orders_screen.dart';
import 'sales_report_screen.dart';
import '../extra/firebase_monitor_screen.dart';
import '../extra/chart_screen.dart';

class AdminHome extends StatefulWidget {
  final Session session;
  const AdminHome({super.key, required this.session});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _idx = 0;

  late final List<Widget> _pages;

  // Pengganti withOpacity() yang aman (biar warning hilang)
  Color _op(Color c, double opacity) {
    final a = (opacity * 255).round().clamp(0, 255);
    return c.withAlpha(a);
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      PendingUsersScreen(session: widget.session),
      ManagePackagesScreen(session: widget.session),
      AdminOrdersScreen(session: widget.session),
      SalesReportScreen(session: widget.session),
    ];
  }

  String get _title {
    switch (_idx) {
      case 0:
        return 'Approval User';
      case 1:
        return 'Kelola Paket';
      case 2:
        return 'Kelola Pesanan';
      default:
        return 'Laporan Penjualan';
    }
  }

  IconData get _titleIcon {
    switch (_idx) {
      case 0:
        return Icons.verified_user_rounded;
      case 1:
        return Icons.inventory_2_rounded;
      case 2:
        return Icons.receipt_long_rounded;
      default:
        return Icons.bar_chart_rounded;
    }
  }

  Future<void> _openAbout() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
  }

  Future<void> _logout() async {
    final scheme = Theme.of(context).colorScheme;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: scheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.logout_rounded, color: scheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Keluar dari akun admin?',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kamu akan kembali ke halaman login.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    await LocalStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: _AdminDrawer(
        name: widget.session.name,
        onAbout: _openAbout,
        onLogout: _logout,
        op: _op,
      ),
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const _BrandMark(size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Admin • ${widget.session.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tentang',
            onPressed: _openAbout,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // Background aksen biar terasa modern
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _op(scheme.primary, 0.18),
                        _op(scheme.tertiary, 0.14),
                        _op(scheme.secondary, 0.10),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container(color: scheme.surface)),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _HeaderCard(
                    title: 'Admin Console',
                    subtitle: 'Kelola user, paket, pesanan, dan laporan.',
                    icon: _titleIcon,
                    selectedIndex: _idx,
                    onQuickTap: (i) => setState(() => _idx = i),
                    op: _op,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Container(
                      color: scheme.surface,
                      child: IndexedStack(index: _idx, children: _pages),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (v) => setState(() => _idx = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user_rounded),
            label: 'Approval',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Paket',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: scheme.primary.withAlpha(50),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'K',
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: size * 0.52,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int selectedIndex;
  final void Function(int index) onQuickTap;
  final Color Function(Color, double) op;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedIndex,
    required this.onQuickTap,
    required this.op,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget quickBtn({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final isActive = selectedIndex == index;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onQuickTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? op(scheme.primary, 0.12)
                  : op(scheme.surfaceContainerHighest, 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? op(scheme.primary, 0.35)
                    : op(scheme.outlineVariant, 0.25),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: op(scheme.outlineVariant, 0.35)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: scheme.shadow.withAlpha(18),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: op(scheme.primary, 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              quickBtn(
                index: 0,
                icon: Icons.verified_user_outlined,
                label: 'Approval',
              ),
              const SizedBox(width: 10),
              quickBtn(
                index: 1,
                icon: Icons.inventory_2_outlined,
                label: 'Paket',
              ),
              const SizedBox(width: 10),
              quickBtn(
                index: 2,
                icon: Icons.receipt_long_outlined,
                label: 'Pesanan',
              ),
              const SizedBox(width: 10),
              quickBtn(
                index: 3,
                icon: Icons.bar_chart_outlined,
                label: 'Laporan',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String name;
  final VoidCallback onAbout;
  final VoidCallback onLogout;
  final Color Function(Color, double) op;

  const _AdminDrawer({
    required this.name,
    required this.onAbout,
    required this.onLogout,
    required this.op,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      op(scheme.primary, 0.18),
                      op(scheme.tertiary, 0.14),
                    ],
                  ),
                  border: Border.all(color: op(scheme.outlineVariant, 0.35)),
                ),
                child: Row(
                  children: [
                    const _BrandMark(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Katering Pre-Order',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Admin: $name',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                onAbout();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: scheme.error),
              title: Text('Logout', style: TextStyle(color: scheme.error)),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text("Realtime Firebase"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(userName: 'Admin'),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Grafik Laporan"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChartScreen()),
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© ${DateTime.now().year} Katering Pre-Order',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
