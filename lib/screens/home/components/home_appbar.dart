import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:provider/provider.dart';
import 'package:survey/controllers/auth/auth_controller.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    Key? key,
    required this.name,
  }) : super(key: key);
  final String name;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              radius: 25,
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
            SizedBox(
              width: padding,
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headline6,
            ),
            Spacer(),
            IconButton(
                icon: Icon(
                  Icons.logout,
                  size: 30,
                ),
                onPressed: () async {
                  await context.read<AuthController>().logOut();
                })
          ],
        ));
  }
}
