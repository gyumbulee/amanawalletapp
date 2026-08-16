import 'package:equatable/equatable.dart';
import '../../../../constants/cable_provider.dart';

/// A single cable subscription package (e.g. "DStv Padi"). Fixed price per
/// package — like data bundles, not free-form like airtime/electricity.
class CablePackage extends Equatable {
  const CablePackage({
    required this.id,
    required this.provider,
    required this.name,
    required this.priceKobo,
  });

  final String id;
  final CableProvider provider;
  final String name;
  final int priceKobo;

  @override
  List<Object?> get props => [id, provider, name, priceKobo];
}
