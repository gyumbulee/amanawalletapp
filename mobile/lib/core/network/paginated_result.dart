/// Generic wrapper for Laravel's standard paginator response shape:
/// `{ data: [...], meta: { current_page, last_page, ... } }`.
/// Reused across wallet ledger, transactions, referral history, etc.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
