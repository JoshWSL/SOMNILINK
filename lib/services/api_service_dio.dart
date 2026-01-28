// API for connecting App to Django REST

import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000//api/",  // url for connection to django backend // must be updated if django is not on same ip like app
      connectTimeout: const Duration(seconds: 10),  // Timeout when more than 10 s waiting 
      receiveTimeout: const Duration(seconds: 10),  
      contentType: "application/json",  // Data format is django
    ),
  );

  // Logging Interceptor ->shows which data is send and recived in terminal (only relevant for app development)
  static void init() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,          // shows url and header
        requestBody: true,      // shows data
        responseBody: true,     // shows server response
        error: true,            
      ),
    );
  }

  static Dio get instance => _dio;
  
}
