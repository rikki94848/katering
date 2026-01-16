class Order {
  final int id;
  final String packageName;
  final String startDate; // YYYY-MM-DD
  final String endDate;   // YYYY-MM-DD
  final int daysCount;
  final int portions;
  final int shippingFee;
  final int discount;
  final int subtotal;
  final int total;
  final String status;

  Order({
    required this.id,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.portions,
    required this.shippingFee,
    required this.discount,
    required this.subtotal,
    required this.total,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'],
    packageName: (j['package_name'] ?? '').toString(),
    startDate: j['start_date'],
    endDate: j['end_date'],
    daysCount: j['days_count'],
    portions: j['portions'],
    shippingFee: j['shipping_fee'],
    discount: j['discount'],
    subtotal: j['subtotal'],
    total: j['total'],
    status: j['status'],
  );
}
