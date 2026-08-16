import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/cable_provider.dart';
import '../../domain/entities/cable_package.dart';
import 'cable_repository_provider.dart';

final cablePackagesProvider = FutureProvider.family<List<CablePackage>, CableProvider>((ref, provider) {
  return ref.watch(cableRepositoryProvider).getPackages(provider: provider);
});
