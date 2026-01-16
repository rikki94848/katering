import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  Future<Map<String, dynamic>> createOrder(String token, {
    required int packageId,
    required String startDate,
    required String endDate,
    required int portions,
    required String address,
    String notes = '',
    int shippingFee = 0,
    int discount = 0,
  }) async {
    final api = ApiClient(token);
    final res = await api.dio.post('/orders', data: {
      'package_id': packageId,
      'start_date': startDate,
      'end_date': endDate,
      'portions': portions,
      'delivery_address': address,
      'notes': notes,
      'shipping_fee': shippingFee,
      'discount': discount,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<Order>> myOrders(String token) async {
    final api = ApiClient(token);
    final res = await api.dio.get('/orders/my');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map((j) => Order.fromJson(j)).toList();
  }

  // Admin
  Future<List<Map<String, dynamic>>> adminOrders(String token) async {
    final api = ApiClient(token);
    final res = await api.dio.get('/orders/admin');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> setOrderStatus(String token, int orderId, String status) async {
    final api = ApiClient(token);
    await api.dio.patch('/orders/admin/$orderId/status', data: {'status': status});
  }

  Future<Map<String, dynamic>> salesReport(String token, String from, String to) async {
    final api = ApiClient(token);
    final res = await api.dio.get('/orders/admin/reports/sales', queryParameters: {'from': from, 'to': to});
    return res.data as Map<String, dynamic>;
  }
}
