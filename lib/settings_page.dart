import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final Function(String val) setBonelabModLocation;
  const SettingsPage({Key? key, required this.setBonelabModLocation})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String folderLocation = "Not Set";

  String cacheFolder = "";

  Map<String, String> settings = {};

  bool saved = false;

  int cacheSize = 0;

  Future<File> getSettingsFile() async {
    final Directory appDocumentsDir = await getApplicationCacheDirectory();
    return File("${appDocumentsDir.path}/settings.json");
  }

  void saveSettings() async {
    var data = jsonEncode(settings);
    var file = await getSettingsFile();
    await file.writeAsString(data);
    setState(() {
      saved = true;
    });
    if (settings["modFolder"] != null) {
      widget.setBonelabModLocation(settings["modFolder"]!);
    }
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    calculateCacheSize();
  }

  void calculateCacheSize() async {
    var dir =
        Directory("${(await getApplicationCacheDirectory()).path}/Downloads");
    cacheFolder = dir.absolute.path;
    var files = await dir.list(recursive: true).toList();
    int size = 0;
    for (var file in files) {
      size += (await file.stat()).size;
    }
    var diskSize = (size / pow(10, 6)).round();
    setState(() {
      cacheSize = diskSize;
    });
  }

  void clearCache() async {
    var dir =
        Directory("${(await getApplicationCacheDirectory()).path}/Downloads");
    await dir.delete(recursive: true);
    await dir.create();
    calculateCacheSize();
  }

  void loadSettings() async {
    var file = await getSettingsFile();
    if (!await file.exists()) {
      return;
    }
    var str = await file.readAsString();
    var data = jsonDecode(str) as Map<String, dynamic>;
    for (var key in data.keys) {
      settings[key] = data[key].toString();
    }
    setState(() {
      settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Mod Manager Settings",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            children: [
              Text(
                  "Current Bonelab Mod Folder: ${settings["modFolder"] ?? "Not Set"}"),
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: ElevatedButton(
                    onPressed: () async {
                      var dir = await FilePicker.platform.getDirectoryPath();
                      if (dir != null) {
                        setState(() {
                          settings["modFolder"] = dir;
                        });
                      }
                    },
                    child: const Text("Select Folder")),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Text("Cache Folder Size: ${cacheSize}MB"),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.file(cacheFolder));
                    },
                    child: const Text("Open Folder"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: FilledButton(
                    onPressed: () {
                      clearCache();
                    },
                    child: const Text("Clear Folder"),
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: FilledButton(
                  onPressed: () {
                    saveSettings();
                  },
                  child: const Text("Save Settings"),
                ),
              ),
              saved
                  ? const Padding(
                      padding: EdgeInsets.only(top: 20.0, left: 10),
                      child: Icon(Icons.check),
                    )
                  : Container()
            ],
          )
        ],
      ),
    );
  }
}
