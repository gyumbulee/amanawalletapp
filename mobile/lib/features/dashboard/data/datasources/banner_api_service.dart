import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class BannerApiService {
  BannerApiService(this._dio);
  final Dio _dio;

  Future<Response> getBanners() {
    return _dio.get(ApiEndpoints.banners);
  }
}
