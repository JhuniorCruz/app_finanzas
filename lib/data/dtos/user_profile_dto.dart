class UserProfileDto {
  final String name;
  final String currency;
  const UserProfileDto({required this.name, required this.currency});

  factory UserProfileDto.fromMap(Map<String, dynamic> m) =>
      UserProfileDto(name: m['name'] ?? '', currency: m['currency'] ?? 'PEN');

  Map<String, dynamic> toMap() => {'name': name, 'currency': currency};
}
