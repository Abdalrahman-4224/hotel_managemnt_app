import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assistant_reply.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../data_sources/assistant_data_source.dart';
import '../models/assistant_model.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantDataSource dataSource;

  AssistantRepositoryImpl(this.dataSource);

  @override
  Future<AssistantStatus> getStatus() async {
    return AssistantModel.status(await dataSource.fetchStatus());
  }

  @override
  Stream<AssistantEvent> ask(String question, {bool reset = false}) async* {
    await for (final e in dataSource.chat(message: question, reset: reset)) {
      final event = AssistantModel.event(e.name, e.data);
      if (event != null) yield event;
    }
  }
}

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return AssistantRepositoryImpl(ref.watch(assistantDataSourceProvider));
});
