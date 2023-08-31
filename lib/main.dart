import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mxr/state/app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AppProvider(), child: const MyApp()));
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
  // ignore: non_constant_identifier_names
  Future<List> PegarApks() async {
    final status = await Permission.accessMediaLocation.request();
    final Uri uri = Uri.parse(
        'https://raw.githubusercontent.com/MateuzDuart/grupoMxrApp/master/dados.json');
    final resposta = await http.get(uri);
    var dados = json.decode(resposta.body) as List;

    List aplicativos = [];

    dados.forEach((dadosApk) {
      context
          .read<AppProvider>()
          .increment(dadosApk['nome'], dadosApk['nomeInstalado']);

      Aplicativo aplicativo = Aplicativo(dadosApk['logo'], dadosApk['apk'],
          dadosApk['nome'], dadosApk['nomeApk'], dadosApk['nomeInstalado']);
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

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 56.0,
              ),
              padding: EdgeInsets.only(
                top: 32,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (context, indice) {
                return Aplicativo(
                    snapshot.data[indice].logo,
                    snapshot.data[indice].apk,
                    snapshot.data[indice].nome,
                    snapshot.data[indice].nomeApk,
                    snapshot.data[indice].nomeInstalado);
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
  final nomeInstalado;
  const Aplicativo(
      this.logo, this.apk, this.nome, this.nomeApk, this.nomeInstalado);

  @override
  State<Aplicativo> createState() => _AplicativoState();
}

class _AplicativoState extends State<Aplicativo> {
  int totTentativa = 0;
  Future<void> downloadFile(String url, String fileName) async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permissão de armazenamento negada');
    }
    if (!context.read<AppProvider>().apps[widget.nome]['instalado']) {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/$fileName.apk';
      print(filePath);
      final file = File(filePath);
      var existe = await file.exists();
      if (existe && totTentativa < 1) {
        await OpenFile.open(filePath);
        Navigator.pop(context);
        totTentativa++;
      } else {
        final response = await http.get(Uri.parse(url));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(filePath);
        Navigator.pop(context);
      }
    }
  }

  void _showPopup(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Baixando ${widget.nome}'),
          content: Container(
            child: CircularProgressIndicator(
              color: Colors.black54,
            ),
            width: 50,
            height: 50,
          ),
          actions: [],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: () {
          setState(() {
            if (!context.read<AppProvider>().apps[widget.nome]['instalado']) {
              context.read<AppProvider>().apps[widget.nome]['cor'] =
                  Colors.blue;
              _showPopup(context);

              downloadFile(widget.apk, widget.nome);
            } else {
              context.read<AppProvider>().apps[widget.nome]['cor'] =
                  Colors.green;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('${widget.nome} já Baixando'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Fechar'),
                      ),
                    ],
                  );
                },
              );
            }
            context
                .read<AppProvider>()
                .getInstalledApps(widget.nome, widget.nomeInstalado);
          });
        },
        child: Ink(
          height: MediaQuery.of(context).size.width * 0.25,
          width: MediaQuery.of(context).size.width * 0.25,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(widget.logo,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) =>
                      Text('Erro ao Carregar Imagem')),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: context.read<AppProvider>().apps[widget.nome]['cor'],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 8),
      ),
      Text(
        widget.nome,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
