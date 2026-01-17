import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../state/session.dart';
import '../extra/chart_screen.dart'; // Pastikan import ini ada

class SalesReportScreen extends StatefulWidget {
  final Session session;
  const SalesReportScreen({super.key, required this.session});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final _svc = OrderService();

  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now();

  Map<String, dynamic>? _data;
  bool _loading = false;
  String? _error;
  DateTime? _lastUpdated;

  final _dateFmt = DateFormat('yyyy-MM-dd');
  final _moneyFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _fmtDate(DateTime d) => _dateFmt.format(d);

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  num _asNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> _load() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _svc.salesReport(
        widget.session.token,
        _fmtDate(_from),
        _fmtDate(_to),
      );
      if (!mounted) return;

      setState(() {
        _data = res;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal load laporan: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _from,
    );
    if (picked == null) return;

    setState(() {
      _from = picked;
      if (_from.isAfter(_to)) _to = _from;
    });
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: _from,
      lastDate: DateTime.now(),
      initialDate: _to,
    );
    if (picked == null) return;

    setState(() => _to = picked);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final omzet = _moneyFmt.format(_asNum(_data?['omzet']));
    final ordersDone = _asInt(_data?['orders_done']);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Laporan Penjualan',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Periode ${_fmtDate(_from)} s/d ${_fmtDate(_to)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12),

          // Filter Card
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Periode', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Dari',
                          value: _fmtDate(_from),
                          onTap: _loading ? null : _pickFrom,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateButton(
                          label: 'Sampai',
                          value: _fmtDate(_to),
                          onTap: _loading ? null : _pickTo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _load,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_loading ? 'Memuat...' : 'Load'),
                        ),
                      ),
                    ],
                  ),
                  if (_lastUpdated != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Terakhir diperbarui: ${DateFormat('dd MMM yyyy, HH:mm').format(_lastUpdated!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Error state (inline)
          if (_error != null) ...[
            Card(
              elevation: 0,
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  'Terjadi kesalahan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _loading ? null : _load,
                  child: const Text('Coba lagi'),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Result
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _data == null && !_loading
                ? Card(
                    key: const ValueKey('empty'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_chart_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Belum ada data laporan untuk periode ini.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    key: const ValueKey('data'),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Omzet',
                              value: omzet,
                              icon: Icons.payments_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Orders Done',
                              value: ordersDone.toString(),
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // --- TOMBOL GRAFIK PENJUALAN ---
                      Card(
                        elevation: 2,
                        shadowColor: const Color(
                          0xFF7C3AED,
                        ).withValues(alpha: 0.3),
                        color: const Color(0xFF7C3AED), // Ungu Tema
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Logic Generate Dummy Data untuk Grafik
                            final days = _to.difference(_from).inDays + 1;
                            final totalOmzet = _asInt(_data?['omzet']);
                            List<int> dummyDailyData = [];

                            if (totalOmzet == 0) {
                              dummyDailyData = List.filled(days, 0);
                            } else {
                              final avg = totalOmzet / days;
                              for (int i = 0; i < days; i++) {
                                if (i == days - 1) {
                                  // Variasi acak sederhana
                                  double variation = (i % 2 == 0 ? 0.8 : 1.2);
                                  dummyDailyData.add((avg * variation).toInt());
                                } else {
                                  double variation = 0.5 + (0.05 * (i % 10));
                                  dummyDailyData.add((avg * variation).toInt());
                                }
                              }
                            }

                            // Navigasi ke ChartScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChartScreen(
                                  startDate: _from,
                                  endDate: _to,
                                  dailyOmzet: dummyDailyData,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bar_chart_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Visualisasi Grafik',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lihat tren penjualan dalam bentuk diagram',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------
                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tarik ke bawah untuk refresh (pull-to-refresh).',
                                  style: theme.textTheme.bodyMedium,
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
    );
  }
}

// ... Widget Helper ...
class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
