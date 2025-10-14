import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _version = 'Unknown';
  String _buildNumber = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                'About MUJ Switch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'MUJ Switch is an app made for the convenience of accessing MUJ SLCM features on your phone.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const Text(
                'Contributors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFD5E7B5)),
                title: const Text('Dhruv Kunzru',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Lead Developer',
                    style: TextStyle(color: Colors.grey)),
                onTap: () => _launchURL('https://github.com/dk10ws'),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFD5E7B5)),
                title: const Text('Amey Santosh Gupte',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('UI/UX Designer',
                    style: TextStyle(color: Colors.grey)),
                onTap: () => _launchURL('https://github.com/Vanillaicee17'),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFD5E7B5)),
                title: const Text('Karan Parashar',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('iOS Last Hope (Backend Developer)',
                    style: TextStyle(color: Colors.grey)),
                onTap: () => _launchURL('https://github.com/whyredfire'),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const Text(
                'Support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFFD5E7B5)),
                title: const Text('Contact Support',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _launchURL('https://t.me/dk10ws'),
              ),
              ListTile(
                leading: const Icon(Icons.web, color: Color(0xFFD5E7B5)),
                title: const Text('Visit MUJ Website',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _launchURL('https://mujslcm.jaipur.manipal.edu'),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const Text(
                'Wanna Contribute?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.contacts, color: Color(0xFFD5E7B5)),
                title: const Text('Message me your interest in the project',
                    style: TextStyle(color: Colors.white)),
                onTap: () => _launchURL('https://t.me/dk10ws'),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const Text(
                'Check For Updates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Color(0xFFD5E7B5)),
                title: Text('App Version: $_version ($_buildNumber)',
                    style: const TextStyle(color: Colors.white)),
                onTap: () =>
                    _launchURL('https://github.com/DK10WS/SLCM_APP/releases/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
