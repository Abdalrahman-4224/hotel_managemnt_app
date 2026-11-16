import '../entities/assistant_reply.dart';

/// The hotel assistant: answers questions about the signed-in user's hotel.
/// The real implementation is in data/repositories/assistant_repository_impl.dart.
abstract class AssistantRepository {
  Future<AssistantStatus> getStatus();

  /// Streams the answer to [question] as it is produced. Cancelling the
  /// subscription stops the model on the server.
  ///
  /// [reset] starts a new conversation: the server otherwise remembers the
  /// previous question for 10 minutes, so "and tomorrow?" works.
  Stream<AssistantEvent> ask(String question, {bool reset = false});
}
