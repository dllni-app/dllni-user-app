class FetchNotificationsModelDataItem {
  const FetchNotificationsModelDataItem({
    this.title,
    this.body,
    this.createdAt,
    required this.type,
    this.isRead,
    this.category,
    this.showTrailingAccent = false,
  });

  final String? title;
  final String? body;
  final String? createdAt;
  final String type;
  final bool? isRead;
  final String? category;
  final bool showTrailingAccent;

  FetchNotificationsModelDataItem copyWith({
    String? title,
    String? body,
    String? createdAt,
    String? type,
    bool? isRead,
    String? category,
    bool? showTrailingAccent,
  }) {
    return FetchNotificationsModelDataItem(
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
      showTrailingAccent: showTrailingAccent ?? this.showTrailingAccent,
    );
  }
}
