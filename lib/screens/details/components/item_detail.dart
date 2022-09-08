import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({Key? key, required this.title, required this.description})
      : super(key: key);
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0),
      child: Column(
        children: [
          Wrap(
            children: [
              Text(
                "$title : ",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
              ),

              Html(
                data: description,
              ),
              // Padding(
              //   padding: EdgeInsets.only(left: padding / 2),
              //   child: Text(
              //     description,
              //     style:
              //         Theme.of(context).textTheme.bodyText1?.copyWith(height: 1.5),
              //   ),
              // ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
