import 'package:http/http.dart' as http;
import 'dart:convert';

enum ResultStatus { success, failure }

// Define a class to represent the result of the fetch operation
class FetchResult {
  final ResultStatus status;
  final dynamic data;

  FetchResult(this.status, this.data);
}

class GameParser {
  Future<FetchResult> fetchUserGames(int userId) async {
    final url = Uri.parse('https://games.roblox.com/v2/users/$userId/games');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);  // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load games: ${response.statusCode}');
    }
  }

  Future<FetchResult> fetchGroupGames(int groupId) async {
    final url = Uri.parse('https://games.roblox.com/v2/groups/$groupId/games?accessFilter=2&limit=100&sortOrder=Asc');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);  // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load games: ${response.statusCode}');
    }
  }

  Future<FetchResult> fetchUserOwnedGroups(int userId) async {
    final url = Uri.parse('https://groups.roblox.com/v2/users/$userId/groups/roles');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final ownedGroups = data['data'].where((item) => item['role']['rank'] == 255).toList();
      return FetchResult(ResultStatus.success, ownedGroups); 
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load games: ${response.statusCode}');
    }   
  }

  Future<FetchResult> searchUsers(String keyword) async {
    final url = Uri.parse('https://users.roblox.com/v1/users/search?keyword=$keyword&limit=10');
    final response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load users: ${response.statusCode}');
    }
  }

  Future<FetchResult> getUserInfo(int userId) async {
    final url = Uri.parse('https://users.roblox.com/v1/users/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load user info: ${response.statusCode}');
    }
  }

  Future<FetchResult> getUserIcons(List<int> userIds) async {
    final url = Uri.parse('https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${userIds.join(',')}&size=48x48&format=Png&isCircular=false');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load user info: ${response.statusCode}');
    }
  }

  Future<FetchResult> fetchGameMedia(int universeId) async {
    final url = Uri.parse('https://thumbnails.roblox.com/v1/games/icons?universeIds=$universeId&returnPolicy=PlaceHolder&size=256x256&format=Png&isCircular=false');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load media: ${response.statusCode}');
    }
  }

  Future<FetchResult> fetchGameInfo(int universeId) async {
    final url = Uri.parse('https://games.roblox.com/v1/games?universeIds=$universeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FetchResult(ResultStatus.success, data);
    } else {
      return FetchResult(ResultStatus.failure, 'Failed to load media: ${response.statusCode}');
    }
  }

  Future<FetchResult> fetchAllUserGames(int userId) async {
    List<dynamic> allGames = [];

    // Fetch user's personal games
    FetchResult userGamesResult = await fetchUserGames(userId);
    if (userGamesResult.status == ResultStatus.success) {
      allGames.addAll(userGamesResult.data['data']); // Assuming the games data is under a 'data' key
    } else {
      return FetchResult(ResultStatus.failure, userGamesResult.data);
    }

    // Fetch groups owned by the user
    FetchResult userOwnedGroupsResult = await fetchUserOwnedGroups(userId);
    if (userOwnedGroupsResult.status == ResultStatus.success) {
      List<dynamic> ownedGroups = userOwnedGroupsResult.data;

      // Fetch games for each owned group
      for (var group in ownedGroups) {
        FetchResult groupGamesResult = await fetchGroupGames(group['group']['id']);
        if (groupGamesResult.status == ResultStatus.success) {
          allGames.addAll(groupGamesResult.data['data']);  // Assuming the games data is under a 'data' key
        } else {
          // If fetching games for a group fails, you can decide to continue with the next group
          // or return a failure. Here, we continue with the next group.
          continue;
        }
      }
    } else {
      return FetchResult(ResultStatus.failure, userOwnedGroupsResult.data);
    }

    return FetchResult(ResultStatus.success, allGames);
  }

}
