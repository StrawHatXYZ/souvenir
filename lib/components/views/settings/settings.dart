import 'package:phantom_connect/phantom_connect.dart';
import 'package:souvenir/components/views/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:souvenir/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const Settings({super.key, required this.phantomConnectInstance});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SettingsTile(
              color: Colors.blue,
              icon: Icons.person,
              title: "Account",
              onTap: () {},
            ),
            const SizedBox(
              height: 10,
            ),
            SettingsTile(
              color: Colors.green,
              icon: Icons.edit,
              title: "Edit Information",
              onTap: () {},
            ),
            const SizedBox(
              height: 40,
            ),
            SettingsTile(
              color: Colors.black,
              icon: Icons.mood_rounded,
              title: "Theme",
              onTap: () {},
            ),
            const SizedBox(
              height: 10,
            ),
            SettingsTile(
              color: Colors.purple,
              icon: Icons.language,
              title: "Language",
              onTap: () {},
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () async {
                logger.i("Disconnect button pressed");
                Uri launchUri = widget.phantomConnectInstance
                    .generateDisconectUri(redirect: '/disconnected');
                await launchUrl(
                  launchUri,
                  mode: LaunchMode.externalApplication,
                );
              },
              child: SettingsTile(
                color: Colors.red,
                icon: Icons.link_off,
                title: "Disconnect",
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
