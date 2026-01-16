import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/package.dart';
import '../../services/order_service.dart';
import '../../state/session.dart';

class CreateOrderScreen extends StatefulWidget {
  final Session session;
  final CateringPackage pkg;
  const CreateOrderScreen({
    super.key,
    required this.session,
    required this.pkg,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _svc = OrderService();

  final _portions = TextEditingController(text: '1');
  final _address = TextEditingController();
  final _notes = TextEditingController();

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();

  int get _daysCount => _end.difference(_start).inDays + 1;

  int _toInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  int get _subtotal =>
      widget.pkg.pricePerPortionPerDay * _toInt(_portions) * _daysCount;

  int get _total => _subtotal.clamp(0, 1 << 30);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  void dispose() {
    _portions.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: _start,
    );
    if (picked == null) return;
    setState(() {
      _start = picked;
      if (_end.isBefore(_start)) _end = _start;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: _start,
      lastDate: _start.add(const Duration(days: 60)),
      initialDate: _end,
    );
    if (picked == null) return;
    setState(() => _end = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alamat wajib diisi')));
      return;
    }

    final portions = _toInt(_portions);
    if (portions <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jumlah porsi minimal 1')));
      return;
    }

    try {
      final res = await _svc.createOrder(
        widget.session.token,
        packageId: widget.pkg.id,
        startDate: _fmt(_start),
        endDate: _fmt(_end),
        portions: portions,
        address: _address.text.trim(),
        notes: _notes.text.trim(),

        // client TIDAK input ongkir & diskon -> default 0
        shippingFee: 0,
        discount: 0,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan dibuat (ID ${res['id']}). Status: ${res['status']}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Order - ${widget.pkg.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: cs.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    Icons.restaurant_menu,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pkg.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${widget.pkg.pricePerPortionPerDay} / porsi / hari',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStart,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text('Mulai: ${_fmt(_start)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEnd,
                  icon: const Icon(Icons.event_available_outlined),
                  label: Text('Selesai: ${_fmt(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Jumlah hari: $_daysCount',
            style: TextStyle(color: Colors.black.withValues(alpha: .60)),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _portions,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah porsi',
              prefixIcon: Icon(Icons.groups_2_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Alamat pengiriman',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal: Rp $_subtotal'),
                  const SizedBox(height: 6),
                  Text(
                    'Total: Rp $_total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ongkir & diskon ditentukan admin.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: .60),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Submit Pesanan'),
          ),
        ],
      ),
    );
  }
}
