import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:provider/provider.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import '../../auth/login/login_screen.dart';
import '../../profile/user_profile.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar(
      {Key? key,
      required this.name,
      required this.userId,
      required this.avatar})
      : super(key: key);
  final String name;
  final String userId;
  final String avatar;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            Stack(children: [
              PopupMenuButton(
                onSelected: (_) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DetailUser(userId)));
                },
                child: avatar != ''
                    ? CircleAvatar(
                        child: ClipOval(
                          child: Image.network(
                              'http://api.triples.hoasao.demego.vn/headless/stream/upload?load=${avatar}',
                              width: 60,
                              fit: BoxFit.fill),
                        ),
                        radius: 30,
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        radius: 25,
                        child: Icon(
                          Icons.person,
                          size: 40,
                        ),
                      ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Hồ sơ'), value: 0),
                ],
              )
            ]),
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
                  await context.read<AuthController>().logOut(context);
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => LoginScreen()));
                })
          ],
        ));
  }
}
