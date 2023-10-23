import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bonelab_mod_manager/mod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ModPage extends StatefulWidget {
  final Mod modData;
  final String modFolder;
  //If true, the download button will be hidden
  final bool view;
  const ModPage({
    Key? key,
    required this.modData,
    required this.modFolder,
    this.view = false,
  }) : super(key: key);

  @override
  State<ModPage> createState() => _ModPageState();
}

class _ModPageState extends State<ModPage> {
  bool downloading = false;

  String status = "";

  Future<File> getLibraryFile() async {
    final Directory appDocumentsDir = await getApplicationCacheDirectory();
    var file = File("${appDocumentsDir.path}/library.json");
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  void downloadMod() async {
    setState(() {
      downloading = true;
      status = "Downloading...";
    });

    if (widget.modFolder == "") {
      setState(
        () {
          downloading = false;
          showDialog(
            context: context,
            builder: (context) => const SimpleDialog(
              children: [
                Center(child: Text("You haven't set your Bonelab folder!!")),
              ],
            ),
          );
        },
      );
      return null;
    }

    // Download the modfile
    var mod = widget.modData;
    var dio = Dio();
    var res = await dio.get(
        "https://u-9193917.modapi.io/v1/games/3809/mods/${widget.modData.id}/files/${widget.modData.modFileId}?api_key=b7ac8124e693d1ac5ed47465ac670b14");
    var data = res.data;
    if (res.statusCode != 200) {
      return;
    }
    var downloadUrl = data["download"]["binary_url"];
    var filename = data["filename"];
    var downloadFolder = await getApplicationCacheDirectory();
    await dio.download(
        downloadUrl, "${downloadFolder.path}/Downloads/$filename");
    var file = File("${downloadFolder.path}/Downloads/$filename");
    var tempDir = Directory("${downloadFolder.path}/Temp");
    // Rename the folder so the mod manager can actually find it
    if (!await tempDir.exists()) {
      await tempDir.create();
    } else {
      //Empty the tempdir
      await tempDir.delete(recursive: true);
      await tempDir.create();
    }
    setState(() {
      status = "Moving files...";
    });
    // Move it to the bonelab folder
    extractFileToDisk(file.path, tempDir.path);
    var extractedfolder = await tempDir.list().first;
    mod.folderName = extractedfolder.path.split("\\").last;
    mod.installedVersion = data["version"];
    (extractedfolder as Directory)
        .rename("${widget.modFolder}/${mod.folderName}");

    // Add this mod to the libary
    setState(() {
      status = "Updating Library...";
    });
    var libraryFile = await getLibraryFile();
    var str = await libraryFile.readAsString();
    try {
      var jsonList = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
      var library = jsonList.map((json) => Mod.fromJson(json)).toList();
      library.add(mod);
      str = jsonEncode(library);
      await libraryFile.writeAsString(str);
    } catch (e) {
      setState(() {
        status = "Creating new Library...";
      });
      var library = <Mod>[];
      library.add(mod);
      str = jsonEncode(library);
      await libraryFile.writeAsString(str);
    }

    setState(() {
      downloading = false;
      status = "Done!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modData.name),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Card(
                child: SizedBox(
                  width: 700,
                  child: Column(
                    children: [
                      Material(
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          widget.modData.imgUrl,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView(
                            children: [
                              Text(widget.modData.description),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "Created by: ${widget.modData.creator}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Total Downloads: ${widget.modData.downloads}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Likes: ${widget.modData.likes}     Dislikes: ${widget.modData.dislikes}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Ratings: ${widget.modData.ratings}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: FilledButton(
                                onPressed: () {},
                                child: const Text("View Mod.io Page")),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          downloading == true
              ? Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(14, 15, 15, 0.5)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(status),
                      )
                    ],
                  ),
                )
              : Container()
        ],
      ),
      floatingActionButton: !widget.view
          ? FloatingActionButton.extended(
              onPressed: downloading == false ? downloadMod : null,
              label: const Text("Download"),
              icon: const Icon(Icons.download),
            )
          : null,
    );
  }
}
