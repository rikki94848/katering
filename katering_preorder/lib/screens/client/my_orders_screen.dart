import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../state/session.dart';

class MyOrdersScreen extends StatefulWidget {
  final Session session;
  const MyOrdersScreen({super.key, required this.session});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _svc = OrderService();
  late Future<List<Order>> _future;

  final _money = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _prettyDate = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _future = _svc.myOrders(widget.session.token);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _svc.myOrders(widget.session.token);
    });
  }

  DateTime? _parseDate(String s) {
    try {
      // backend format: yyyy-MM-dd
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _fmtDateRange(String start, String end) {
    final a = _parseDate(start);
    final b = _parseDate(end);
    if (a == null || b == null) return '$start s/d $end';
    return '${_prettyDate.format(a)}  —  ${_prettyDate.format(b)}';
  }

  // Status color mapping
  ({Color bg, Color fg, IconData icon, String label}) _statusStyle(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'done') {
      return (
        bg: const Color(0xFFDCFCE7),
        fg: const Color(0xFF166534),
        icon: Icons.check_circle,
        label: 'Selesai',
      );
    }
    if (s == 'approved') {
      return (
        bg: const Color(0xFFDBEAFE),
        fg: const Color(0xFF1D4ED8),
        icon: Icons.verified,
        label: 'Approved',
      );
    }
    if (s == 'processing') {
      return (
        bg: const Color(0xFFFFEDD5),
        fg: const Color(0xFF9A3412),
        icon: Icons.autorenew,
        label: 'Diproses',
      );
    }
    if (s == 'delivering') {
      return (
        bg: const Color(0xFFE0E7FF),
        fg: const Color(0xFF3730A3),
        icon: Icons.local_shipping,
        label: 'Dikirim',
      );
    }
    if (s == 'rejected') {
      return (
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFF991B1B),
        icon: Icons.cancel,
        label: 'Ditolak',
      );
    }
    return (
      bg: const Color(0xFFE5E7EB),
      fg: const Color(0xFF111827),
      icon: Icons.info,
      label: raw,
    );
  }

  void _showDetail(Order o) {
    final st = _statusStyle(o.status);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _GlassCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${o.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusPill(
                    bg: st.bg,
                    fg: st.fg,
                    icon: st.icon,
                    text: st.label,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _InfoRow(left: 'Paket', right: o.packageName),
              const SizedBox(height: 6),
              _InfoRow(
                left: 'Periode',
                right: _fmtDateRange(o.startDate, o.endDate),
              ),
              const SizedBox(height: 6),
              _InfoRow(left: 'Porsi / hari', right: '${o.portions}'),
              const SizedBox(height: 6),
              _InfoRow(
                left: 'Total',
                right: _money.format(o.total),
                bold: true,
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFF06B6D4), Color(0xFF22C55E)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // White overlay (readability)
        Container(color: Colors.white.withValues(alpha: .88)),

        FutureBuilder<List<Order>>(
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
                        const Icon(Icons.error_outline, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat pesanan:\n${snap.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final items = snap.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long, size: 34),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pesanan kamu akan muncul di sini setelah checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: .65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                itemCount: items.length + 1,
                itemBuilder: (context, idx) {
                  if (idx == 0) {
                    // Header
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
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
                                Icons.receipt_long,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pesanan Saya',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${items.length} pesanan • tarik ke bawah untuk refresh',
                                    style: TextStyle(
                                      color: Colors.black.withValues(
                                        alpha: .60,
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

                  final o = items[idx - 1];
                  final st = _statusStyle(o.status);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showDetail(o),
                      borderRadius: BorderRadius.circular(18),
                      child: _GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // left icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: st.bg,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: .06),
                                ),
                              ),
                              child: Icon(st.icon, color: st.fg),
                            ),
                            const SizedBox(width: 12),

                            // content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '#${o.id} • ${o.packageName}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusPill(
                                        bg: st.bg,
                                        fg: st.fg,
                                        icon: st.icon,
                                        text: st.label,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range_outlined,
                                        size: 16,
                                        color: Colors.black.withValues(
                                          alpha: .55,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _fmtDateRange(o.startDate, o.endDate),
                                          style: TextStyle(
                                            color: Colors.black.withValues(
                                              alpha: .70,
                                            ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.restaurant_outlined,
                                        size: 16,
                                        color: Colors.black.withValues(
                                          alpha: .55,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Porsi: ${o.portions}',
                                        style: TextStyle(
                                          color: Colors.black.withValues(
                                            alpha: .70,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.payments_outlined,
                                        size: 16,
                                        color: Colors.black.withValues(
                                          alpha: .55,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _money.format(o.total),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black.withValues(alpha: .45),
                            ),
                          ],
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
    );
  }
}

// ================= helpers =================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: .74),
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

class _StatusPill extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String text;

  const _StatusPill({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;

  const _InfoRow({required this.left, required this.right, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              color: Colors.black.withValues(alpha: .65),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            fontSize: bold ? 14.5 : 13.5,
          ),
        ),
      ],
    );
  }
}
