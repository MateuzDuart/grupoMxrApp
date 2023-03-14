import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const MyHomePage(title: 'Grupo MRX'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> downloadFile(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var totalBytes = response.contentLength;
    var bytesReceived = StreamController<int>();
    var dir = await getExternalStorageDirectory();
    File file = File("${dir!.path}/$fileName");
    await file.writeAsBytes(response.bodyBytes);

    final bytes = response.bodyBytes;
    final buffer = List<int>.filled(1024 * 1024, 0);
    var offset = 0;


    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 65, 65, 65),
        ),
        body: InkWell(
          onTap: () {
            downloadFile(
                'https://app.paraibahost.com.br/mobile/dl/apk/63a089110c5d1c735c7016a2',
                'fileName.apk');
          }, // Handle your callback
          child: Ink(height: 100, width: 100, color: Colors.red),
        ));
  }
}
