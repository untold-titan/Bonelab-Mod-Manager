import 'dart:convert';
import 'dart:io';

import 'package:bonelab_mod_manager/mod.dart';
import 'package:bonelab_mod_manager/mod_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LibraryPage extends StatefulWidget {
  final String modFolder;
  const LibraryPage({
    Key? key,
    required this.modFolder,
  }) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  var library = <Mod>[];

  Future<File> getLibraryFile() async {
    final Directory appDocumentsDir = await getApplicationCacheDirectory();
    var file = File("${appDocumentsDir.path}/library.json");
    return file;
  }

  void getLibrary() async {
    var libraryFile = await getLibraryFile();
    if (!await libraryFile.exists()) {
      return;
    }
    var str = await libraryFile.readAsString();
    var jsonList = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
    library = jsonList.map((json) => Mod.fromJson(json)).toList();
    setState(() {
      library = library;
    });
  }

  void openModDialog(Mod mod) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Mod Folder: ${mod.folderName}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModPage(
                            modData: mod,
                            modFolder: "",
                            view: true,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "View Mod",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    onPressed: () {
                      deleteMod(mod);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete Mod"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void deleteMod(Mod mod) async {
    var modFolder = Directory("${widget.modFolder}/${mod.folderName}");
    //Sometimes the mod is deleted manually, so i need to handle that
    if (await modFolder.exists()) {
      await modFolder.delete(recursive: true);
    }
    library.remove(mod);
    var file = await getLibraryFile();
    await file.writeAsString(jsonEncode(library));
    setState(() {
      library = library;
    });
  }

  @override
  void initState() {
    getLibrary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Library Page",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: FilledButton(
                  onPressed: () {}, child: const Text("Check for Updates")),
            )
          ],
        ),
        Expanded(
          child: ListView(
            children: library
                .map(
                  (e) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${e.name} - v${e.installedVersion}",
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(e.creator)
                            ],
                          ),
                          IconButton.filled(
                            onPressed: () {
                              openModDialog(e);
                            },
                            icon: const Icon(Icons.more_horiz),
                          )
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
