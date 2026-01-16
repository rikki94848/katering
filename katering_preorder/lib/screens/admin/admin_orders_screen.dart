import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/order_service.dart';
import '../../state/session.dart';

class AdminOrdersScreen extends StatefulWidget {
  final Session session;
  const AdminOrdersScreen({super.key, required this.session});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _svc = OrderService();
  late Future<List<Map<String, dynamic>>> _future;

  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _future = _svc.adminOrders(widget.session.token);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _svc.adminOrders(widget.session.token);
    });
  }

  Future<void> _setStatus(int id, String status) async {
    try {
      await _svc.setOrderStatus(widget.session.token, id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status pesanan #$id diubah ke ${_statusLabel(status)}',
          ),
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ubah status: $e')));
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'approved':
        return 'Approved';
      case 'processing':
        return 'Processing';
      case 'delivering':
        return 'Delivering';
      case 'done':
        return 'Done';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'approved':
        return Icons.verified_rounded;
      case 'processing':
        return Icons.local_fire_department_rounded;
      case 'delivering':
        return Icons.local_shipping_rounded;
      case 'done':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  Color _statusColor(String s) {
    // warna status (biar chip-nya enak dilihat)
    switch (s) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'processing':
        return const Color(0xFFF59E0B);
      case 'delivering':
        return const Color(0xFF06B6D4);
      case 'done':
        return const Color(0xFF3B82F6);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  Future<void> _showStatusSheet({
    required int orderId,
    required String current,
  }) async {
    final options = const [
      'approved',
      'processing',
      'delivering',
      'done',
      'rejected',
    ];

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF7C3AED).withOpacity(.12),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ubah Status Pesanan #$orderId',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...options.map((s) {
                  final selected = (s == current);
                  final c = _statusColor(s);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? c.withOpacity(.7)
                            : Colors.transparent,
                        width: 1.2,
                      ),
                      color: selected
                          ? c.withOpacity(.10)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: c.withOpacity(.14),
                        child: Icon(_statusIcon(s), color: c),
                      ),
                      title: Text(
                        _statusLabel(s),
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        selected ? 'Status saat ini' : 'Tap untuk pilih',
                      ),
                      trailing: selected
                          ? Icon(Icons.check_rounded, color: c)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _setStatus(orderId, s);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kalau screen ini sudah dipakai di dalam Scaffold lain,
    // kamu boleh hapus Scaffold di bawah dan pakai body-nya saja.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient biar lebih “wah”
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D5EF8), // ungu
                  Color(0xFF22C55E), // hijau
                  Color(0xFF06B6D4), // cyan
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Overlay putih transparan supaya konten tetap terbaca
          Container(color: Colors.white.withOpacity(.78)),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_rounded, size: 44),
                          const SizedBox(height: 10),
                          Text(
                            'Gagal memuat pesanan',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text('${snap.error}', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Coba lagi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final items = snap.data ?? const [];
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SizedBox(height: 36),
                      _EmptyState(),
                      SizedBox(height: 200),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final o = items[i];

                    final id = (o['id'] is int)
                        ? o['id'] as int
                        : int.tryParse('${o['id']}') ?? 0;
                    final pkg = (o['package_name'] ?? '').toString();
                    final client = (o['client_name'] ?? '').toString();
                    final status = (o['status'] ?? 'pending').toString();

                    final totalRaw = o['total'];
                    final totalNum = (totalRaw is num)
                        ? totalRaw
                        : num.tryParse('$totalRaw') ?? 0;

                    final statusC = _statusColor(status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GlassCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () =>
                              _showStatusSheet(orderId: id, current: status),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon “badge”
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF7C3AED),
                                        Color(0xFF06B6D4),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '#$id',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _StatusChip(
                                            label: _statusLabel(status),
                                            color: statusC,
                                            icon: _statusIcon(status),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        pkg.isEmpty
                                            ? '(Paket tidak diketahui)'
                                            : pkg,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Client: ${client.isEmpty ? '-' : client}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black.withOpacity(.70),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Total + action
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.black.withOpacity(
                                                  .06,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.payments_rounded,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _rupiah.format(totalNum),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton.filledTonal(
                                            onPressed: () => _showStatusSheet(
                                              orderId: id,
                                              current: status,
                                            ),
                                            icon: const Icon(
                                              Icons.edit_rounded,
                                            ),
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
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.72),
        border: Border.all(color: Colors.white.withOpacity(.55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.08),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(.14),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                ),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Tarik ke bawah untuk refresh.\nPesanan baru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
