import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class ActionHandler {
  Future<void> launchApp(String packageName, String activity) async {
    try {
      if (packageName.isNotEmpty && activity.isNotEmpty) {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          componentName: '$packageName/$activity',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else {
        print('Error: Package name or activity is empty');
      }
    } catch (e) {
      print('Error launching app: $e');
    }
  }
}
