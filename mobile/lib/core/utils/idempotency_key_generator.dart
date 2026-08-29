import 'dart:math';

/// Generates a unique-enough key to dedupe a single user's purchase
/// attempts against the backend's idempotency middleware.
///
/// Deliberately not pulling in the `uuid` package for this — timestamp
/// + secure-random bytes gives plenty of entropy for "don't double-charge
/// this user for this specific attempt", which is all this needs to do.
class IdempotencyKeyGenerator {
  IdempotencyKeyGenerator._();

  static final Random _random = Random.secure();

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final randomBytes = List<int>.generate(8, (_) => _random.nextInt(256));
    final randomHex =
        randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$timestamp-$randomHex';
  }
}
