// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';

// class Notifi extends StatefulWidget {
//   const Notifi({super.key});

//   @override
//   State<Notifi> createState() => _NotifiState();
// }

// class _NotifiState extends State<Notifi> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: FilledButton(
//           onPressed: triggernotifications, child: Text("Basic Notifications")),
//     );
//   }

//   triggernotifications() {
//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//           id: 0,
//           channelKey: "basic_channel",
//           title: "Basic Notifications",
//           body: "i am mathiyarasan"),
//     );
//   }
// }
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class Notifi extends StatefulWidget {
  const Notifi({super.key});

  @override
  State<Notifi> createState() => _NotifiState();
}

class _NotifiState extends State<Notifi> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: triggerNotifications,
        child: Text("Basic Notifications"),
      ),
    );
  }

  void requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  void triggerNotifications() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: "basic_channel",
        title: "Basic Notifications",
        body: "I am Mathiyarasan",
      ),
    );
  }
}
