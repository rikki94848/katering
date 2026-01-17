import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extra/firebase_monitor_screen.dart';
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

  // State untuk Filter Tanggal (Riwayat)
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

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

  // Fungsi Pilih Tanggal
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED), // Warna Ungu Tema
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // Update Status dengan Notifikasi Keren
  Future<void> _setStatus(int id, String status) async {
    try {
      await _svc.setOrderStatus(widget.session.token, id, status);
      if (!mounted) return;

      final color = _statusColor(status);
      final label = _statusLabel(status);
      final icon = _statusIcon(status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Status Diperbarui!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pesanan #$id sekarang "$label"',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          duration: const Duration(seconds: 3),
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

  // --- Helper Status ---
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
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFF7C3AED,
                        ).withValues(alpha: .12),
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
                              ? c.withValues(alpha: .7)
                              : Colors.transparent,
                          width: 1.2,
                        ),
                        color: selected
                            ? c.withValues(alpha: .10)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.withValues(alpha: .14),
                          child: Icon(_statusIcon(s), color: c),
                        ),
                        title: Text(
                          _statusLabel(s),
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w700,
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
          ),
        );
      },
    );
  }

  // Helper untuk memparse tanggal dari API (asumsi ada field created_at atau date)
  DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    return DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Pesanan'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF7C3AED),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF7C3AED),
            tabs: [
              Tab(text: 'Proses', icon: Icon(Icons.incomplete_circle_rounded)),
              Tab(text: 'Riwayat', icon: Icon(Icons.history_rounded)),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6D5EF8), Color(0xFF22C55E), Color(0xFF06B6D4)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Container(
                color: Colors.white.withValues(alpha: .85),
              ), // Overlay putih

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final allOrders = snap.data ?? [];

                  // --- LOGIC PEMISAHAN DATA ---
                  final activeOrders = allOrders.where((o) {
                    final s = (o['status'] ?? '').toString();
                    return s != 'done' && s != 'rejected';
                  }).toList();

                  final historyOrders = allOrders.where((o) {
                    final s = (o['status'] ?? '').toString();
                    // Cek status harus Done/Rejected
                    if (s != 'done' && s != 'rejected') return false;

                    // Cek Tanggal Filter
                    final date = _parseDate(
                      o['created_at'],
                    ); // Pastikan field tanggal sesuai API
                    return date.isAfter(
                          _startDate.subtract(const Duration(days: 1)),
                        ) &&
                        date.isBefore(_endDate.add(const Duration(days: 1)));
                  }).toList();
                  // ---------------------------

                  return TabBarView(
                    children: [
                      // TAB 1: ACTIVE
                      _buildOrderList(activeOrders, isHistory: false),

                      // TAB 2: HISTORY
                      Column(
                        children: [
                          // Widget Filter Tanggal
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _GlassCard(
                              child: InkWell(
                                onTap: _pickDateRange,
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range,
                                        color: Color(0xFF7C3AED),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Filter Tanggal",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              "${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // List History
                          Expanded(
                            child: _buildOrderList(
                              historyOrders,
                              isHistory: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BAGIAN BUILD LIST ---
  Widget _buildOrderList(
    List<Map<String, dynamic>> items, {
    required bool isHistory,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.history_toggle_off : Icons.inbox,
              size: 60,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              isHistory ? 'Tidak ada riwayat' : 'Tidak ada pesanan aktif',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final o = items[i];
          final id = (o['id'] is int)
              ? o['id'] as int
              : int.tryParse('${o['id']}') ?? 0;
          final pkg = (o['package_name'] ?? '').toString();
          final client = (o['client_name'] ?? '').toString();
          final status = (o['status'] ?? 'pending').toString();
          final totalNum = (o['total'] is num)
              ? o['total']
              : num.tryParse('${o['total']}') ?? 0;
          final statusC = _statusColor(status);

          // Data Mock Ulasan (Nanti ambil dari API: o['rating'], o['review'])
          final int? rating = o['rating'];
          final String? review = o['review'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GlassCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                // Admin TETAP BISA edit status kapan saja (untuk kasus offline)
                onTap: () => _showStatusSheet(orderId: id, current: status),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isHistory ? Colors.grey.shade200 : null,
                              gradient: isHistory
                                  ? null
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF7C3AED),
                                        Color(0xFF06B6D4),
                                      ],
                                    ),
                            ),
                            child: Icon(
                              isHistory
                                  ? Icons.receipt
                                  : Icons.receipt_long_rounded,
                              color: isHistory ? Colors.grey : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  pkg,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Client: $client',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: .70),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _rupiah.format(totalNum),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // --- TAMBAHAN: TOMBOL CHAT ---
                          IconButton(
                            tooltip: 'Diskusi',
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                size: 20,
                                color: Color(0xFF7C3AED)), // Warna Ungu
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    userName: 'Admin', // Nama pengirim (Admin)
                                    orderId: id, // ID Pesanan
                                  ),
                                ),
                              );
                            },
                          ),
                          // Tombol Edit (Icon Pencil)
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _showStatusSheet(orderId: id, current: status),
                          ),
                        ],
                      ),

                      // --- BAGIAN ULASAN (HANYA MUNCUL DI HISTORY) ---
                      if (isHistory && status == 'done') ...[
                        const Divider(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ulasan Pengguna:",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (rating != null) ...[
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < rating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review ?? "Tidak ada komentar",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ] else
                                const Text(
                                  "Belum memberikan ulasan",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
        color: Colors.white.withValues(alpha: .72),
        border: Border.all(color: Colors.white.withValues(alpha: .55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: .08),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: .14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
