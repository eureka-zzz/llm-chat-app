import 'user.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String messageType;
  final String content;
  final DateTime timestamp;
  final User? sender;
  final User? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messageType,
    required this.content,
    required this.timestamp,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      messageType: json['message_type'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_type': messageType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
