import '../entities/virtual_account.dart';

abstract class VirtualAccountRepository {
  Future<VirtualAccount> getVirtualAccount();
}
