import '../models/package.dart';
import 'api_client.dart';

class PackageService {
  Future<List<CateringPackage>> listPackages(String token) async {
    final api = ApiClient(token);
    final res = await api.dio.get('/packages');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map((j) => CateringPackage.fromJson(j)).toList();
  }

  // Admin
  Future<int> createPackage(String token, {required String name, required int price, required String description, required bool active}) async {
    final api = ApiClient(token);
    final res = await api.dio.post('/packages', data: {
      'name': name,
      'price_per_portion_per_day': price,
      'description': description,
      'is_active': active,
    });
    return res.data['id'];
  }

  Future<void> updatePackage(String token, int id, {required String name, required int price, required String description, required bool active}) async {
    final api = ApiClient(token);
    await api.dio.put('/packages/$id', data: {
      'name': name,
      'price_per_portion_per_day': price,
      'description': description,
      'is_active': active,
    });
  }

  Future<void> deletePackage(String token, int id) async {
    final api = ApiClient(token);
    await api.dio.delete('/packages/$id');
  }
}
