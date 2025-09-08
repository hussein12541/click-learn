import 'package:dio/dio.dart';

import '../constant/constant.dart';

class ApiServices {
  final Dio _dio = Dio(BaseOptions(
      baseUrl:kBaseUrl,
      headers: {
        "apikey":
        kAnonKey,
      }));
  Future<Response> getData({required String path}) async {
    return await _dio.get(path);
  }
  Future<Response> deleteData({required String path}) async {
    return await _dio.delete(path);
  }

  Future<Response> postData(
      {required String path, required Map<String, dynamic> data}) async {
    return await _dio.post(
      path,
      data: data,
    );
  }

  Future<Response>

  patchData(
      {required String path, required Map<String, dynamic> data}) async {
    return await _dio.patch(path, data: data);
  }
}
