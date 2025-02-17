import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  final List messages;
  const MessagesScreen({super.key, required this.messages});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // Libere o controlador para evitar vazamentos
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant MessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    scrollToBottom(); // Role para o final quando a lista for atualizada
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, index) {
        bool isUserMessage = widget.messages[index]['isUserMessage'];
        String messageText = widget.messages[index]['message'].text.text[0];

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment:
                isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUserMessage)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/robot.jpg'), // Imagem do bot
                ),
              SizedBox(width: isUserMessage ? 0 : 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(isUserMessage ? 0 : 20),
                    topLeft: Radius.circular(isUserMessage ? 20 : 0),
                  ),
                  color: isUserMessage
                      ? Colors.grey.shade800
                      : Colors.grey.shade900.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxWidth: w * 0.7),
                child: Text(
                  messageText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: isUserMessage ? 10 : 0),
              if (isUserMessage)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default.jpg'), // Imagem do usuário
                ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => SizedBox(height: 10),
      itemCount: widget.messages.length,
    );
  }
}
