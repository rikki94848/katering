import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../state/session.dart';

class PendingUsersScreen extends StatefulWidget {
  final Session session;
  const PendingUsersScreen({super.key, required this.session});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final _svc = AdminService();
  late Future<List<Map<String, dynamic>>> _future;

  bool _busy = false;

  // ✅ search
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _all = [];
  String _q = '';

  @override
  void initState() {
    super.initState();
    _future = _svc.pendingUsers(widget.session.token);
    _reload();

    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim().toLowerCase();
      if (v == _q) return;
      setState(() => _q = v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final fut = _svc.pendingUsers(widget.session.token);

    setState(() {
      _future = fut; // ✅ callback setState return void (bukan Future)
    });

    try {
      final data = await fut;
      if (!mounted) return;

      setState(() {
        _all = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load: $e')));
    }
  }

  void _setBusy(bool v) {
    if (!mounted) return;
    setState(() => _busy = v);
  }

  int _asId(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<void> _approve(Map<String, dynamic> u) async {
    final name = (u['name'] ?? '').toString();
    final email = (u['email'] ?? '').toString();
    final id = _asId(u['id']);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve user?'),
        content: Text('Approve akun:\n$name\n$email'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Approve'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    _setBusy(true);
    try {
      await _svc.approveUser(widget.session.token, id);
      if (!mounted) return;

      await _reload();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User "$name" berhasil di-approve')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal approve: $e')));
    } finally {
      _setBusy(false);
    }
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

  List<Map<String, dynamic>> _filtered() {
    if (_q.isEmpty) return _all;
    return _all.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(_q) || email.contains(_q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Pending'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
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
          // Soft overlay
          Container(color: Colors.white.withValues(alpha: .80)),

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
                          const Text(
                            'Gagal memuat user pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('${snap.error}', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _busy ? null : _reload,
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

              final items = _filtered();

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
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
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Cari nama / email...',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              tooltip: 'Clear',
                              onPressed: () {
                                _searchCtrl.clear();
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_all.isEmpty) ...const [
                      _EmptyState(message: 'Tidak ada user pending'),
                      SizedBox(height: 240),
                    ] else if (items.isEmpty) ...const [
                      _EmptyState(message: 'Tidak ada hasil yang cocok'),
                      SizedBox(height: 240),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 10),
                        child: Text(
                          'Hasil: ${items.length} user',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black.withValues(alpha: .65),
                          ),
                        ),
                      ),
                      ...items.map((u) {
                        final name = (u['name'] ?? '').toString();
                        final email = (u['email'] ?? '').toString();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    alignment: Alignment.center,
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
                                    child: Text(
                                      _initials(name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.isEmpty ? '(Tanpa Nama)' : name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.mail_outline_rounded,
                                              size: 16,
                                              color: Colors.black.withValues(
                                                alpha: .65,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                email,
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withValues(alpha: .70),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: _busy
                                                ? null
                                                : () => _approve(u),
                                            icon: const Icon(
                                              Icons.verified_rounded,
                                            ),
                                            label: const Text('Approve'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
          ),

          if (_busy) const _BusyOverlay(),
        ],
      ),
    );
  }
}

// ===== UI helpers =====

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

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: Colors.black.withValues(alpha: .18),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Memproses...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

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
                Icons.person_off_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Tarik ke bawah untuk refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withValues(alpha: .65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
