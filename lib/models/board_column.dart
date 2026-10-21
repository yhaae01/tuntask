import 'dart:convert';
import 'package:flutter/material.dart';

class BoardColumn {
  final String id;
  final String title;
  final String colorHex;
  final int order;

  const BoardColumn({
    required this.id,
    required this.title,
    required this.colorHex,
    required this.order,
  });

  Color get color {
    final hexString = colorHex.replaceAll('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    } else if (hexString.length == 8) {
      return Color(int.parse(hexString, radix: 16));
    }
    return const Color(0xFF0052CC); // Jira default blue
  }

  BoardColumn copyWith({
    String? id,
    String? title,
    String? colorHex,
    int? order,
  }) {
    return BoardColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      colorHex: colorHex ?? this.colorHex,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'colorHex': colorHex,
      'order': order,
    };
  }

  factory BoardColumn.fromMap(Map<String, dynamic> map) {
    return BoardColumn(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      colorHex: map['colorHex']?.toString() ?? '#0052CC',
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BoardColumn.fromJson(String source) =>
      BoardColumn.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardColumn &&
        other.id == id &&
        other.title == title &&
        other.colorHex == colorHex &&
        other.order == order;
  }

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ colorHex.hashCode ^ order.hashCode;

  @override
  String toString() =>
      'BoardColumn(id: $id, title: $title, colorHex: $colorHex, order: $order)';
}
