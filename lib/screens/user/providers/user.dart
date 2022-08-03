import 'package:flutter/widgets.dart';

class Role {
  String id = '';
  String schema = '';
  String schema_label = '';
  String code = '';

  Role(
      {required this.id,
      required this.schema,
      required this.schema_label,
      required this.code});
}

class User with ChangeNotifier {
  String id = '';
  String username = 'chưa có tên tài khoản';
  String fullName = "Không có tên";
  String email = 'Không có email';
  String phone = ' không có sđt';
  String title = 'không có tiêu đề';
  bool isActive;
  bool isRoot;
  List<Role> role = [];
  User({
    required this.id,
    required this.username,
    required this.fullName,
    // required this.email,
    required this.phone,
    // required this.title,
    required this.isActive,
    required this.isRoot,
    // required this.role
  });
}
