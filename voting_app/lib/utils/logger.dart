import 'dart:developer' as developer;

class AppLogger {
  // Simple log levels using dart:developer
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, level: 500, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, level: 800, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, level: 900, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, level: 1000, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(message, level: 1200, error: error, stackTrace: stackTrace);
  }

  // Simplified logging methods
  static void logWalletAction(
    String action, {
    String? walletAddress,
    dynamic error,
  }) {
    if (error != null) {
      developer.log('Wallet Action Failed: $action', level: 1000, error: error);
    } else {
      developer.log(
        'Wallet Action: $action ${walletAddress ?? ''}',
        level: 800,
      );
    }
  }

  static void logVotingAction(
    String action, {
    String? pollName,
    int? optionId,
    dynamic error,
  }) {
    if (error != null) {
      developer.log('Voting Action Failed: $action', level: 1000, error: error);
    } else {
      developer.log(
        'Voting Action: $action ${pollName ?? ''} ${optionId != null ? '(Option $optionId)' : ''}',
        level: 800,
      );
    }
  }

  static void logPollAction(
    String action, {
    String? pollName,
    int? optionCount,
    dynamic error,
  }) {
    if (error != null) {
      developer.log('Poll Action Failed: $action', level: 1000, error: error);
    } else {
      developer.log(
        'Poll Action: $action ${pollName ?? ''} ${optionCount != null ? '($optionCount options)' : ''}',
        level: 800,
      );
    }
  }

  static void logNetworkAction(
    String action, {
    String? url,
    int? statusCode,
    dynamic error,
  }) {
    if (error != null) {
      developer.log(
        'Network Action Failed: $action',
        level: 1000,
        error: error,
      );
    } else {
      developer.log(
        'Network Action: $action ${url ?? ''} ${statusCode != null ? '(Status: $statusCode)' : ''}',
        level: 800,
      );
    }
  }

  static void logUIAction(
    String action, {
    String? screen,
    String? component,
    dynamic error,
  }) {
    if (error != null) {
      developer.log('UI Action Failed: $action', level: 900, error: error);
    } else {
      developer.log(
        'UI Action: $action ${screen ?? ''} ${component ?? ''}',
        level: 500,
      );
    }
  }

  static void logAppLifecycle(String event, {String? details}) {
    developer.log('App Lifecycle: $event ${details ?? ''}', level: 800);
  }

  static void logPerformance(
    String operation,
    Duration duration, {
    String? details,
  }) {
    developer.log(
      'Performance: $operation took ${duration.inMilliseconds}ms ${details ?? ''}',
      level: 800,
    );
  }

  static void logBlockchainAction(
    String action, {
    String? transactionId,
    String? programId,
    dynamic error,
  }) {
    if (error != null) {
      developer.log(
        'Blockchain Action Failed: $action',
        level: 1000,
        error: error,
      );
    } else {
      developer.log(
        'Blockchain Action: $action ${transactionId != null ? '(TX: ${transactionId.substring(0, 8)}...)' : ''} ${programId != null ? '(Program: ${programId.substring(0, 8)}...)' : ''}',
        level: 800,
      );
    }
  }
}
