class Settings {
  final String systemPrompt;
  final DateTime promptUpdatedAt;

  Settings({
    required this.systemPrompt,
    required this.promptUpdatedAt,
  });

  Settings copyWith({
    String? systemPrompt,
    DateTime? promptUpdatedAt,
  }) {
    return Settings(
      systemPrompt: systemPrompt ?? this.systemPrompt,
      promptUpdatedAt: promptUpdatedAt ?? this.promptUpdatedAt,
    );
  }
}
