import 'package:flutter/material.dart';
import '../../services/public_meal_service.dart';
// Import map dan chart dihapus karena tidak boleh ada di sini

class PublicMenuScreen extends StatefulWidget {
  const PublicMenuScreen({super.key});

  @override
  State<PublicMenuScreen> createState() => _PublicMenuScreenState();
}

class _PublicMenuScreenState extends State<PublicMenuScreen> {
  final _svc = PublicMealService();
  final _q = TextEditingController(text: 'chicken');

  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _q.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kata kunci dulu ya')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _svc.searchMeals(query);
      if (!mounted) return;
      setState(() => _items = res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load public API: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(Map<String, dynamic> m) {
    final title = (m['strMeal'] ?? '').toString();
    final area = (m['strArea'] ?? '-').toString();
    final category = (m['strCategory'] ?? '-').toString();
    final thumb = (m['strMealThumb'] ?? '').toString();
    final source = (m['strSource'] ?? '').toString();
    final yt = (m['strYoutube'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _GlassCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (thumb.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black.withValues(alpha: .06),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              _InfoRow(left: 'Area', right: area),
              const SizedBox(height: 6),
              _InfoRow(left: 'Kategori', right: category),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (source.isEmpty && yt.isEmpty)
                          ? null
                          : () {
                              final link = source.isNotEmpty ? source : yt;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Link: $link')),
                              );
                            },
                      icon: const Icon(Icons.link),
                      label: const Text('Lihat sumber'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Oke'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _search();
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
              colors: [
                Color(0xFF0F172A), // navy
                Color(0xFF6D28D9), // purple
                Color(0xFF06B6D4), // cyan
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // Overlay for readability
        Container(color: Colors.white.withValues(alpha: .90)),

        RefreshIndicator(
          onRefresh: _search,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              _GlassCard(
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
                          colors: [Color(0xFF6D28D9), Color(0xFF06B6D4)],
                        ),
                      ),
                      child: const Icon(Icons.public, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inspirasi Menu',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Cari dari TheMealDB • tap untuk detail',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: .60),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : _search,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Search bar
              _GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _q,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _loading ? null : _search(),
                        decoration: InputDecoration(
                          hintText:
                              'Cari menu (misal: chicken, pasta, soup...)',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          suffixIcon: _q.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => setState(() => _q.clear()),
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _loading ? null : _search,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(_loading ? '...' : 'Cari'),
                    ),
                  ],
                ),
              ),

              // --- BAGIAN FITUR TAMBAHAN (MAP & CHART) SUDAHDIHAPUS ---
              const SizedBox(height: 10),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 10),

              if (!_loading && _items.isEmpty)
                _GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.search_off),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tidak ada hasil. Coba kata kunci lain.',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: .70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),

              // Result list cards
              ..._items.map((m) {
                final title = (m['strMeal'] ?? '').toString();
                final area = (m['strArea'] ?? '').toString();
                final category = (m['strCategory'] ?? '').toString();
                final thumb = (m['strMealThumb'] ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _openDetail(m),
                    borderRadius: BorderRadius.circular(18),
                    child: _GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 72,
                              height: 72,
                              color: Colors.black.withValues(alpha: .05),
                              child: thumb.isEmpty
                                  ? const Icon(Icons.fastfood_outlined)
                                  : Image.network(
                                      thumb,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (area.isNotEmpty)
                                      _Chip(
                                        text: area,
                                        icon: Icons.place_outlined,
                                      ),
                                    if (category.isNotEmpty)
                                      _Chip(
                                        text: category,
                                        icon: Icons.category_outlined,
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
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ... helper classes (_GlassCard, _Chip, _InfoRow) tetap sama ...

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

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFFEEF2FF),
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black.withValues(alpha: .70)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String left;
  final String right;

  const _InfoRow({required this.left, required this.right});

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
        Text(right, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
