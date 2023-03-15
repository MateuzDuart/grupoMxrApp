import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Future<List> PegarApks() async {
    final Uri uri = Uri.parse(
        'https://raw.githubusercontent.com/MateuzDuart/grupoMxrApp/master/dados.json');
    final resposta = await http.get(uri);
    var dados = json.decode(resposta.body) as List;

    List aplicativos = [];

    dados.forEach((dadosApk) {
      Aplicativo aplicativo = Aplicativo(dadosApk['logo'], dadosApk['apk'],
          dadosApk['nome'], dadosApk['nomeApk']);
      aplicativos.add(aplicativo);
    });

    return aplicativos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 65, 65, 65),
        ),
        body: FutureBuilder(
          future: PegarApks(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Text('Carregando...');
            } else {}

            return ListView.builder(
              padding: EdgeInsets.only(
                top: 32,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (context, indice) {
                return Aplicativo(
                    snapshot.data[indice].logo,
                    snapshot.data[indice].apk,
                    snapshot.data[indice].nome,
                    snapshot.data[indice].nomeApk);
              },
            );
          },
        ));
  }
}

class Aplicativo extends StatefulWidget {
  final logo;
  final apk;
  final nome;
  final nomeApk;
  const Aplicativo(this.logo, this.apk, this.nome, this.nomeApk);

  @override
  State<Aplicativo> createState() => _AplicativoState();
}

class _AplicativoState extends State<Aplicativo> {
  
  Future<void> downloadFile(String url, String fileName) async {
  final status = await Permission.storage.request();
  if (status != PermissionStatus.granted) {
    throw Exception('Permissão de armazenamento negada');
  }

  final dir = await getExternalStorageDirectory();
  final filePath = '${dir!.path}/$fileName';

  final response = await http.get(Uri.parse(url));
  final totalBytes = response.contentLength;
  final fileSizeInMB = totalBytes! / (1000 * 1000); 

  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);

  await OpenFile.open(filePath);
}


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        InkWell(
          onTap: () {
            downloadFile(widget.apk, widget.nomeApk);
          }, // Handle your callback
          child: Ink(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.red,
              child: Image.network(widget.logo,
                  errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) =>
                      Text('Erro ao Carregar Imagem'))),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        Text(
          widget.nome,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 40),
        ),
      ]),
    );
  }
}
