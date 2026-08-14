import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_repository_provider.dart';

/// Fetches a single transaction by reference. `.family` keys the cache per
/// reference so navigating between two different transaction details
/// doesn't reuse stale data.
final transactionDetailProvider = FutureProvider.family<Transaction, String>((ref, reference) {
  return ref.watch(transactionRepositoryProvider).getTransactionDetail(reference);
});
