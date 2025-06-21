import 'dart:async';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/Client/APIendpoint.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

// const imageUrl = "http://192.168.1.55:5051/";
const imageUrl = APIEndpoints.imageUrl;
const baseUrl = APIEndpoints.baseUrl;

class BaseClient<T> {
  final T Function(Map<String, dynamic>)? fromJson;
  final Dio _dio = Dio();
  final int _timeoutSeconds = 30;

  BaseClient({this.fromJson}) {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: _timeoutSeconds),
      receiveTimeout: Duration(seconds: _timeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = (await SharedPreferencesHelper.getUser())?.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await SharedPreferencesHelper.removeUser();
        }
        return handler.next(error);
      },
    ));
  }

  Future<ApiResponse<T>> create({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    developer.log('🌐 BaseClient.create() - بدء HTTP POST Request',
        name: 'BaseClient');
    developer.log('  - URL: $baseUrl$endpoint', name: 'BaseClient');
    developer.log('  - Data: $data', name: 'BaseClient');

    try {
      developer.log('📡 إرسال POST request...', name: 'BaseClient');
      final response = await _dio.post(endpoint, data: data);

      developer.log('📥 استجابة HTTP:', name: 'BaseClient');
      developer.log('  - Status Code: ${response.statusCode}',
          name: 'BaseClient');
      developer.log('  - Response Data: ${response.data}', name: 'BaseClient');

      final result = _handleResponse(response);
      developer.log('✅ تم معالجة الاستجابة بنجاح', name: 'BaseClient');
      return result;
    } on DioException catch (e) {
      developer.log('💥 DioException في BaseClient.create():',
          name: 'BaseClient');
      developer.log('  - Type: ${e.type}', name: 'BaseClient');
      developer.log('  - Message: ${e.message}', name: 'BaseClient');
      developer.log('  - Status Code: ${e.response?.statusCode}',
          name: 'BaseClient');
      developer.log('  - Response Data: ${e.response?.data}',
          name: 'BaseClient');
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> getById({
    required String endpoint,
    required String id,
  }) async {
    try {
      final response = await _dio.get('$endpoint/$id');
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> get({required String endpoint}) async {
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  FutureOr<T> get_noResponse({required String endpoint}) async {
    try {
      final response = await _dio.get(endpoint);
      return fromJson!(response.data);
    } on DioException catch (e) {
      return e.response?.data;
    }
  }

  Future<ApiResponse<T>> getAll(
      {required String endpoint,
      int page = 1,
      Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          ...?queryParams,
          'pageNumber': page,
        },
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> update({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<T>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<String>> uploadFile(String selectedImagePath) async {
    try {
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          selectedImagePath,
          filename: selectedImagePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        FileEndpoints.multi,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final urls = (response.data['data'] as List)
            .map<String>((file) => file['url'].toString())
            .toList();
        return ApiResponse<String>(data: urls);
      }
      return ApiResponse<String>(
        message: response.data['message'] ?? 'Upload failed',
        data: [],
        errorType: ApiErrorType.serverError,
      );
    } on DioException catch (e) {
      return ApiResponse<String>(
        message: e.response?.data['message'] ?? 'Upload error',
        data: [],
        errorType: ApiErrorType.serverError,
      );
    }
  }

  ApiResponse<T> _handleResponse(Response response) {
    developer.log('🔄 BaseClient._handleResponse() - معالجة الاستجابة',
        name: 'BaseClient');
    developer.log('  - Status Code: ${response.statusCode}',
        name: 'BaseClient');

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      developer.log('✅ استجابة ناجحة - تحويل البيانات', name: 'BaseClient');
      final result = ApiResponse.fromJsonAuto(response.data, fromJson!);
      developer.log('  - Message: ${result.message}', name: 'BaseClient');
      return result;
    }

    developer.log('❌ استجابة فاشلة', name: 'BaseClient');
    developer.log('  - Error Message: ${response.data['message']}',
        name: 'BaseClient');
    developer.log('  - Errors: ${response.data['errors']}', name: 'BaseClient');

    return ApiResponse<T>(
      message: response.data['message'] ?? 'Unknown error',
      data: [],
      errors: response.data['errors'],
      errorType: ApiErrorType.serverError,
    );
  }

  ApiResponse<T> _handleDioError(DioException e) {
    developer.log('💥 BaseClient._handleDioError() - معالجة خطأ Dio',
        name: 'BaseClient');
    developer.log('  - Exception Type: ${e.type}', name: 'BaseClient');
    developer.log('  - Exception Message: ${e.message}', name: 'BaseClient');

    ApiErrorType errorType;
    String message = '';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorType = ApiErrorType.timeout;
        message = 'Request timed out';
        developer.log('⏰ خطأ انتهاء المهلة الزمنية', name: 'BaseClient');
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        developer.log('📛 استجابة سيئة - Status Code: $statusCode',
            name: 'BaseClient');
        developer.log('  - Response Data: ${e.response?.data}',
            name: 'BaseClient');
        if (statusCode == 401) {
          errorType = ApiErrorType.unauthorized;
          message = 'Unauthorized';
          developer.log('🔒 خطأ عدم تفويض (401)', name: 'BaseClient');
        } else {
          errorType = ApiErrorType.serverError;
          message = e.response?.data['message'] ?? 'Server error';
          developer.log('🔥 خطأ خادم: $message', name: 'BaseClient');
        }
        break;
      case DioExceptionType.cancel:
        errorType = ApiErrorType.unknown;
        message = 'Request cancelled';
        developer.log('🚫 تم إلغاء الطلب', name: 'BaseClient');
        break;
      case DioExceptionType.unknown:
        if (e.message != null && e.message!.contains('SocketException')) {
          errorType = ApiErrorType.noInternet;
          message = 'No internet connection';
          developer.log('📡 لا يوجد اتصال بالإنترنت', name: 'BaseClient');
        } else {
          errorType = ApiErrorType.unknown;
          message = 'Unknown error: ${e.message}';
        }
        break;
      default:
        errorType = ApiErrorType.unknown;
        message = 'Unexpected error';
    }

    return ApiResponse<T>(
      message: message,
      data: [],
      errors: e.response?.data['errors'],
      errorType: errorType,
    );
  }
}
