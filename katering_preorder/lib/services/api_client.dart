import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String? token)
      : dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ));
}
