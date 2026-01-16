import 'api_client.dart';

class AdminService {
  Future<List<Map<String, dynamic>>> pendingUsers(String token) async {
    final api = ApiClient(token);
    final res = await api.dio.get('/admin/users/pending');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> approveUser(String token, int userId) async {
    final api = ApiClient(token);
    await api.dio.patch('/admin/users/$userId/approve');
  }
}
