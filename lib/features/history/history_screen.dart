import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if ((state.valueOrNull?.isNotEmpty ?? false))
            IconButton(
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context, ref),
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load history: $e')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No saved payloads yet.'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(entry.payload.replaceAll('\r\n', ' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
                      leading: const CircleAvatar(child: Icon(Icons.history_rounded, size: 18)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'copy') {
                            await Clipboard.setData(ClipboardData(text: entry.payload));
                          } else {
                            await ref.read(historyProvider.notifier).remove(entry.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'copy', child: Text('Copy')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This removes locally saved generated entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
        ],
      ),
    );
    if (yes == true) await ref.read(historyProvider.notifier).clear();
  }
}
