import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:on_audio_query/on_audio_query.dart';

List<String> Data = ['VietNam', 'America', 'China', 'England'];

List<SongModel> songList = [];

class CustomSearch extends SearchDelegate {
  @override
  String? get searchFieldLabel => 'Search for song, artists, albums';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
              })
          : IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text(
                          "Press the button and start speaking",
                          textAlign: TextAlign.center,
                        ),
                        children: [
                          Container(
                            child: IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: () {
                                //Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            child: TextButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      );
                    });
              })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in Data) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }

    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
            onTap: () {
              query = result;
            },
          );
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in allSongs) {
      if (item.displayNameWOExt.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item.displayNameWOExt);
      }
    }

    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
            onTap: () {
              query = result;
            },
          );
        });
  }
}
