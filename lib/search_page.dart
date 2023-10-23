import 'package:bonelab_mod_manager/mod.dart';
import 'package:bonelab_mod_manager/mod_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String modFolder;
  const SearchPage({Key? key, required this.modFolder}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  bool searching = false;

  List<Mod> mods = [];

  void search() async {
    mods.clear();
    setState(() {
      mods = mods;
      searching = true;
    });
    var dio = Dio();
    var res = await dio.get(
        "https://u-9193917.modapi.io/v1/games/3809/mods?api_key=b7ac8124e693d1ac5ed47465ac670b14&_q=$searchQuery");
    var data = res.data;
    if (res.statusCode != 200) {
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
      for (var platform in mod["platforms"]) {
        if (platform["platform"] == "windows") {
          newMod.modFileId = platform["modfile_live"];
        }
      }
      mods.add(newMod);
    }
    setState(() {
      searching = false;
      mods = mods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.search),
                  ),
                  SizedBox(
                    width: 500,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Search"),
                      ),
                      onChanged: (str) => searchQuery = str,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                        onPressed: () {
                          search();
                        },
                        icon: const Icon(Icons.arrow_forward)),
                  )
                ],
              ),
            ),
            Expanded(
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
        ),
        searching == true
            ? Container(
                decoration:
                    const BoxDecoration(color: Color.fromRGBO(14, 15, 15, 0.5)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text("Searching..."),
                    )
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}
