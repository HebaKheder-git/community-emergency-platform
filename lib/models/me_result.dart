class MeResult {
  final int id;
  final String? name;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  const MeResult({
    required this.id,
    required this.email,
    required this.roles,
    required this.permissions,
    this.name,
  });

  bool hasRole(String role) => roles.contains(role);

  /// Convenience for the "trusted" vs "member" distinction your scenario
  /// cares about in the app (trusted user unlocks the emergency button
  /// and SOS features; a plain member does not).
  bool get isTrusted => roles.contains('trusted') || roles.contains('rescuer');
}