import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:little_white_one/models/chat_message.dart';

import '../main.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum LwBot { two, three }

class _MyHomePageState extends State<MyHomePage> {
  static const String subtitle2 = '勉强能聊天的傻子机器人';
  static const String subtitle3 = '蠢得不行得一直训练的机器人';

  TextEditingController _msgController;
  TextEditingController _userNameController;
  List<ChatMessage> _messages;
  LwBot _lwBot = LwBot.two;

  String get generation => _lwBot == LwBot.two ? '第二代' : '第三代';

  _MyHomePageState() {
    _messages = [];
  }

  @override
  void initState() {
    _msgController = TextEditingController();
    _userNameController = TextEditingController();
    _userNameController.text = Global.username;
    _messages.add(ChatMessage('小白提示', '要先设置用户名才可以和小白机器人聊天哦（点击右上角设置）', client: Global.clientName));
    super.initState();
  }

  @override
  void dispose() {
    Global.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${widget.title} $generation'),
            Text(_lwBot == LwBot.two ? subtitle2 : subtitle3, style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<LwBot>(
            icon: Icon(Icons.settings),
            onSelected: (LwBot result) {
              setState(() {
                _lwBot = result;
              });
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<LwBot>>[
                PopupMenuItem<LwBot>(
                  value: LwBot.two,
                  child: Text('小白第二代'),
                ),
                PopupMenuItem<LwBot>(
                  value: LwBot.three,
                  child: Text('小白第三代'),
                ),
              ];
            },
          ),
          IconButton(icon: Icon(Icons.person), onPressed: _setUserName),
        ],
      ),
      body: _buildBody(),
    );
  }

  void _setUserName() async {
    var onPressed = () {
      Global.username = _userNameController.text;
      Global.save();
      BotToast.showText(text: '已保存。');
      Navigator.of(context).pop();
      setState(() {});
    };

    if (Global.username != null) onPressed = null;

    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('请设置用户名'),
            children: <Widget>[
              SimpleDialogOption(
                child: TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(hintText: '请输入用户名'),
                  readOnly: Global.username == null ? false : true,
                  onSubmitted: (content) {
                    _userNameController.text = content;
                    Global.username = content;
                    Global.save();
                    BotToast.showText(text: '已保存。');
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ),
              SimpleDialogOption(
                child: Text('用户名只可以设置一次'),
              ),
              SimpleDialogOption(
                child: RaisedButton(
                  child: Text('确定'),
                  onPressed: onPressed,
                ),
              ),
            ],
          );
        });
  }

  void _addMsg({String username, String content, DateTime sentTime, String client}) {
//    print('$username,$content,$sentTime');
    _messages.add(ChatMessage(username, content, sentTime: sentTime, client: client));
    setState(() {});
  }

  void _sendMessage(String userName, String content) async {
    _addMsg(username: userName, content: content);
    var answer = '[暂无回答]';
    if (_lwBot == LwBot.two)
      answer = await Global.ask2(content);
    else
      answer = await Global.ask3(content);
    _addMsg(username: '小白', content: answer);
  }

  Widget _buildBody() {
    var tempMessages = _messages.reversed;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            reverse: true,
            children: <Widget>[
              for (var msg in tempMessages) _buildMsgCard(username: msg.userName, content: msg.content, sentTime: msg.sentTimeStr, client: msg.client),
            ],
          ),
        ),
        _buildBottom()
      ],
    );
  }

  Widget _buildBottom() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        controller: _msgController,
        maxLength: 200,
        maxLengthEnforced: true,
        decoration: InputDecoration(
          labelText: '输入消息',
          hintText: '输入消息',
          prefixIcon: Icon(Icons.message),
          helperText: '小白机器人目前仍处于开发阶段，请多多包涵~',
          contentPadding: EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onSubmitted: (content) async {
          if (Global.username != null) {
            _sendMessage(Global.username, _msgController.text);
            _msgController.clear();
          } else {
            BotToast.showText(text: '请先设置用户名才可以发送消息');
          }
        },
      ),
    );
  }

  Widget _buildMsgCard({String username, String content, String sentTime, String client}) {
    if (username == Global.username)
      // 右边
      return Card(
        child: ListTile(
          trailing: Icon(Icons.person, size: 40),
          title: Text(username, textAlign: TextAlign.right),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(content),
              Text('$sentTime - $client', textAlign: TextAlign.right, style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    else
      // 左边
      return Card(
        child: ListTile(
          leading: Icon(Icons.adb, size: 40, color: Global.randomColor()),
          title: Text(username),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text(content), Text('$sentTime - $client', style: TextStyle(fontSize: 10))],
          ),
        ),
      );
  }
}
