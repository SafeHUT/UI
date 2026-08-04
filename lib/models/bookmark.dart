import 'dart:convert';

class Bookmark {

  final String title;
  final String url;

  Bookmark({required this.title, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
    );
  }

  static String encode(List<Bookmark> bookmarks) => json.encode(
        bookmarks.map<Map<String, dynamic>>((bookmark) => bookmark.toMap()).toList(),
  );  

  static List<Bookmark> decode(String bookmarksString) =>
      (json.decode(bookmarksString) as List<dynamic>)
          .map<Bookmark>((item) => Bookmark.fromMap(item))
          .toList();
}