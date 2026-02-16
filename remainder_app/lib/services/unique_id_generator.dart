import 'package:android_id/android_id.dart';

Future<String?> userId() async {
  try {
    final androidId = AndroidId();
    final String UID = await androidId.getId() ?? '';
    print("uniqueID:" + UID);
    return UID;
  } catch (err) {
    print("UID Error: ${err.toString()}");
    return null;
  }
}
