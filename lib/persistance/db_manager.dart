import 'package:ease_life/interaction/websocket_manager.dart';
import 'package:sqflite/sqflite.dart';

class ChatMessage {
  String fromId;
  String fromAvatar;
  String toId;

  String content;
  MessageType type;
  ConnectStatus status;
  int duration;
  String group;
  int sendTime;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map[columnFromId] = fromId;
    map[columnFromAvatar] = fromAvatar;
    map[columnToId] = toId;
    map[columnContent] = content;
    map[columnType] = type.index;
    map[columnStatus] = status?.index ?? 0;
    map[columnDuration] = duration;
    map[columnSendTime] = sendTime;
    map[columnSendTime] = sendTime;
    map[columnGroup] = group;
    return map;
  }

  ChatMessage.fromMap(Map<String, dynamic> map) {
    this.fromId = map[columnFromId];
    this.fromAvatar = map[columnFromAvatar];
    this.toId = map[columnToId];
    this.group = map[columnGroup];
    this.content = map[columnContent];
    this.type = MessageType.values[map[columnType] ?? 0];
    this.status = ConnectStatus.values[map[columnStatus] ?? 2];
    this.duration = map[columnDuration];
    this.sendTime = map[columnSendTime];
  }

  ChatMessage.fromMessage(WSMessage message) {
    this.content = message.content;
    this.type = message.type;
    this.status = message.status;
    this.duration = message.duration?.toInt();
    this.fromId = message.fromId;
    this.fromAvatar = message.fromAvatar;
    this.toId = message.toId;
    this.group = message.group;
    this.sendTime = message.sendTime;
  }

  WSMessage toMessage() {
    return WSMessage(content,
        type: type,
        status: status,
        duration: duration?.toDouble(),
        fromId: fromId,
        fromAvatar: fromAvatar,
        toId: toId,
        sendTime: sendTime,
        group: group);
  }

  @override
  String toString() {
    return 'ChatMessage{fromId: $fromId, fromAvatar: $fromAvatar, toId: $toId, content: $content, type: $type, status: $status, duration: $duration, group: $group, sendTime: $sendTime}';
  }
}

String tableName = "t_chat_messages";
String columnId = "_id";
String columnFromId = "from_id";
String columnFromAvatar = "from_avatar";
String columnToId = "to_id";
String columnContent = "content";
String columnType = "type";
String columnStatus = "status";
String columnDuration = "duration";
String columnSendTime = "send_time";
String columnGroup = "_group";
String sql = '''
CREATE table $tableName ( 
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnFromId TEXT NOT NULL,
  $columnFromAvatar TEXT NOT NULL,
  $columnToId TEXT NOT NULL,
  $columnContent TEXT NOT NULL,
  $columnGroup TEXT NOT NULL,
  $columnType INTEGER NOT NULL,
  $columnStatus INTEGER,
  $columnSendTime INTEGER NOT NULL,
  $columnDuration INTEGER)
''';

class ChatMessageProvider {
  Database _database;

  ChatMessageProvider._();

  static ChatMessageProvider _instance;

  static ChatMessageProvider getInstance() {
    if (_instance == null) {
      _instance = ChatMessageProvider._();
    }
    return _instance;
  }

  factory ChatMessageProvider() {
    return ChatMessageProvider.getInstance();
  }

  Future<ChatMessageProvider> open() async {
    String defaultPath = await getDatabasesPath() + "/chat_messages.db";
    _database = await openDatabase(defaultPath, version: 7,
        onCreate: (Database db, int version) async {
      await db.execute(sql);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute("DROP TABLE IF EXISTS $tableName");
      await db.execute(sql);
    });
    return _instance;
  }

  Future<int> add(ChatMessage message) async {
    print('----------$message');
    await _checkDataBaseAvailable();
    return _database.insert(tableName, message.toMap());
  }

  Future<List<ChatMessage>> getAll(String group, String userId) async {
    await _checkDataBaseAvailable();
    return _database
        .query(
      tableName,
      where: "$columnGroup = ? AND ( $columnToId = ? OR $columnFromId = ?)",
      whereArgs: [group, userId, userId],
      orderBy: "$columnSendTime DESC",
    )
        .then((list) {
      return list.map((map) {
        return ChatMessage.fromMap(map);
      }).toList();
    });
  }

  _checkDataBaseAvailable() async {
    if (_database == null) {
      await open();
    }
  }
}
