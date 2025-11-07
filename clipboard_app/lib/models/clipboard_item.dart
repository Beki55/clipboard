class ClipboardItem {
  final String content;
  final DateTime createdAt;

  ClipboardItem({required this.content, required this.createdAt});

  factory ClipboardItem.fromJson(Map<String, dynamic> json) {
    return ClipboardItem(
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
