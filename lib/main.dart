import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:io' show Platform;


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

 void showNotification(RemoteMessage message) async {
  
    var title = message.data["nt"];
    var msge = message.data["nm"];
    var payload =message.data;
    var android =  new AndroidNotificationDetails(
        'fluttertest', 'channel NAME',
        priority: Priority.max, importance: Importance.max);

    var platform = new NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(0, title, msge, platform,
        payload: payload.toString());
      
        CleverTapPlugin.pushNotificationViewedEvent(message.data);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
   showNotification(message);
  //CleverTapPlugin.createNotification(jsonEncode(message.data));
  print('on message'+message.data["nm"]+"working");
}
// void main() {
//   runApp(const MyApp());
// }

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   var details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (details!.didNotificationLaunchApp) {
     print(details.payload.toString()+"testing payload");
     List<String> str = details.payload!.replaceAll("{","").replaceAll("}","").split(",");
     Map<String,dynamic> result = {};
    for(int i=0;i<str.length;i++){
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    print(result);

    CleverTapPlugin.pushNotificationClickedEvent(result);
  }

  await Firebase.initializeApp();
  await init();
  runApp(MyApp()); //this is different

}

 Future<void> init() async {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
        var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
       flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onselectnotificaion);
  
 } 

Future<dynamic> onselectnotificaion(String? payload) async {
  List<String> str = payload!.replaceAll("{","").replaceAll("}","").split(",");
  Map<String,dynamic> result = {};
  for(int i=0;i<str.length;i++){
    List<String> s = str[i].split(":");
    result.putIfAbsent(s[0].trim(), () => s[1].trim());
  }
  print(result);
  CleverTapPlugin.pushNotificationClickedEvent(result);
     
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late CleverTapPlugin _clevertapPlugin;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

   @override
   void initState() {
      super.initState();

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) async {
              print("This is working+++++"+jsonEncode(message));
              showNotification(message!);         
          }); 
      
      FirebaseMessaging.instance.getToken().then((value) {
            String? token = value;
            if(Platform.isAndroid)
            {
               print("FCM Token is"+token!);
               CleverTapPlugin.setPushToken(value!);
            }
      }); 

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          showNotification(message);
          print(jsonEncode(message.data));
     //   CleverTapPlugin.createNotification(jsonEncode(message.data));
          print(message.data);
     
      });
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);  
   }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
