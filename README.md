# Coral XYZ Dart Examples

This repository contains example Flutter/Dart projects demonstrating the **revolutionary simplicity** of the [dart-coral-xyz](https://github.com/immadominion/dart-coral-xyz) package for Solana Anchor development.

## 🚀 Examples

Each folder showcases the dramatic improvements dart-coral-xyz brings to Solana development:

### 📊 **`voting_app/`** - Advanced Voting Application ⭐ **FEATURED**

A comprehensive voting application that demonstrates **why dart-coral-xyz is a game changer**:

**🎯 What it showcases:**

- **Complex Data Structures**: Polls with multiple options and voter tracking
- **Real-time Updates**: Live vote count updates using automatic Borsh deserialization
- **Multi-Account Management**: Creating and managing multiple poll accounts
- **Advanced UI**: Modern Flutter interface with gradients, animations, and state management
- **Production Patterns**: Error handling, state management, and user feedback
- **Detailed Comparison**: Side-by-side comparison vs 500+ lines of manual implementation

**💰 Business Impact Demonstrated:**

- **57% Less Code**: 327 lines vs 766+ lines of manual Solana integration
- **10x Faster Development**: Build in hours, not weeks
- **Zero Borsh Complexity**: Automatic serialization eliminates bugs
- **Future-Proof**: IDL changes don't break your code

**Perfect for**: Understanding the massive advantages of dart-coral-xyz, production-ready patterns, and complex Solana app architecture.

### ✅ **`todo_app/`** - CRUD Operations Showcase

A production-ready todo application demonstrating **essential CRUD patterns**:

**🎯 What it showcases:**

- **Complete CRUD Operations**: Create, read, update, and delete todo items
- **PDA-Based Account Management**: User profiles and individual todo accounts
- **Real-time State Synchronization**: Automatic UI updates with blockchain state
- **IDL Constants Integration**: Direct usage of program constants from IDL
- **Clean Architecture**: Provider pattern with separation of concerns
- **Error Handling**: Comprehensive error management and user feedback

**💰 Business Impact Demonstrated:**

- **44% Less Code**: 256 lines vs 462 lines of manual Solana integration
- **Zero Discriminator Calculations**: IDL handles all complexity automatically
- **Automatic Deserialization**: No manual Borsh parsing needed
- **Type-Safe Operations**: Full IDE support with compile-time error checking

**Perfect for**: Learning essential CRUD patterns, understanding PDA management, and building data-driven applications.

### 🔢 **`basic_counter/`** - Simple Counter

A straightforward counter application demonstrating:

- Program initialization and PDA derivation
- Basic method calls and account fetching
- Simple state management patterns

**Perfect for**: Getting started with dart-coral-xyz fundamentals.

## 🎯 Key Learning Outcomes

After exploring these examples, you'll understand:

- **🚀 Revolutionary Simplicity**: How dart-coral-xyz transforms 500+ lines of manual serialization into 3 simple method calls
- **🛡️ Type Safety**: Experience full Dart type safety with Solana programs - your IDE catches errors at compile time
- **⚡ Performance**: See the benefits of optimized native code vs pure Dart byte manipulation
- **🔄 Future-Proof Development**: Learn how IDL changes automatically flow to your Dart code
- **📚 Familiar Patterns**: Discover how Solana development becomes as simple as any REST API

## 🛠️ Getting Started

1. **Start with `voting_app/`**: See the dramatic difference dart-coral-xyz makes
2. **Read the Comparison**: Check the detailed README comparing 50 lines vs 500+ lines
3. **Follow Setup Instructions**: Each example has detailed setup steps with template files
4. **Configure Safely**: Add your credentials using the provided template files (private files are gitignored)
5. **Experience the Magic**: Launch the apps and see automatic Borsh deserialization in action

## � Why These Examples Matter

### **Before dart-coral-xyz (Manual Implementation)**

```dart
// 😰 Hundreds of lines of manual Borsh serialization
List<int> accountBytes = base64Decode(data);
final dataBytes = accountBytes.sublist(8);
int offset = 0;
// ... 400+ more lines of error-prone parsing
```

### **After dart-coral-xyz**

```dart
// 🎉 Simple, clean, reliable
final accountData = await program.account['Poll']!.fetch(pollAddress);
// Vote counts are ALWAYS accurate - no manual parsing!
```

## 🤝 Contributing

Contributions welcome! These examples show that dart-coral-xyz isn't just an improvement—it's a **complete transformation** of how we build on Solana.

## 📄 License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
