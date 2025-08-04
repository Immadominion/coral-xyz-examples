import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _contentController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkUserInitialized();
  }

  Future<void> _checkUserInitialized() async {
    final provider = context.read<TodoProvider>();
    final initialized = await provider.checkUserInitialized();
    setState(() {
      _isInitialized = initialized;
    });
    if (initialized) {
      provider.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo DApp (dart-coral-xyz)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TodoProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: Colors.red[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.clearError,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            );
          }

          if (!_isInitialized) {
            return _buildInitializationView(context, provider);
          }

          return _buildTodoView(context, provider);
        },
      ),
    );
  }

  Widget _buildInitializationView(BuildContext context, TodoProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Todo DApp!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Initialize your profile to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'Wallet: ${provider.walletAddress?.substring(0, 8)}...${provider.walletAddress?.substring(provider.walletAddress!.length - 8)}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final success = await provider.initializeUser();
              if (success) {
                setState(() {
                  _isInitialized = true;
                });
              }
            },
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Initialize Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoView(BuildContext context, TodoProvider provider) {
    return Column(
      children: [
        // User info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet: ${provider.walletAddress?.substring(0, 8)}...${provider.walletAddress?.substring(provider.walletAddress!.length - 8)}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Todos: ${provider.userProfile?.todoCount ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Add todo section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a new todo...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTodo(provider),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _addTodo(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ),

        // Todos list
        Expanded(
          child: provider.todos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checklist, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No todos yet!',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      Text(
                        'Add your first todo above',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.todos.length,
                  itemBuilder: (context, index) {
                    final todo = provider.todos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          todo.marked
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: todo.marked ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          todo.content,
                          style: TextStyle(
                            decoration: todo.marked
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.marked ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text('Todo #${todo.idx}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!todo.marked)
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () => provider.markTodo(todo.idx),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.removeTodo(todo.idx),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _addTodo(TodoProvider provider) async {
    if (_contentController.text.trim().isEmpty) return;

    final success = await provider.addTodo(_contentController.text);
    if (success) {
      _contentController.clear();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
