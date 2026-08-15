import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/virtual_account.dart';
import '../../domain/repositories/virtual_account_repository.dart';
import '../datasources/virtual_account_api_service.dart';
import '../models/virtual_account_model.dart';

class VirtualAccountRepositoryImpl implements VirtualAccountRepository {
  VirtualAccountRepositoryImpl(this._api);
  final VirtualAccountApiService _api;

  @override
  Future<VirtualAccount> getVirtualAccount() async {
    try {
      final response = await _api.getVirtualAccount();
      final data = response.data as Map<String, dynamic>;
      // Backend wraps the payload under "virtual_account". Also accept a
      // generic "data" wrapper or a flat body, in case that ever changes.
      final payload = data['virtual_account'] is Map
          ? data['virtual_account'] as Map<String, dynamic>
          : (data['data'] is Map ? data['data'] as Map<String, dynamic> : data);
      return VirtualAccountModel.fromJson(payload);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
