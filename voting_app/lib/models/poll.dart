import 'poll_option.dart';

class Poll {
  final bool finished;
  final String name;
  final String description;
  final List<PollOption> options;
  final List<String> voters; // Storing as strings for now (pubkey addresses)
  final String address; // Poll account address

  const Poll({
    required this.finished,
    required this.name,
    required this.description,
    required this.options,
    required this.voters,
    required this.address,
  });

  int get totalVotes => options.fold(0, (sum, option) => sum + option.votes);

  bool get hasVotes => totalVotes > 0;

  PollOption? getOptionById(int id) {
    try {
      return options.firstWhere((option) => option.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasUserVoted(String userPublicKey) {
    return voters.contains(userPublicKey);
  }

  List<PollOption> get sortedOptions {
    final sorted = List<PollOption>.from(options);
    sorted.sort((a, b) => b.votes.compareTo(a.votes));
    return sorted;
  }

  PollOption? get leadingOption {
    if (options.isEmpty) return null;
    return sortedOptions.first;
  }

  @override
  String toString() =>
      'Poll(name: $name, finished: $finished, totalVotes: $totalVotes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Poll &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          finished == other.finished;

  @override
  int get hashCode => name.hashCode ^ description.hashCode ^ finished.hashCode;
}
