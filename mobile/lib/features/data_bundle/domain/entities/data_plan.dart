import 'package:equatable/equatable.dart';
import '../../../../constants/network_provider.dart';

/// A single data bundle option for a network (e.g. "1GB - 30 Days").
/// Fetched per-network from `/data/plans` — unlike airtime, the amount
/// isn't free-form, it's whatever the selected plan costs.
class DataPlan extends Equatable {
  const DataPlan({
    required this.id,
    required this.network,
    required this.name,
    required this.sizeLabel,
    required this.validityLabel,
    required this.priceKobo,
  });

  final String id;
  final NetworkProvider network;
  final String name;
  final String sizeLabel;
  final String validityLabel;
  final int priceKobo;

  @override
  List<Object?> get props => [id, network, name, sizeLabel, validityLabel, priceKobo];
}
