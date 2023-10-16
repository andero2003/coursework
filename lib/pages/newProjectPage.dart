import 'package:cwflutter/services/DatabaseService.dart';
import 'package:cwflutter/classes/GameData.dart';
import 'package:cwflutter/classes/GameParser.dart';
import 'package:cwflutter/pages/dashboard.dart';
import 'package:flutter/material.dart';

class NewProjectPage extends StatefulWidget {
  final int userId;

  const NewProjectPage({super.key, required this.userId});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game'),
      ),

      body: FutureBuilder<FetchResult>(
        future: GameParser().fetchAllUserGames(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data?.status == ResultStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64,),
                    SizedBox(height: 10,),
                    Text('Failed to load games: error code ${snapshot.data?.data}. Please check your connection and try again.', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 26),),
                  ],
                ),
              )
            );
          } else {
            final games = snapshot.data!.data;

            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final mediaFuture = GameParser().fetchGameMedia(game['id']);
                final GameData gameData = GameData(id: game['id']);

                // build your game widgets
                return GameCardButton(
                  gameData: gameData, 
                  mediaFuture: mediaFuture, 
                  onPressed: () {
                    DatabaseService().setupProject(widget.userId, game['id']);
                    Navigator.pop(context);
                  }
                );
              },
            );
          }
        },
      )
    );
  }
}