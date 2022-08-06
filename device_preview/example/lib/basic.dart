import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicApp extends StatelessWidget {
  const BasicApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic'),
      ),
      body: Column(
        children: [
          FutureBuilder<bool>(
            future: SharedPreferences.getInstance().then(
              (value) async => Future.value(
                value.getBool('example_bool_cached'),
              ),
            ),
            builder: ((context, snapshot) {
              return Column(
                children: [
                  Text(
                    'This example app has ${snapshot.data == true ? '1 item in' : 'no'} cached data.',
                  ),
                  ElevatedButton(
                    child: Text(
                      snapshot.data == true
                          ? 'Delete boolean from cache'
                          : 'Save boolean to cache',
                    ),
                    onPressed: () async {
                      if (snapshot.data == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('example_bool_cached');
                        setState(() {});
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('example_bool_cached', true);
                        setState(() {});
                      }
                    },
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: ListView(
              children: [
                ...Iterable.generate(
                  100,
                  (i) => ListTile(
                    title: Text('Tile $i'),
                    onTap: () {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
