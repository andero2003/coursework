import 'package:cwflutter/src/models/Game.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/FetchResult.dart';

class RobloxAPIService {
  Future<FetchResult<List<Game>?>> fetchUserGames(User user) async {
    final url = Uri.parse('https://games.roblox.com/v2/users/${user.user_id}/games');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Game> games = [];
      for (dynamic item in data['data']) {
        games.add(Game(
          game_id: item['id'], 
          game_title: item['name'], 
          game_description: item['description'] ?? 'N/A', 
          game_icon: (await fetchGameIconById(item['id'])).data!,
          game_thumbnail: (await fetchGameThumbnailById(item['id'])).data!,
        ));
      }
      return FetchResult(ResultStatus.success, games);  // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<List<Game>?>> fetchGroupGames(int groupId) async {
    final url = Uri.parse('https://games.roblox.com/v2/groups/$groupId/games?accessFilter=2&limit=100&sortOrder=Asc');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Game> games = [];
      for (dynamic item in data['data']) {
        games.add(Game(
          game_id: item['id'], 
          game_title: item['name'], 
          game_description: item['description'] ?? 'N/A', 
          game_icon: (await fetchGameIconById(item['id'])).data!,
          game_thumbnail: (await fetchGameThumbnailById(item['id'])).data!,
        ));
      }
      return FetchResult(ResultStatus.success, games);  // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<List<int>?>> fetchUserOwnedGroups(User user) async {
    final url = Uri.parse('https://groups.roblox.com/v2/users/${user.user_id}/groups/roles');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<int> ownedGroups = [];
      for (dynamic item in data['data']) {
        if (item['role']['rank'] == 255) {
          ownedGroups.add(item['group']['id']);
        }
      }
      return FetchResult(ResultStatus.success, ownedGroups); 
    } else {
      return FetchResult(ResultStatus.failure, null);
    }   
  }

  Future<FetchResult<List<User>?>> searchUsers(String keyword) async {
    final url = Uri.parse('https://users.roblox.com/v1/users/search?keyword=$keyword&limit=10');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<User> users = [];
      for (dynamic item in data['data']) {
        users.add(
          User(
            user_id: item['id'], 
            username: item['name'], 
            avatar_image: (await getUserIconsByIds([item['id']])).data![item['id']]!
          )
        );
      }
      return FetchResult(ResultStatus.success, users);
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<Map<int, String>?>> getUserIconsByIds(List<int> userIds) async {
    final url = Uri.parse('https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${userIds.join(',')}&size=48x48&format=Png&isCircular=false');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final Map<int, String> mapping = {};
      for (dynamic item in data['data']) {
        mapping[item['targetId']] = item['imageUrl'];
      }
      return FetchResult(ResultStatus.success, mapping);
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<String?>> fetchGameIconById(int universeId) async {
    final url = Uri.parse('https://thumbnails.roblox.com/v1/games/icons?universeIds=$universeId&returnPolicy=PlaceHolder&size=256x256&format=Png&isCircular=false');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data['data'][0]['imageUrl']);
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<String?>> fetchGameThumbnailById(int universeId) async {
    final url = Uri.parse('https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=$universeId&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data['data'][0]['thumbnails'][0]['imageUrl']);
    } else {
      return FetchResult(ResultStatus.failure, null);
    }
  }

  Future<FetchResult<List<Game>?>> fetchAllUserGames(User user) async {
    List<Game> allGames = [];

    // Fetch user's personal games
    FetchResult<List<Game>?> userGamesResult = await fetchUserGames(user);
    if (userGamesResult.status == ResultStatus.success) {
      allGames.addAll(userGamesResult.data!); // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, null);
    }

    // Fetch groups owned by the user
    FetchResult<List<int>?> userOwnedGroupsResult = await fetchUserOwnedGroups(user);
    if (userOwnedGroupsResult.status == ResultStatus.success) {
      List<int> ownedGroups = userOwnedGroupsResult.data!;

      // Fetch games for each owned group
      for (int groupId in ownedGroups) {
        FetchResult<List<Game>?> groupGamesResult = await fetchGroupGames(groupId);
        if (groupGamesResult.status == ResultStatus.success) {
          allGames.addAll(groupGamesResult.data!);  // Assuming the games data is under a 'data' key
        } else {
          continue;
        }
      }
    } else {
      return FetchResult(ResultStatus.failure, null);
    }

    return FetchResult(ResultStatus.success, allGames);
  }

}
