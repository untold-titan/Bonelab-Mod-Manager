class Mod {
  int id = 0;
  String name = "";
  String creator = "";
  String imgUrl = "";
  String description = "";
  String ratings = "";
  int downloads = 0;
  int modFileId = 0;
  int likes = 0;
  int dislikes = 0;
  String folderName = "";
  String installedVersion = "";
  String modIoPage = "";

  Mod({
    this.id = 0,
    this.name = "",
    this.creator = "",
    this.imgUrl = "",
    this.description = "",
    this.ratings = "",
    this.downloads = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.folderName = "",
    this.installedVersion = "",
    this.modIoPage = "",
  });

  Map toJson() => {
        "id": id,
        "name": name,
        "creator": creator,
        "imgUrl": imgUrl,
        "description": description,
        "ratings": ratings,
        "downloads": downloads,
        "modFileId": modFileId,
        "likes": likes,
        "dislikes": dislikes,
        "folderName": folderName,
        "installedVersion": installedVersion,
        "modIoPage": modIoPage,
      };

  factory Mod.fromJson(Map<String, dynamic> json) {
    return Mod(
        id: json["id"] as int,
        name: json["name"] as String,
        creator: json["creator"] as String,
        imgUrl: json["imgUrl"] as String,
        description: json["description"] as String,
        ratings: json["ratings"] as String,
        downloads: json["downloads"] as int,
        likes: json["likes"] as int,
        dislikes: json["dislikes"] as int,
        folderName: json["folderName"] as String,
        installedVersion: json["installedVersion"] as String,
        modIoPage: json["modIoPage"] as String);
  }
}
