import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  static const templates = [
    ('Normal request', 'A conventional HTTP-style request layout.', Icons.http_rounded),
    ('Front injection layout', 'Two-stage request construction for inspection.', Icons.layers_rounded),
    ('Back injection layout', 'Request followed by a secondary request segment.', Icons.vertical_align_bottom_rounded),
    ('Front query layout', 'Target and host separated by a query-style delimiter.', Icons.alt_route_rounded),
    ('Back query layout', 'Authority followed by a host query segment.', Icons.route_rounded),
    ('WebSocket handshake', 'HTTP Upgrade/Connection handshake structure.', Icons.swap_vert_circle_rounded),
    ('SNI note', 'HTTP request plus a clear TLS/SNI warning.', Icons.lock_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Templates')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
          children: [
            const Text('Local library', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Templates are deterministic starting points, not guarantees of remote compatibility.', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 18),
            for (final t in templates)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(child: Icon(t.$3)),
                  title: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(t.$2),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.go('/studio'),
                ),
              ),
          ],
        ),
      );
}
