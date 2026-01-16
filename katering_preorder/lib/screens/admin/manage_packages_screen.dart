import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/package.dart';
import '../../services/package_service.dart';
import '../../state/session.dart';

class ManagePackagesScreen extends StatefulWidget {
  final Session session;
  const ManagePackagesScreen({super.key, required this.session});

  @override
  State<ManagePackagesScreen> createState() => _ManagePackagesScreenState();
}

class _ManagePackagesScreenState extends State<ManagePackagesScreen> {
  final _svc = PackageService();
  late Future<List<CateringPackage>> _future;

  bool _busy = false;

  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _future = _svc.listPackages(widget.session.token);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _svc.listPackages(widget.session.token);
    });
  }

  void _setBusy(bool v) {
    if (!mounted) return;
    setState(() => _busy = v);
  }

  Future<void> _openForm({CateringPackage? pkg}) async {
    final nameCtrl = TextEditingController(text: pkg?.name ?? '');
    final priceCtrl = TextEditingController(
      text: (pkg?.pricePerPortionPerDay ?? 10000).toString(),
    );
    final descCtrl = TextEditingController(text: pkg?.description ?? '');

    bool active = pkg?.isActive ?? true;

    // ✅ bottom sheet hanya mengembalikan data (TANPA API call)
    final draft = await showModalBottomSheet<_PkgDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context2, setState2) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: MediaQuery.of(context2).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                          ),
                        ),
                        child: Icon(
                          pkg == null ? Icons.add_rounded : Icons.edit_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pkg == null ? 'Tambah Paket' : 'Edit Paket',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _ActiveChip(active: active),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama paket',
                      prefixIcon: Icon(Icons.restaurant_menu_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga / porsi / hari',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: descCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context2,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      value: active,
                      onChanged: (v) => setState2(() => active = v),
                      title: const Text('Paket aktif'),
                      subtitle: Text(
                        active
                            ? 'Ditampilkan ke client'
                            : 'Disembunyikan dari client',
                      ),
                      secondary: Icon(
                        active
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_rounded),
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            final price =
                                int.tryParse(priceCtrl.text.trim()) ?? 0;
                            final desc = descCtrl.text.trim();

                            if (name.isEmpty) {
                              // pakai context2 aman (masih dalam sheet)
                              ScaffoldMessenger.of(context2).showSnackBar(
                                const SnackBar(
                                  content: Text('Nama paket wajib diisi'),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(
                              ctx,
                              _PkgDraft(
                                id: pkg?.id,
                                name: name,
                                price: price,
                                description: desc,
                                active: active,
                              ),
                            );
                          },
                          label: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();

    // kalau cancel
    if (draft == null) return;

    // ✅ API call dilakukan di screen utama (AMAN, tidak red screen)
    _setBusy(true);
    try {
      if (draft.id == null) {
        await _svc.createPackage(
          widget.session.token,
          name: draft.name,
          price: draft.price,
          description: draft.description,
          active: draft.active,
        );
      } else {
        await _svc.updatePackage(
          widget.session.token,
          draft.id!,
          name: draft.name,
          price: draft.price,
          description: draft.description,
          active: draft.active,
        );
      }

      if (!mounted) return;
      await _reload();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            draft.id == null ? 'Paket ditambahkan' : 'Paket diperbarui',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _confirmDelete(CateringPackage p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus paket?'),
        content: Text('Yakin ingin menghapus "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    _setBusy(true);
    try {
      await _svc.deletePackage(widget.session.token, p.id);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paket dihapus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    } finally {
      _setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Paket'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Paket'),
      ),
      body: Stack(
        children: [
          // gradient background
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
          Container(color: Colors.white.withValues(alpha: .80)),

          FutureBuilder<List<CateringPackage>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }

              final items = snap.data ?? const [];

              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SizedBox(height: 28),
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
                    final p = items[i];
                    final active = p.isActive;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GlassCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openForm(pkg: p),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    Icons.fastfood_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          _ActiveChip(active: active),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_rupiah.format(p.pricePerPortionPerDay)} / porsi / hari',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black.withValues(
                                            alpha: .75,
                                          ),
                                        ),
                                      ),
                                      if (p.description.trim().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          p.description,
                                          style: TextStyle(
                                            color: Colors.black.withValues(
                                              alpha: .65,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _openForm(pkg: p),
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                              ),
                                              label: const Text('Edit'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () =>
                                                  _confirmDelete(p),
                                              icon: const Icon(
                                                Icons.delete_rounded,
                                              ),
                                              label: const Text('Hapus'),
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

          // overlay loading
          if (_busy) const _BusyOverlay(),
        ],
      ),
    );
  }
}

// ========= helper =========

class _PkgDraft {
  final int? id;
  final String name;
  final int price;
  final String description;
  final bool active;

  _PkgDraft({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.active,
  });
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

class _ActiveChip extends StatelessWidget {
  final bool active;
  const _ActiveChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final c = active ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withValues(alpha: .14),
        border: Border.all(color: c.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            size: 16,
            color: c,
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: c,
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
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada paket',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan tombol "Tambah Paket" untuk membuat paket baru.\nTarik ke bawah untuk refresh.',
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
