import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 65, 65, 65),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 32),
          children: [Aplicativo()],
        ));
  }
}

class Aplicativo extends StatefulWidget {
  @override
  State<Aplicativo> createState() => _AplicativoState();
}

class _AplicativoState extends State<Aplicativo> {
  Future downloadFile(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var totalBytes = response.contentLength;
    final tamanho = totalBytes! / 1000 / 1000;
    final bytesReceived = StreamController();
    var dir = await getExternalStorageDirectory();
    File file = File("${dir!.path}/$fileName");
    await file.writeAsBytes(response.bodyBytes);

    final request = http.Request('GET', Uri.parse(url));
    final streamedResponse = await request.send();

    await streamedResponse.stream.map((chunk) {
      bytesReceived.add(chunk.length);
      return chunk;
    }).pipe(file.openWrite());
    var recebidos = 0;
    bytesReceived.stream.listen((bytes) {
      recebidos += bytes as int;
      final progress = (recebidos / totalBytes) * 100;
      print('Download progress: $progress%');
    });

    // return file;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        InkWell(
            onTap: () {
              downloadFile(
                  'https://github.com/MateuzDuart/grupoMxrApp/raw/master/apks/Acesso_PDV_4.0.4.apk',
                  'fileName.apk');
            }, // Handle your callback
            child: Ink(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.red,
              child: Image.network(
                  'https://involusite.tk/Imagens/logo-involusite-simplificada.png'),
            )),
        Padding(
          padding: EdgeInsets.only(top: 16),
        ),
        Text('bla bla bla bla bla bla',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
      ]),
    );
  }
}
