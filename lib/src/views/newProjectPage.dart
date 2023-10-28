import 'package:cwflutter/src/models/Game.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:cwflutter/src/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/FetchResult.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

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

      body: FutureBuilder<FetchResult<List<Game>?>>(
        future: RobloxAPIService().fetchAllUserGames(Provider.of<AuthService>(context).loggedUser!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data?.status == ResultStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64,),
                    const SizedBox(height: 10,),
                    Text('Failed to load games: error code ${snapshot.data?.data}. Please check your connection and try again.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 26),),
                  ],
                ),
              )
            );
          } else {
            final games = snapshot.data!.data!;

            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];

                // build your game widgets
                return GameCardButton(
                  game: game, 
                  onPressed: () {
                    Provider.of<ProjectService>(context, listen: false).initialiseProjectForGame(game);
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