import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool confirmExports = true;
  bool showWarnings = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
          children: [
            const Text('Workspace', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: confirmExports,
                    onChanged: (v) => setState(() => confirmExports = v),
                    title: const Text('Confirm exports'),
                    subtitle: const Text('Ask before copying/exporting generated content.'),
                  ),
                  SwitchListTile(
                    value: showWarnings,
                    onChanged: (v) => setState(() => showWarnings = v),
                    title: const Text('Show validation warnings'),
                    subtitle: const Text('Keep structural warnings visible in Studio.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Card(
              child: ListTile(
                leading: Icon(Icons.security_rounded),
                title: Text('Privacy model'),
                subtitle: Text('PayloadLab performs generation and analysis locally. It does not send generated content to a remote service.'),
              ),
            ),
            const SizedBox(height: 14),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('PayloadLab 1.0'),
                subtitle: Text('Offline construction, inspection and validation workspace.'),
              ),
            ),
          ],
        ),
      );
}
