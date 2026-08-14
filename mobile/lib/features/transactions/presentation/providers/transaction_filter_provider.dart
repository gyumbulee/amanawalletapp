import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_filter.dart';

/// Current filter/search selection for the transactions list. Changing
/// this automatically re-runs [TransactionListController.build] since it's
/// watched there — no manual invalidate needed from the filter sheet.
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) => const TransactionFilter());
