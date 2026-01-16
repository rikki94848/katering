import 'package:dio/dio.dart';
import 'api_config.dart';

class PublicMealService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.mealDbBase));

  Future<List<Map<String, dynamic>>> searchMeals(String keyword) async {
    final res = await dio.get('/search.php', queryParameters: {'s': keyword});
    final meals = res.data['meals'];
    if (meals == null) return [];
    return (meals as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> lookupMeal(String id) async {
    final res = await dio.get('/lookup.php', queryParameters: {'i': id});
    final meals = res.data['meals'];
    if (meals == null) return null;
    return (meals as List).first as Map<String, dynamic>;
  }
}
