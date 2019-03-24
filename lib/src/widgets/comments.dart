import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' show parse;

class Comment extends StatelessWidget {
  final int itemId;
  final Map<int, Future<ItemModel>> itemMap;
  final int depth;

  Comment({this.itemId, this.itemMap, this.depth});

  Widget build(context) {
    return FutureBuilder(
      future: itemMap[itemId],
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (!snapshot.hasData) {
          return Text('Still loading comment');
        }

      final item = snapshot.data;
      final children = <Widget> [
        ListTile(
          title: buildText(item),
          subtitle: item.by == '' ? Text('This comment has been deleted by the moderator.') : Text(item.by),
          contentPadding: EdgeInsets.only(
            right: 16.0,
            left: (depth + 1) * 16.0,
          ),
        ),
        Divider(),
      ];
      item.kids.forEach((kidId) {
        children.add(Comment(itemId: kidId, itemMap: itemMap, depth: depth + 1));
      });

        return Column(
          children: children,
        );
      },
    );
  }

  Widget buildText(ItemModel item) {
    final htmlStr = item.text.replaceAll('<p>', '\n\n');
    final cleanStr = _parseHtmlString(htmlStr);

    return Text(cleanStr);
  }

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }
}
