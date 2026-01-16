class Session {
  final String token;
  final String role;
  final bool approved;
  final String name;

  Session({required this.token, required this.role, required this.approved, required this.name});
}
