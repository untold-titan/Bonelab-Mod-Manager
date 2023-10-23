import 'dart:convert';
import 'dart:io';

import 'package:bonelab_mod_manager/home_page.dart';
import 'package:bonelab_mod_manager/library_page.dart';
import 'package:bonelab_mod_manager/search_page.dart';
import 'package:bonelab_mod_manager/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  var windowOptions = const WindowOptions(
    title: "Bonelab Mod Manager",
    minimumSize: Size(1400, 800),
    // titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedPage = 0;

  String bonelabModFolder = "";

  void setModFolder(String location) {
    setState(() {
      bonelabModFolder = location;
    });
  }

  Future<File> getSettingsFile() async {
    final Directory appDocumentsDir = await getApplicationCacheDirectory();
    return File("${appDocumentsDir.path}/settings.json");
  }

  void loadSettings() async {
    var file = await getSettingsFile();
    if (!await file.exists()) {
      return;
    }
    var str = await file.readAsString();
    var data = jsonDecode(str) as Map<String, dynamic>;
    if (data["modFolder"] != null) {
      bonelabModFolder = data["modFolder"];
    }
    setState(() {
      bonelabModFolder = bonelabModFolder;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Bonelab Mod Manager"),
        //   // actions: [
        //   //   IconButton(
        //   //       onPressed: () {
        //   //         exit(0);
        //   //       },
        //   //       icon: const Icon(Icons.close))
        //   // ],
        // ),
        body: Row(
          children: [
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text("Search"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.source),
                  label: Text("Library"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text("Settings"),
                )
              ],
              selectedIndex: _selectedPage,
              onDestinationSelected: (val) => {
                setState(() {
                  _selectedPage = val;
                })
              },
            ),
            Expanded(
              child: [
                HomePage(
                  modFolder: bonelabModFolder,
                ),
                SearchPage(
                  modFolder: bonelabModFolder,
                ),
                LibraryPage(
                  modFolder: bonelabModFolder,
                ),
                SettingsPage(
                  setBonelabModLocation: setModFolder,
                )
              ].elementAt(_selectedPage),
            )
          ],
        ),
      ),
    );
  }
}
