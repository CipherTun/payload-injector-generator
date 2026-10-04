import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/payload.dart';
import '../domain/payload_engine.dart';
import 'history_repository.dart';

final payloadEngineProvider = Provider<PayloadEngine>((ref) => PayloadEngine());
final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryRepository());

final historyProvider = AsyncNotifierProvider<HistoryController, List<HistoryEntry>>(
  HistoryController.new,
);

class HistoryController extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() => ref.read(historyRepositoryProvider).load();

  Future<void> add(HistoryEntry entry) async {
    final current = [...(state.value ?? const <HistoryEntry>[])];
    current.insert(0, entry);
    final trimmed = current.take(100).toList();
    await ref.read(historyRepositoryProvider).save(trimmed);
    state = AsyncData(trimmed);
  }

  Future<void> remove(String id) async {
    final current = [...(state.value ?? const <HistoryEntry>[])]..removeWhere((e) => e.id == id);
    await ref.read(historyRepositoryProvider).save(current);
    state = AsyncData(current);
  }

  Future<void> clear() async {
    await ref.read(historyRepositoryProvider).clear();
    state = const AsyncData([]);
  }
}
