import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/payload.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});
  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final host = TextEditingController(text: 'example.com');
  final port = TextEditingController(text: '443');
  final method = TextEditingController(text: 'CONNECT');
  final userAgent = TextEditingController();
  final headerName = TextEditingController();
  final headerValue = TextEditingController();

  PayloadType type = PayloadType.normal;
  String protocol = 'HTTP/1.1';
  bool split = false;
  final headers = <String, String>{};
  PayloadResult? result;

  @override
  void dispose() {
    for (final c in [host, port, method, userAgent, headerName, headerValue]) {
      c.dispose();
    }
    super.dispose();
  }

  void generate() {
    final parsedPort = int.tryParse(port.text.trim()) ?? -1;
    final spec = PayloadSpec(
      host: host.text,
      port: parsedPort,
      method: method.text,
      protocol: protocol,
      type: type,
      userAgent: userAgent.text,
      headers: headers,
      split: split,
    );
    setState(() => result = ref.read(payloadEngineProvider).generate(spec));
  }

  Future<void> save() async {
    final value = result;
    if (value == null || !value.isValid) return;

    final messenger = ScaffoldMessenger.of(context);

    await ref.read(historyProvider.notifier).add(
          HistoryEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: '${type.label} · ${host.text.trim()}',
            payload: value.payload,
            createdAt: DateTime.now(),
          ),
        );

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Saved to local history')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultValue = result;
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          const Text('Build a request', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Everything runs locally. Nothing is transmitted.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 22),
          _Field(label: 'Host', controller: host),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _Field(label: 'Port', controller: port, keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _Field(label: 'Method', controller: method)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: protocol,
            decoration: const InputDecoration(labelText: 'Protocol'),
            items: const [
              DropdownMenuItem(value: 'HTTP/1.0', child: Text('HTTP/1.0')),
              DropdownMenuItem(value: 'HTTP/1.1', child: Text('HTTP/1.1')),
            ],
            onChanged: (v) => setState(() => protocol = v ?? protocol),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PayloadType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Template'),
            items: [
              for (final item in PayloadType.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: (v) => setState(() => type = v ?? type),
          ),
          const SizedBox(height: 12),
          _Field(label: 'User-Agent (optional)', controller: userAgent),
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              title: const Text('Advanced headers', style: TextStyle(fontWeight: FontWeight.w800)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Row(children: [
                  Expanded(child: _Field(label: 'Name', controller: headerName)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'Value', controller: headerValue)),
                  IconButton(
                    tooltip: 'Add header',
                    onPressed: () {
                      if (headerName.text.trim().isEmpty) return;
                      setState(() {
                        headers[headerName.text.trim()] = headerValue.text;
                        headerName.clear();
                        headerValue.clear();
                      });
                    },
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
                ]),
                for (final entry in headers.entries)
                  ListTile(
                    dense: true,
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                    trailing: IconButton(
                      onPressed: () => setState(() => headers.remove(entry.key)),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                SwitchListTile(
                  value: split,
                  onChanged: (v) => setState(() => split = v),
                  title: const Text('Split marker'),
                  subtitle: const Text('Marks the generated Host boundary for inspection.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Generate')),
          ),
          if (resultValue != null) ...[
            const SizedBox(height: 18),
            _ResultCard(
              result: resultValue,
              onCopy: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(
                  ClipboardData(text: resultValue.payload),
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Copied')),
                );
              },
              onSave: save,
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.keyboard});
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.onCopy, required this.onSave});
  final PayloadResult result;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Output', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_rounded)),
              IconButton(onPressed: onSave, icon: const Icon(Icons.bookmark_add_rounded)),
            ]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF08090D), borderRadius: BorderRadius.circular(16)),
              child: SelectableText(result.payload, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.6)),
            ),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final e in result.errors) Text('✕ $e', style: const TextStyle(color: Colors.redAccent)),
            ],
            for (final w in result.warnings) Text('! $w', style: const TextStyle(color: Colors.amber)),
          ]),
        ),
      );
}
