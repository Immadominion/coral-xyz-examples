import 'package:flutter/foundation.dart';
import '../services/solana_service.dart';
import '../models/todo_models.dart';

class TodoProvider extends ChangeNotifier {
  final SolanaService _solanaService = SolanaService();

  SolanaService get solanaService => _solanaService;

  bool get isConnected => _solanaService.isConnected;
  bool get isLoading => _solanaService.isLoading;
  String? get error => _solanaService.error;
  UserProfile? get userProfile => _solanaService.userProfile;
  List<TodoAccount> get todos => _solanaService.todos;
  String? get walletAddress => _solanaService.walletAddress;

  TodoProvider() {
    _solanaService.addListener(_onServiceChange);
  }

  void _onServiceChange() {
    notifyListeners();
  }

  Future<bool> initializeUser() async {
    final result = await _solanaService.initializeUser();
    return result != null;
  }

  Future<bool> addTodo(String content) async {
    if (content.trim().isEmpty) return false;
    final result = await _solanaService.addTodo(content.trim());
    return result != null;
  }

  Future<bool> markTodo(int todoIdx) async {
    final result = await _solanaService.markTodo(todoIdx);
    return result != null;
  }

  Future<bool> removeTodo(int todoIdx) async {
    final result = await _solanaService.removeTodo(todoIdx);
    return result != null;
  }

  Future<bool> checkUserInitialized() async {
    return await _solanaService.isUserInitialized();
  }

  Future<void> refresh() async {
    await _solanaService.refresh();
  }

  void clearError() {
    _solanaService.clearError();
  }

  @override
  void dispose() {
    _solanaService.removeListener(_onServiceChange);
    super.dispose();
  }
}
