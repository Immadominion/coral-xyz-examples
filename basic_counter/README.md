# Coral XYZ Anchor Dart Client Example

This Flutter app demonstrates how to interact with Solana programs using the [Coral XYZ Anchor Dart client](https://github.com/coral-xyz/dart-coral-xyz). This example shows a simple counter program that can be initialized and incremented on the Solana blockchain.

## Why This Approach?

This example uses a private key wallet approach instead of Mobile Wallet Adapter (MWA) for the following reasons:

1. **iOS Simulator Compatibility**: MWA doesn't work in iOS simulators, making development difficult
2. **Cross-Platform Development**: Works consistently across all platforms during development
3. **Simplified Testing**: No external wallet dependencies for automated testing
4. **Educational Purpose**: Shows direct integration patterns for understanding the underlying mechanics

> **Note**: For production applications, consider using Mobile Wallet Adapter or other secure wallet connection methods.

## Comparison with TypeScript Implementation

This Dart implementation closely mirrors the TypeScript Coral XYZ Anchor client patterns:

### Similarities:

- **Program Initialization**: Both use IDL loading and program instantiation
- **PDA Derivation**: Both use `findProgramAddress`/`findProgramAddressSync` for PDA calculation
- **Method Calls**: Both use the `.methods.methodName()` pattern for program interactions
- **Account Fetching**: Both use `.account.accountName.fetch()` for reading account data
- **Provider Pattern**: Both use connection + wallet + provider structure

### Key Differences:

| Aspect              | TypeScript                                    | Dart                                                 |
| ------------------- | --------------------------------------------- | ---------------------------------------------------- |
| **PDA Derivation**  | `PublicKey.findProgramAddressSync()`          | `await PublicKey.findProgramAddress()`               |
| **Method Calls**    | `program.methods.increment(new anchor.BN(1))` | `(program.methods as dynamic).increment(BigInt.one)` |
| **Account Access**  | `program.account.counter.fetch()`             | `program.account['Counter']!.fetch()`                |
| **BigInt Handling** | `new anchor.BN(1)`                            | `BigInt.one`                                         |
| **Async Pattern**   | Promise-based                                 | Future-based with async/await                        |

The Dart client currently requires dynamic casting for method calls due to type system differences, but the core patterns remain consistent.

## Setup Instructions

### 1. Install Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  coral_xyz_anchor: ^latest_version
  bs58: ^1.0.2
  solana: ^0.31.2+1
```

### 2. Configure Your Private Key

1. **Copy the example file**:

   ```bash
   cp lib/private.example.dart lib/private.dart
   ```

2. **Generate a new keypair** (if needed):

   ```bash
   solana-keygen new --outfile ~/my-solana-key.json
   ```

3. **Get your private key in base58 format**:

   ```bash
   # Get public key
   solana-keygen pubkey ~/my-solana-key.json

   # For private key conversion, use a Solana tool or wallet
   ```

4. **Update `lib/private.dart`**:

   ```dart
   const String PROGRAM_ID = 'YOUR_PROGRAM_ID_HERE';
   const String PRIVATE_KEY = 'YOUR_BASE58_PRIVATE_KEY_HERE';
   ```

5. **Fund your wallet** (for devnet):
   - Visit: https://faucet.solana.com/
   - Enter your public key to receive test SOL

### 3. Deploy Your Counter Program

This example requires a deployed Anchor counter program. You can:

1. **Use the provided program ID** (devnet): `An8uNPQkHmZVNWgVrxWMtjnx1JvYfdBnfuYksqtMMP8U`
2. **Deploy your own** following the [Anchor documentation](https://www.anchor-lang.com/docs/getting-started)

### 4. Add Your IDL

Place your program's IDL file at `assets/idl.json`. The IDL should match your deployed program.

## Running the App

```bash
flutter run
```

## App Flow

1. **Automatic Setup**: The app automatically initializes the Anchor client on startup
2. **Initialize Counter**: If the counter account doesn't exist, tap "Initialize" to create it
3. **Increment Counter**: Once initialized, tap "Increment" to increase the counter value
4. **Real-time Updates**: The counter value updates automatically after each transaction

## Code Structure

- **`lib/counter_screen.dart`**: Main UI and Anchor client integration
- **`lib/private.dart`**: Private key and program ID configuration (not in version control)
- **`lib/private.example.dart`**: Template for private key configuration
- **`assets/idl.json`**: Program Interface Definition Language file
- **`lib/main.dart`**: Flutter app entry point

## Security Best Practices

⚠️ **IMPORTANT SECURITY CONSIDERATIONS**:

### For Development:

- ✅ Use testnet/devnet only
- ✅ Use dedicated development keypairs
- ✅ Never commit `private.dart` to version control
- ✅ Use the provided `.gitignore` patterns

### For Production:

- 🔐 Use Mobile Wallet Adapter or hardware wallets
- 🔐 Implement secure key storage (keychain/keystore)
- 🔐 Use environment variables for server-side applications
- 🔐 Consider multi-signature wallets for high-value operations
- 🔐 Implement proper key rotation and backup strategies

## Learning Resources

- **[Anchor Documentation](https://www.anchor-lang.com/docs)**: Complete guide to Anchor framework
- **[Solana Cookbook](https://solanacookbook.com/)**: Practical Solana development examples
- **[Coral XYZ Anchor TypeScript](https://github.com/coral-xyz/anchor)**: Reference implementation
- **[Solana Program Examples](https://github.com/solana-labs/solana-program-library)**: Official program examples

## Contributing

This example is part of the Coral XYZ Dart client showcase. Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Follow Dart/Flutter best practices
4. Add tests if applicable
5. Submit a pull request

## License

This example is provided as-is for educational purposes. Check the main repository for license information.

---

**Happy building with Coral XYZ Anchor Dart! 🚀**
