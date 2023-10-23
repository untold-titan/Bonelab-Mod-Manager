import 'package:bonelab_mod_manager/mod.dart';
import 'package:bonelab_mod_manager/mod_page.dart';
import 'package:flutter/material.dart';

class ModCard extends StatefulWidget {
  final Mod mod;
  final String modFolder;
  const ModCard({Key? key, required this.mod, required this.modFolder})
      : super(key: key);

  @override
  State<ModCard> createState() => _ModCardState();
}

class _ModCardState extends State<ModCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModPage(
                modData: widget.mod,
                modFolder: widget.modFolder,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Image.network(widget.mod.imgUrl),
            Text(
              widget.mod.name,
              style: const TextStyle(fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(widget.mod.creator),
            )
          ],
        ),
      ),
    );
  }
}
