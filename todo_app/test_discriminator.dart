import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  // Compute discriminator for 'global:initialize_user' (snake_case)
  final input = 'global:initialize_user';
  final hash = sha256.convert(utf8.encode(input));
  final discriminator = hash.bytes.take(8).toList();
  print('Snake case discriminator: $discriminator');
  print(
    'Snake case hex: ${discriminator.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}',
  );

  // Compute discriminator for 'global:initializeUser' (camelCase)
  final input2 = 'global:initializeUser';
  final hash2 = sha256.convert(utf8.encode(input2));
  final discriminator2 = hash2.bytes.take(8).toList();
  print('Camel case discriminator: $discriminator2');
  print(
    'Camel case hex: ${discriminator2.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}',
  );
}
