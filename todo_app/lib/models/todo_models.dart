class UserProfile {
  const UserProfile({
    required this.authority,
    required this.lastTodo,
    required this.todoCount,
  });

  final String authority;
  final int lastTodo;
  final int todoCount;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      authority: json['authority'].toString(),
      lastTodo: json['lastTodo'] as int,
      todoCount: json['todoCount'] as int,
    );
  }
}

class TodoAccount {
  const TodoAccount({
    required this.authority,
    required this.idx,
    required this.content,
    required this.marked,
  });

  final String authority;
  final int idx;
  final String content;
  final bool marked;

  factory TodoAccount.fromJson(Map<String, dynamic> json) {
    return TodoAccount(
      authority: json['authority'].toString(),
      idx: json['idx'] as int,
      content: json['content'] as String,
      marked: json['marked'] as bool,
    );
  }
}
