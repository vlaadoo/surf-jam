import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // TODO(task): Implement Auth screen.

  final loginController = TextEditingController();
  final passController = TextEditingController();

  String _login = "";
  String _password = "";

  void _auth(_log, _pass) async {
    try {
      final token =
          await widget.authRepository.signIn(login: _log, password: _pass);
      _pushToChat(context, token);
      print(token);
    } on AuthException catch (ex) {
      print(ex);
    }
  }

  late double lineWidth;

  @override
  void initState() {
    lineWidth = 0;

    super.initState();
  }

  void _changeWidth() async {
    var steps = 120;

    const duration = Duration(seconds: 1);

    /// Длительность каждого передвижения.
    final stepDuration =
        Duration(milliseconds: duration.inMilliseconds ~/ steps);

    var widthStep = (lineWidth + 1 * steps / 4);

    var currentWidth = lineWidth;
    while (steps > 0) {
      setState(() {
        if (lineWidth > 300) {
          lineWidth = 0;
          widthStep = 0;
          currentWidth = 0;
          lineWidth += currentWidth;
        }
        currentWidth += widthStep;
        lineWidth = currentWidth;
      });
      steps--;
      await Future.delayed(stepDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
          padding: EdgeInsets.all(25.0),
          child: Center(
            child: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new TextFormField(
                  controller: loginController,
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      labelText: "Логин"),
                  validator: (value) {
                    if (value == null) {
                      return 'Введите логин';
                    } else {
                      _login = loginController.text;
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: TextFormField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder(),
                        labelText: "Пароль"),
                    validator: (value) {
                      print(value);
                      if (value == null) {
                        return 'Введите пароль';
                      } else {
                        _password = passController.text;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(900, 40))),
                    onPressed: () => {
                      _auth(loginController.text, passController.text),
                      _changeWidth()
                    },
                    child: Text("Далее"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Container(
                    height: 10,
                    width: lineWidth,
                    color: Colors.green,
                  ),
                )
              ],
            )),
          )),
    );
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}
