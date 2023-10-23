import 'package:bonelab_mod_manager/mod.dart';
import 'package:bonelab_mod_manager/mod_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String modFolder;
  const HomePage({Key? key, required this.modFolder}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mod> mods = [];

  @override
  void initState() {
    super.initState();
    getMods();
  }

  void getMods() async {
    var dio = Dio();
    var res = await dio.get(
        "https://u-9193917.modapi.io/v1/games/3809/mods?api_key=b7ac8124e693d1ac5ed47465ac670b14&_sort=-date_added");
    var data = res.data;
    if (data == null) {
      return;
    }
    for (var mod in data["data"]) {
      var newMod = Mod();
      newMod.id = mod["id"];
      newMod.name = mod["name"];
      newMod.creator = mod["submitted_by"]["username"];
      newMod.imgUrl = mod["logo"]["thumb_1280x720"];
      newMod.description = mod["description_plaintext"];
      newMod.downloads = mod["stats"]["downloads_total"];
      newMod.ratings = mod["stats"]["ratings_display_text"];
      newMod.likes = mod["stats"]["ratings_positive"];
      newMod.dislikes = mod["stats"]["ratings_negative"];
      newMod.modIoPage = mod["profile_url"];
      for (var platform in mod["platforms"]) {
        if (platform["platform"] == "windows") {
          newMod.modFileId = platform["modfile_live"];
        }
      }
      mods.add(newMod);
    }
    if (mounted) {
      setState(() {
        mods = mods;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Newest Mods on Mod.io",
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
        mods.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 300.0),
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: GridView.count(
                  crossAxisCount: 5,
                  children: mods
                      .map(
                        (e) => ModCard(
                          mod: e,
                          modFolder: widget.modFolder,
                        ),
                      )
                      .toList(),
                ),
              ),
      ],
    );
  }
}
