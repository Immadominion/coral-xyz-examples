class PollOption {
  final String label;
  final int id;
  final int votes;

  const PollOption({
    required this.label,
    required this.id,
    required this.votes,
  });

  double getVotePercentage(int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (votes / totalVotes) * 100;
  }

  @override
  String toString() => 'PollOption(label: $label, id: $id, votes: $votes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollOption &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          id == other.id &&
          votes == other.votes;

  @override
  int get hashCode => label.hashCode ^ id.hashCode ^ votes.hashCode;
}
