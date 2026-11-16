import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';

/// One Server-Sent Event: `event: <name>` then `data: <json>`.
typedef SseEvent = ({String name, Map<String, dynamic> data});

class AssistantDataSource {
  final ApiClient apiClient;

  AssistantDataSource(this.apiClient);

  Future<Map<String, dynamic>> fetchStatus() async {
    final data = await apiClient.get('/assistant/status');
    return Map<String, dynamic>.from(data);
  }

  /// POST /assistant/chat with stream: true. Yields each event as it arrives.
  /// An `error` event, or an error status before the stream starts, is thrown
  /// as an [AppException] carrying the server's Arabic message.
  ///
  /// Cancelling the subscription closes the connection, which stops the model
  /// on the server - an abandoned question must not hold the queue.
  Stream<SseEvent> chat({required String message, required bool reset}) async* {
    final cancel = CancelToken();
    try {
      final response = await apiClient.dio.post<ResponseBody>(
        '/assistant/chat',
        data: {'message': message, 'stream': true, 'reset': reset},
        cancelToken: cancel,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: AppConstants.assistantTimeout,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      var name = 'message';
      await for (final line in lines) {
        if (line.startsWith('event:')) {
          name = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          final data = Map<String, dynamic>.from(
            jsonDecode(line.substring(5).trim()),
          );
          if (name == 'error') {
            throw AppException(
              data['message'] ?? 'حدث خطأ غير متوقع.',
              statusCode: 500,
            );
          }
          yield (name: name, data: data);
        }
      }
    } on DioException catch (error) {
      throw await _toAppException(error);
    } finally {
      // Ends the request if the listener went away mid-answer.
      cancel.cancel();
    }
  }

  /// Like ApiClient's, except a streamed error body has to be read first.
  Future<AppException> _toAppException(DioException error) async {
    final response = error.response;
    if (response == null) {
      return error.type == DioExceptionType.receiveTimeout
          ? const AppException('تأخر المساعد في الرد، حاول مرة أخرى.')
          : const AppException('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
    }

    var message = 'حدث خطأ ما، حاول مرة أخرى';
    final body = response.data;
    try {
      final json = body is ResponseBody
          ? jsonDecode(await utf8.decodeStream(body.stream))
          : body;
      if (json is Map && json['message'] != null) message = json['message'];
    } catch (_) {
      // Not JSON (e.g. a proxy error page): keep the generic message.
    }
    return AppException(message, statusCode: response.statusCode);
  }
}

final assistantDataSourceProvider = Provider<AssistantDataSource>((ref) {
  return AssistantDataSource(ref.watch(apiClientProvider));
});
