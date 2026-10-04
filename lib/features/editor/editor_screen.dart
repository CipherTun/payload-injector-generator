import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/payload_engine.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final controller = TextEditingController(text: 'CONNECT example.com:443 HTTP/1.1\r\nHost: example.com\r\n\r\n');
  final engine = PayloadEngine();
  String toolOutput = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void transform(String operation) {
    try {
      final input = controller.text;
      final output = switch (operation) {
        'base64' => engine.toBase64(input),
        'url' => engine.toUrl(input),
        'hex' => engine.toHex(input),
        'fromBase64' => engine.fromBase64(input),
        'fromUrl' => engine.fromUrl(input),
        'fromHex' => engine.fromHex(input),
        _ => input,
      };
      setState(() => toolOutput = output);
    } on FormatException catch (e) {
      setState(() => toolOutput = 'Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = controller.text.split('\n').length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          IconButton(
            tooltip: 'Copy',
            onPressed: () => Clipboard.setData(ClipboardData(text: controller.text)),
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
        children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xFF0B0C11), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF242735))),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 1; i <= lines; i++)
                      Text('$i', style: const TextStyle(fontFamily: 'monospace', color: Colors.white24, fontSize: 12, height: 1.55)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.55),
                    decoration: const InputDecoration(border: InputBorder.none, filled: false, hintText: 'Write or paste text...'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Transforms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in const [('Encode Base64','base64'), ('Decode Base64','fromBase64'), ('Encode URL','url'), ('Decode URL','fromUrl'), ('To hex','hex'), ('From hex','fromHex')])
                OutlinedButton(onPressed: () => transform(item.$2), child: Text(item.$1)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final errors = engine.validateRaw(controller.text);
              setState(() => toolOutput = errors.isEmpty ? 'Validation passed.' : errors.join('\n'));
            },
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Validate'),
          ),
          if (toolOutput.isNotEmpty) ...[
            const SizedBox(height: 14),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: SelectableText(toolOutput, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)))),
          ],
        ],
      ),
    );
  }
}
