import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Messages.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot em PHQ9',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey),
        ),
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> messages = [];
  List<int> respostas = []; 

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brazilTimeZone = tz.getLocation('America/Sao_Paulo');
    final nowInBrazil = tz.TZDateTime.now(brazilTimeZone);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot em PHQ9'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Hoje, ${DateFormat("Hm").format(nowInBrazil)}",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ),
          Expanded(child: MessagesScreen(messages: messages)),
          MessageInputField(
            controller: _controller,
            focusNode: _focusNode,
            onSend: (text) {
              sendMessage(text);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget chatBubble(String message, bool isUserMessage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            CircleAvatar(
              backgroundImage:
                  AssetImage("assets/robot.jpg"), // Caminho da imagem do bot
              radius: 20,
            ),
          SizedBox(width: 10),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Colors.orangeAccent
                    : Color.fromRGBO(23, 157, 139, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isUserMessage) SizedBox(width: 10),
          if (isUserMessage)
            CircleAvatar(
              backgroundImage: AssetImage(
                  "assets/default.jpg"), // Caminho da imagem do usuário
              radius: 20,
            ),
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) {
      print('A mensagem está vazia');
      return;
    }

    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.queryResult != null &&
        response.queryResult!.fulfillmentMessages != null) {
      for (var msg in response.queryResult!.fulfillmentMessages!) {
        setState(() {
          addMessage(Message(text: msg.text));
        });

        if (msg.text?.text != null && isNumeric(text)) {
          respostas.add(int.parse(text));
        }

        if (respostas.length == 9) {
          int resultado = respostas.reduce((a, b) => a + b);
          mostrarResultado(resultado);
          respostas.clear();
        }
      }
    }
    _focusNode.requestFocus();
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    setState(() {
      messages.add({
        'message': message,
        'isUserMessage': isUserMessage,
      });
    });
  }

  void mostrarResultado(int resultado) {
    String interpretacao;
    if (resultado <= 4) {
      interpretacao = "Nenhuma ou mínima depressão.";
    } else if (resultado <= 9) {
      interpretacao = "Depressão leve.";
    } else if (resultado <= 14) {
      interpretacao = "Depressão moderada.";
    } else if (resultado <= 19) {
      interpretacao = "Depressão moderadamente grave.";
    } else {
      interpretacao = "Depressão grave.";
    }

    setState(() {
      addMessage(
        Message(
          text: DialogText(
            text: [
              "Sua pontuação foi $resultado.\n$interpretacao",
            ],
          ),
        ),
      );
    });
  }

  bool isNumeric(String s) {
    if (s.isEmpty) return false;
    final n = num.tryParse(s);
    return n != null;
  }
}

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSend;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: Colors.white),
              onSubmitted: onSend,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              onSend(controller.text);
            },
            icon: Icon(Icons.send, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
