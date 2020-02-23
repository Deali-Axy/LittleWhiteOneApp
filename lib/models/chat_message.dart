import '../main.dart';

class ChatMessage {
  String userName;
  String content;
  DateTime sentTime;

  String get sentTimeStr {
    var now = DateTime.now();
    var duration = now.difference(sentTime);

    var seconds = duration.inSeconds;
    var minutes = duration.inMinutes;
    var hours = duration.inHours;

    var timeStr = '';
    if (seconds < 60) timeStr = '$seconds 秒前';
    if (seconds >= 60 && minutes < 60) timeStr = '$minutes 分钟前';
    if (hours >= 1) timeStr = '$hours 小时前';

    return timeStr;
  }

  String client;

  ChatMessage(this.userName, this.content, {this.sentTime, this.client}) {
    this.sentTime = sentTime ?? DateTime.now();
    this.client = client ?? Global.clientName;
  }
}