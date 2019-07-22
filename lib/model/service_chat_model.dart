import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

class ServiceChatModel extends ChangeNotifier {
  static ServiceChatModel of(BuildContext context) {
    return Provider.of<ServiceChatModel>(context, listen: false);
  }

  IOWebSocketChannel _currentChannel;

  Set<IChatUser> _currentChatUsers = Set();
  IChatUser _chatSelf;

  List<IChatMessage> _messages = [];

  IOWebSocketChannel get currentChannel => _currentChannel;

  Set<IChatUser> get currentChatUsers => _currentChatUsers ?? Set();

  get userCount => currentChatUsers.length;

  IChatUser get chatSelf => _chatSelf;

  List<IChatMessage> get messages => _messages;

  void addUser(ChatUser user) {
    if (_currentChatUsers.add(user)) {
      notifyListeners();
    }
  }
}

abstract class IChatUser {
  String userId;
  String userAvatar;
  String userName;

  IChatUser(this.userId, this.userAvatar, this.userName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IChatUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

abstract class IChatMessage {
  String content;
}

class ChatUser extends IChatUser {
  ChatUser(
    String userId,
    String userAvatar,
    String userName,
  ) : super(
          userId,
          userAvatar,
          userName,
        );
}
