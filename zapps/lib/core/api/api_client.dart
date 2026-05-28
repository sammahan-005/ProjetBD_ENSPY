import 'package:dio/dio.dart';
import 'package:zapps/core/api/api_constants.dart';
import 'package:zapps/core/utils/auth_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AuthStorage.clear();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// GET
  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  /// POST
  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  /// POST multipart (upload fichier)
  Future<Response> postFormData(String path, FormData data) =>
      _dio.post(path, data: data);

  /// PUT
  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  /// DELETE
  Future<Response> delete(String path) => _dio.delete(path);
}
