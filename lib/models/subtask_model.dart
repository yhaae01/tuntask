import 'dart:convert';

class SubTaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTaskModel.fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubTaskModel.fromJson(String source) =>
      SubTaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubTaskModel &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isCompleted.hashCode;

  @override
  String toString() =>
      'SubTaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
}
