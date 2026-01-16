import 'api_client.dart';
import 'local_storage.dart';
import '../models/auth_result.dart';

class AuthService {
  Future<void> register(String name, String email, String password) async {
    final api = ApiClient(null);
    await api.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<AuthResult> login(String email, String password) async {
    final api = ApiClient(null);
    final res = await api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final result = AuthResult.fromJson(res.data);
    await LocalStorage.saveSession(
      token: result.token,
      role: result.role,
      approved: result.isApproved,
      name: result.name,
    );
    return result;
  }
}
