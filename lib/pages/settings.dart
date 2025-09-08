import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  final String newCookies;

  const Settings({super.key, required this.newCookies});

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
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
              const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
