class AuthResult {
  final String token;
  final String role; // 'client' | 'admin'
  final bool isApproved;
  final String name;

  AuthResult({required this.token, required this.role, required this.isApproved, required this.name});

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
    token: j['token'],
    role: j['role'],
    isApproved: j['isApproved'] == true,
    name: j['name'] ?? '',
  );
}
