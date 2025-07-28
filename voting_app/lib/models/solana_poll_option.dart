class SolanaPollOption {
  const SolanaPollOption({
    required this.label,
    required this.id,
    required this.votes,
  });

  final String label;
  final int id;
  final int votes;

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() => {
    'label': label,
    'id': id,
    'votes': votes,
  };

  // Create from JSON
  factory SolanaPollOption.fromJson(Map<String, dynamic> json) => SolanaPollOption(
    label: json['label'] as String,
    id: json['id'] as int,
    votes: json['votes'] as int,
  );

  @override
  String toString() => 'SolanaPollOption(label: $label, id: $id, votes: $votes)';
}
