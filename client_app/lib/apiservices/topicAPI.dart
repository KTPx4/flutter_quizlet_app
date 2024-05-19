import 'dart:convert';
import 'dart:io';

import 'package:client_app/models/topic.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';

const WEB_URL = 'http://localhost:3000'; // kết nối từ web
const ANDROID_URL = 'http://10.0.2.2:3000'; // kết nối từ máy ảo android
// const ANDROID_URL = 'https://flutter-quizlet-app.onrender.com'; // kết nối từ máy ảo android
// const WEB_URL = 'https://flutter-quizlet-app.onrender.com'; // kết nối từ web

const KEY_LOGIN = "quizlet-login";

class TopicAPI {
  static final TopicAPI _instance = TopicAPI._init();
  // Existing code...
  TopicAPI._init();
  factory TopicAPI() {
    return _instance;
  }
  static String getServer() {
    var url = ANDROID_URL;
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      url = WEB_URL;
    }
    return url;
  }

  static String getLink() {
    var url = ANDROID_URL + "/api";
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      url = WEB_URL + "/api";
    }
    return url;
  }

  // Get all public topics
  static Future<Map<String, dynamic>> getPublicTopics() async {
    try {
      var server = getLink();
      var link = "$server/topic/public";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'topics': resBody["data"]};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to fetch public topics. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Get all public topics of account id
  static Future<Map<String, dynamic>> getPublicTopicsByUser(
      {required String accountID}) async {
    try {
      var server = getLink();

      var link = "$server/account/$accountID/public";

      var pref = await SharedPreferences.getInstance();

      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {
          'success': true,
          'topics': resBody["data"],
          "count": resBody["count"]
        };
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to fetch public topics. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Get all topics of the account
  static Future<Map<String, dynamic>> getAccountTopics() async {
    try {
      var server = getLink();
      var link = "$server/topic/";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'topics': resBody["data"]};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to fetch account topics. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Add a new topic for the account
  static Future<Map<String, dynamic>> addTopic({required Topic topic}) async {
    try {
      var link = "${getLink()}/topic";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var body = jsonEncode({
        'topicName': topic.topicName,
        'desc': topic.desc,
        'isPublic': topic.isPublic,
      });

      var res = await http.post(
        Uri.parse(link),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: body,
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, '_id': resBody["data"]["_id"]};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to add topic. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Edit a topic
  static Future<Map<String, dynamic>> editTopic(
      {required String id, required Topic topic}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var body = jsonEncode({
        '_id': id,
        'topicName': topic.topicName,
        'desc': topic.desc,
        'isPublic': topic.isPublic,
      });

      var res = await http.patch(
        Uri.parse(link),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: body,
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': "Topic edited successfully"};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to edit topic. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Delete a topic
  static Future<Map<String, dynamic>> deleteTopic({required String id}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.delete(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': "Topic deleted successfully"};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to delete topic. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Get a topic by ID
  static Future<Map<String, dynamic>> getTopicById({required String id}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {

        return {'success': true, 'topic': resBody["data"]};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to fetch topic. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Add new words to a topic
  static Future<Map<String, dynamic>> addWordsToTopic(
      {required String id, required List<Word> words}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id/word";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var body = jsonEncode(
          {'words': words.map((word) => word.addWordToJson()).toList()});

      var res = await http.post(
        Uri.parse(link),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: body,
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': "Words added successfully"};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to add words. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Edit words in a topic
  static Future<Map<String, dynamic>> editWordsInTopic(
      {required String id, required List<Word> words}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var body = jsonEncode({
        'words': words.map((word) => word.editWordToJson()).toList(),
      });

      var res = await http.patch(
        Uri.parse(link),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: body,
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': "Words edited successfully"};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to edit words. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  // Delete words in a topic
  static Future<Map<String, dynamic>> deleteWordsInTopic(
      {required String id, required String wordId}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$id/word/$wordId";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.delete(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': "Words deleted successfully"};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to delete words. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getWordsInTopic(
      {required String topicId}) async {
    try {
      var server = getLink();
      var link = "$server/topic/$topicId/word";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        var words = (resBody["data"] as List)
            .map((wordData) => Word.fromJson(wordData))
            .toList();
        return {
          'success': true,
          'message': resBody["message"],
          'count': resBody["count"],
          'words': words
        };
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to fetch words. Please try again later!",
        'exception': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateWordMark(
      String topicId, String wordId, bool mark) async {
    try {
      var server = getLink();
      var link = "$server/topic/$topicId/word?wordid=$wordId&mark=$mark";
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(KEY_LOGIN);

      var res = await http.get(
        Uri.parse(link),
        headers: {"Authorization": "Bearer $token"},
      );

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'message': resBody["message"]};
      }

      return {'success': false, 'message': resBody["message"]};
    } catch (e) {
      return {
        'success': false,
        'message': "Failed to update word mark. Please try again later!",
        'exception': e.toString(),
      };
    }
  }
}
