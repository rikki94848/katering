import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../state/session.dart';
import '../extra/firebase_monitor_screen.dart';

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

  Future<void> _confirmReceived(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pesanan Diterima?'),
        content: const Text(
          'Pastikan katering sudah sampai.\nPesanan akan dipindah ke Riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Diterima'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _svc.setOrderStatus(widget.session.token, id, 'done');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih! Pesanan selesai.')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showRatingDialog(int id) async {
    int rating = 5;
    final noteCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Beri Ulasan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bagaimana rasa makanannya?'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tulis masukan Anda...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    // Simulasi kirim review
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ulasan terkirim!')),
                    );
                    _reload();
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _fmtDateRange(String start, String end) {
    final a = _parseDate(start);
    final b = _parseDate(end);
    if (a == null || b == null) return '$start s/d $end';
    return '${_prettyDate.format(a)} — ${_prettyDate.format(b)}';
  }

  ({Color bg, Color fg, IconData icon, String label}) _statusStyle(String raw) {
    final s = raw.toLowerCase().trim();
    // Gunakan if { return ... } dengan kurung kurawal
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pesanan Saya",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Berjalan'),
                      Tab(text: 'Riwayat'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Gagal: ${snap.error}'));
                }

                final all = snap.data ?? [];
                final active = all
                    .where((x) => x.status != 'done' && x.status != 'rejected')
                    .toList();
                final history = all
                    .where((x) => x.status == 'done' || x.status == 'rejected')
                    .toList();

                return TabBarView(
                  children: [
                    // NAMA FUNGSI SUDAH DIPERBAIKI (huruf kecil)
                    _buildOrderList(
                      items: active,
                      isHistory: false,
                      onAction: _confirmReceived,
                    ),
                    _buildOrderList(
                      items: history,
                      isHistory: true,
                      onAction: _showRatingDialog,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // NAMA FUNGSI DIGANTI DARI _OrderList JADI _buildOrderList
  Widget _buildOrderList({
    required List<Order> items,
    required bool isHistory,
    required Function(int) onAction,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.history : Icons.soup_kitchen,
              size: 50,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              isHistory ? 'Belum ada riwayat' : 'Tidak ada pesanan aktif',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final o = items[i];
          final st = _statusStyle(o.status);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${o.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      constraints:
                          const BoxConstraints(), // Biar icon tidak makan tempat
                      padding: const EdgeInsets.only(left: 8),
                      icon: const Icon(Icons.chat_bubble_rounded,
                          size: 18, color: Color(0xFF7C3AED)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              // Ganti dengan nama user asli dari session jika ada
                              // contoh: widget.session.userName
                              userName: 'Client',
                              orderId: o.id,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: st.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(st.icon, size: 12, color: st.fg),
                          const SizedBox(width: 4),
                          Text(
                            st.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: st.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  o.packageName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmtDateRange(o.startDate, o.endDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _money.format(o.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if ((!isHistory && o.status == 'delivering') ||
                    (isHistory && o.status == 'done')) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: isHistory
                        ? OutlinedButton.icon(
                            onPressed: () => onAction(o.id),
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: const Text("Beri Ulasan"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7C3AED)),
                              foregroundColor: const Color(0xFF7C3AED),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: () => onAction(o.id),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text("Pesanan Diterima"),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                            ),
                          ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
