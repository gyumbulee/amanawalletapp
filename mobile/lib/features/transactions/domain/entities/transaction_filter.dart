import 'package:equatable/equatable.dart';
import 'transaction.dart';

/// Filter/search state for the transactions list. All fields optional —
/// an empty [TransactionFilter] means "show everything".
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.service,
    this.status,
    this.search,
    this.startDate,
    this.endDate,
  });

  final TransactionService? service;
  final TransactionStatus? status;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isEmpty =>
      service == null && status == null && (search == null || search!.isEmpty) && startDate == null && endDate == null;

  TransactionFilter copyWith({
    TransactionService? service,
    bool clearService = false,
    TransactionStatus? status,
    bool clearStatus = false,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDateRange = false,
  }) {
    return TransactionFilter(
      service: clearService ? null : (service ?? this.service),
      status: clearStatus ? null : (status ?? this.status),
      search: search ?? this.search,
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (service != null) 'service': service!.apiValue,
      if (status != null) 'status': status!.apiValue,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
    };
  }

  @override
  List<Object?> get props => [service, status, search, startDate, endDate];
}
