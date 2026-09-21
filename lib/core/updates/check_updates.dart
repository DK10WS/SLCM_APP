import "package:flutter/material.dart";
import 'package:mujslcm/core/theme/app_colors.dart';
import "package:mujslcm/core/constants/urls.dart";
import "package:mujslcm/core/network/slcm_client.dart";
import "package:package_info_plus/package_info_plus.dart";
import 'package:url_launcher/url_launcher.dart';

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<void> _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Object?> checkUpdate(context) async {
  final appversion = await getAppVersion();
  final response = await slcm.get(Urls.releases);
  if ("v$appversion" != response.data["tag_name"]) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              backgroundColor: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "New Update",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Version ${response.data["tag_name"]} is out check out",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          _launchURL(Urls.releasesPage);
                        },
                        child: const Text('Download',
                            style: TextStyle(
                                color: AppColors.accent, fontSize: 15)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
  return null;
}
