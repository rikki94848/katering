class CateringPackage {
  final int id;
  final String name;
  final int pricePerPortionPerDay;
  final String description;
  final bool isActive;

  CateringPackage({
    required this.id,
    required this.name,
    required this.pricePerPortionPerDay,
    required this.description,
    required this.isActive,
  });

  factory CateringPackage.fromJson(Map<String, dynamic> j) {
    final raw = j['is_active'];
    final active = (raw == null)
        ? true
        : (raw == true || raw == 1 || raw == '1');

    return CateringPackage(
      id: j['id'],
      name: j['name'],
      pricePerPortionPerDay: j['price_per_portion_per_day'],
      description: (j['description'] ?? '').toString(),
      isActive: active,
    );
  }
}
