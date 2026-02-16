import 'package:dio/dio.dart';

class ReminderAPI {
  static List<Map<String, dynamic>> datas = [];
  static const String url = 'http://192.168.1.10:2000/reminder/';
  static List<Map<String, dynamic>> reschedules = [];
  
 static Future<List<Map<String, dynamic>>> fetchReminders({
    required String id,
  }) async {
    try {
      final Response res = await Dio().get('${url}home', data: {'id': id});
      datas = (res.data as List).cast<Map<String, dynamic>>();
      return datas;
    } catch (err) {
      print("Error while fetching data: ${err.toString()}");
      return datas;
    }
  }

  static Future<bool> insertReminders({
    required int id,
    required String reminder,
    required String time,
    required String period,
    required bool isActive,
    required String userId,
  }) async {
    try {
      final Response res = await Dio().post(
        url + "alarm",
        data: {
          "id": id,
          "reminder": reminder,
          "time": time,
          "period": period,
          'isActive': isActive,
          "userId": userId,
        },
      );
      bool inserted = res.data['inserted'];
      return inserted;
    } catch (err) {
      print("Error while inserting datas ${err.toString()}");
      return false;
    }
  }

  static Future<bool> deleteScheduler({required int id}) async {
    try {
      final Response res = await Dio().delete(
        url + 'deleteScheduler',
        queryParameters: {'id': id},
      );
      bool result = res.data['deleted'];
      return result;
    } catch (err) {
      return false;
    }
  }

  static Future<bool> alarmUpdate({
    required int id,
    required bool isActive,
  }) async {
    try {
      final Response res = await Dio().put(
        url + 'cancelAlarm',
        queryParameters: {'id': id, 'isActive': isActive},
      );
      return res.data['updated'];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> alarmTimeUpdate({
    required int id,
    required String alarmTime,
  }) async {
    try {
      final Response res = await Dio().put(
        '${url}updateAlarm',
        queryParameters: {'id': id, 'time': alarmTime},
      );
      return res.data['updated'];
    } catch (err) {
      return false;
    }
  }

  static Future<bool> reminderUpdate({
    required String desp,
    required int id,
  }) async {
    try {
      final Response res = await Dio().put(
        '${url}reminderUpdate',
        queryParameters: {'desp': desp, 'id': id},
      );
      print(res);
      return res.data['updated'];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkUserId({required String id}) async {
    try {
      print('id: ' + id);
      final Response res = await Dio().post(
        "${url}userIdCheck",
        queryParameters: {'id': id},
      );
      print(res.statusCode);
      return res.data['status'];
    } catch (err) {
      return false;
    }
  }
}
