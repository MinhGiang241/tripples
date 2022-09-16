import 'package:flutter/material.dart';

class CancelUploadDiaLog extends StatelessWidget {
  const CancelUploadDiaLog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Cảnh báo"),
      content:
          Text("File đang trong tiến trình tải. Bạn có chắc muốn huỷ không?"),
      actions: [
        TextButton(onPressed: () {}, child: Text("Không")),
        TextButton(onPressed: () {}, child: Text("Đồng ý"))
      ],
    );
  }
}
