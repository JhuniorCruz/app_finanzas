class UserProfile {
  final String name;
  final String currency; // p.ej. "PEN"
  const UserProfile({required this.name, required this.currency});

  UserProfile copyWith({String? name, String? currency}) =>
      UserProfile(name: name ?? this.name, currency: currency ?? this.currency);
}
