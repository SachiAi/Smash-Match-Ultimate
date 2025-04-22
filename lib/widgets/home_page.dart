// ignore_for_file: prefer_const_constructors

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/leaderboard.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:memory_game/widgets/gallery.dart';

const Color orangeRed = Color(0xFFFF5349); // Orange-red color
bool isPaused = false;

final List<String> difficultyList = <String>[
  'Easy (3x4)',
  'Medium (4x5)',
  'Hard (6x6)'
];

final List<String> timerList = <String>[
  '30 seconds',
  '1 minute',
  '2 minutes',
];

class HomePage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const HomePage({super.key, required this.audioPlayer});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Player? currentPlayer;
  late TextEditingController _playerController;
  late TextEditingController _playerPassword;
  bool isLoginMode = true;
  bool isLoginSignUpDone = false;
  String userErrorMsg = "";
  String passwordErrorMsg = "";
  String _difficulty = difficultyList.first;
  String _timer = timerList[1];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    currentPlayer = Database.playerBox?.get("currentPlayer");
    if (currentPlayer != null) {
      isLoginSignUpDone = true;
    }
    _playerController = TextEditingController(text: currentPlayer?.name);
    _playerPassword = TextEditingController(text: "");
    String? diff = Database.optionsBox?.get("difficulty");
    if (diff != null) {
      _difficulty = diff;
    } else {
      Database.optionsBox?.put("difficulty", difficultyList.first);
    }
    String? timer = Database.optionsBox?.get("timer");
    if (timer != null) {
      _timer = timer;
    } else {
      Database.optionsBox?.put("timer", timerList[1]);
    }
  }

  void _updateCurrentPlayer(Player newPlayer) async {
    if (newPlayer.name != "Guest") {
      await Database.playerBox?.put("currentPlayer", newPlayer);
      setState(() => currentPlayer?.name = _playerController.text);
    }
  }

  // DIFFICULTY
  Widget _buildOptionsDialog(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(children: [
        AlertDialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            content: Stack(children: [
              SizedBox(
                  width: 1100,
                  child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/rectangle.png")
                          )
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Name
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Name :",
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2.8,
                                            fontFamily: "AlegreyaSans-Black",
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                          width: 130,
                                          child: TextField(
                                            readOnly: true,
                                            style: TextStyle(
                                                fontSize: SizeConfig.fontSize * 2.5,
                                                fontFamily: "AlegreyaSans-Black",
                                                color:  Colors.black),
                                            controller: _playerController,
                                          )
                                      )
                                    ]
                                ),

                                // Level
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Level :",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2.7,
                                            fontFamily: "AlegreyaSans-Black",
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black),
                                      ),
                                      DropdownButton<String>(
                                          elevation: 0,
                                          dropdownColor: Colors.orange[200],
                                          value: _difficulty,
                                          onChanged: (value) async {
                                            await Database.optionsBox
                                                ?.put("difficulty", value!);
                                            setState(
                                                    () => _difficulty = value!);
                                          },
                                          items: difficultyList.map((value) {
                                            return DropdownMenuItem(
                                                value: value,
                                                child: Text(value,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                            .fontSize *
                                                            2.0,
                                                        fontFamily: "AlegreyaSans",
                                                        color: Colors.black)
                                                )
                                            );
                                          }).toList()
                                      )
                                    ]
                                ),

                                // Time
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Time :",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2.8,
                                            fontFamily: "AlegreyaSans-Black",
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black),
                                      ),
                                      DropdownButton<String>(
                                          elevation: 0,
                                          dropdownColor: Colors.orange[200],
                                          value: _timer,
                                          onChanged: (value) async {
                                            await Database.optionsBox
                                                ?.put("timer", value!);
                                            setState(() => _timer = value!);
                                          },
                                          items: timerList.map((value) {
                                            return DropdownMenuItem(
                                                value: value,
                                                child: Text(value,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                            .fontSize *
                                                            2.4,
                                                        fontFamily: "AlegreyaSans",
                                                        color: Colors.black)
                                                )
                                            );
                                          }).toList()
                                      )
                                    ]
                                ),

                              ],
                            ),
                          ]
                      )
                  )
              ),

              // Play Button
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0, 250, 0, 0),
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.black, size: 40,),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                    minimumSize: MaterialStateProperty.all(const Size(150, 80)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // adjust for desired roundness
                        side: BorderSide(width: 4, color: Colors.black),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _updateCurrentPlayer(Player(name: _playerController.text));
                    Navigator.of(context).pop();
                  },
                ),
              ),

              // Difficulty Text
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      0, 70, 0, SizeConfig.blockSizeVertical * 37),
                  child: SizedBox(
                    width: 300,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/select-diff-text.png"),
                              fit: BoxFit.fitWidth)),
                    ),
                  )
              ),
            ])),
      ]);
    });
  }

  // EXIT
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit?'),
        content: const Text('Going down without a fight?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  // MAIN MENU
  // Page Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          // Background Image
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage("assets/Background.png"), fit: BoxFit.cover)),
          child: Stack(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _homeTitle(),
                      Column(
                        children: [
                          // Card Design
                          SizedBox(
                            width: 300,
                            height: 140,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/cards-home.png"),
                                  )),
                            ),
                          ),

                          // Match Button
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                side: BorderSide(
                                  width: 3.0,
                                  color: Colors.black,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: const Text(
                                "MATCH",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'AlegreyaSans-Black',  // Fixed font family name
                                  fontWeight: FontWeight.w900,  // Optional: ensure it's black weight
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Game(audioPlayer: widget.audioPlayer),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Difficulty Button
                          SizedBox(height: 15),
                          SizedBox(
                            width: 300,
                            height: 50,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    side: BorderSide(
                                        width: 3.0,
                                        color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0)
                                    )
                                ),
                                child: const Text(
                                  "DIFFICULTY",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'AlegreyaSans-Black',
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        _buildOptionsDialog(context),
                                  );
                                }),
                          ),
                        ],
                      ),

                      // Leaderboards Button
                      SizedBox(height: 15),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              side: BorderSide(
                                  width: 3.0,
                                  color: Colors.black),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          child: const Text(
                            "LEADERBOARDS",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'AlegreyaSans',
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Leaderboard(score: 0)));
                          },
                        ),
                      ),

                      // Card Gallery Button
                      SizedBox(height: 15),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              side: BorderSide(
                                  width: 3.0,
                                  color: Colors.black),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          child: const Text(
                            "CARD GALLERY",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'AlegreyaSans',
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Gallery(
                                      audioPlayer: widget.audioPlayer,
                                    )));
                          },
                        ),
                      ),

                      // Quit Button
                      SizedBox(height: 15),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              side: BorderSide(
                                  width: 3.0,
                                  color: Colors.black),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          child: const Text(
                            "QUIT",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'AlegreyaSans',
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            _onWillPop();
                          },
                        ),
                      ),
                    ]),
              ),
            ),

            // Logout Button
            Positioned(
              top: 70,
              right: 30,
              child: _logoutBtn(),
            ),

            IgnorePointer(
              ignoring:
              isLoginSignUpDone, // ignores pointers to the overlay if login/signup is done
              child: SizedBox(
                height:
                MediaQuery.of(context).size.height, // height of the screen
                width: MediaQuery.of(context).size.width, // width of the screen
                child: Opacity(
                  opacity: isLoginSignUpDone
                      ? 0.0
                      : 1.0, // make entire login/signup overlay disappear
                  child: Stack(
                    children: [
                      // black overlay background
                      Container(
                        color: Color.fromARGB(255, 42, 50, 44).withOpacity(0.7),
                      ),

                      // blur effect
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                isLoginMode
                                    ? "assets/login-box.png"
                                    : "assets/signup-box.png",
                                width: 350,
                              ),
                            ),
                            Container(
                              //color: Colors.black,
                              margin: EdgeInsets.fromLTRB(70,
                                  SizeConfig.blockSizeVertical * 33, 70, 50),
                              height: SizeConfig.blockSizeVertical * 40,
                              width: 300,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 2,
                                      fontFamily: "AlegreyaSans",
                                      color: const Color.fromRGBO(
                                          147, 123, 107, 1),
                                    ),
                                    controller: _playerController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z0-9]")),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "Name",
                                      helperText: userErrorMsg,
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                  TextField(
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 1.8,
                                      fontFamily: "AlegreyaSans",
                                      color: const Color.fromRGBO(
                                          147, 123, 107, 1),
                                    ),
                                    controller: _playerPassword,
                                    obscureText: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z0-9]")),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      helperText: passwordErrorMsg,
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Login: Sign-Up button   ;   Sign-Up: Back to Login button
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            userErrorMsg = "";
                                            passwordErrorMsg = "";
                                            _playerController.text = "";
                                            _playerPassword.text = "";
                                            isLoginMode = !isLoginMode;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(

                                          ),
                                        ),
                                        child: Text(
                                            isLoginMode ? "SIGN-UP" : "BACK"),
                                      ),

                                      // Login: Login button   ;   Sign-Up: Sign-up button
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            userErrorMsg = "";
                                            passwordErrorMsg = "";
                                          });
                                          if (_playerController.text.isEmpty) {
                                            setState(() => userErrorMsg =
                                            "Enter a username.");
                                            return;
                                          }
                                          if (_playerPassword.text.isEmpty) {
                                            setState(() => passwordErrorMsg =
                                            "Enter password.");
                                            return;
                                          }
                                          if (isLoginMode) {
                                            Database.firebase
                                                .collection("players")
                                                .doc(_playerController.text)
                                                .get()
                                                .then((user) {
                                              if (!user.exists) {
                                                setState(() {
                                                  userErrorMsg =
                                                  "Username does not exist.";
                                                });
                                                return;
                                              }
                                              if (user.data()?["password"] !=
                                                  _playerPassword.text) {
                                                setState(() {
                                                  passwordErrorMsg =
                                                  "Incorrect password.";
                                                });
                                                return;
                                              }
                                              Database.playerBox
                                                  ?.put(
                                                  "personalBest",
                                                  Player(
                                                      name: user
                                                          .data()?["name"],
                                                      score: user.data()?[
                                                      "score"]))
                                                  .whenComplete(() {
                                                setState(() =>
                                                isLoginSignUpDone = true);
                                                _updateCurrentPlayer(Player(
                                                    name: _playerController
                                                        .text));
                                              });
                                            });
                                          } else {
                                            Database.firebase
                                                .collection("players")
                                                .doc(_playerController.text)
                                                .get()
                                                .then((user) {
                                              if (user.exists) {
                                                setState(() {
                                                  userErrorMsg =
                                                  "This username is already taken.";
                                                });
                                              } else {
                                                Database.firebase
                                                    .collection("players")
                                                    .doc(_playerController.text)
                                                    .set({
                                                  "name":
                                                  _playerController.text,
                                                  "score": 0,
                                                  "password":
                                                  _playerPassword.text
                                                });
                                                setState(() {
                                                  isLoginMode = true;
                                                  _playerController.text = "";
                                                  _playerPassword.text = "";
                                                });
                                              }
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: orangeRed,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: orangeRed, width: 2.0),
                                          ),
                                        ),
                                        child: Text(
                                            isLoginMode ? "LOGIN" : "SIGN-UP",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            )
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 70, left: 30, child: _musicBtn()),
          ])),
    );
  }

  // Logo
  SizedBox _homeTitle() {
    return SizedBox(
      width: 380,
      height: 250,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/logo-title.png"), fit: BoxFit.cover)
        ),
      ),
    );
  }

  // Music Button
  SizedBox _musicBtn() {
    return SizedBox(
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3.0),

            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF3C3C),
                Color(0xFFFF913C),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Center(
            child: IconButton(
              icon: isPaused
                  ? const Icon(Icons.headphones_outlined)
                  : const Icon(Icons.headphones),
              color: Colors.black,
              iconSize: 25,
              onPressed: () {
                if (isPaused) {
                  widget.audioPlayer.resume();
                } else {
                  widget.audioPlayer.pause();
                }
                setState(() {
                  isPaused = !isPaused;
                });
              },
            ),
          ),
        )
    );
  }

  // Logout Button
  SizedBox _logoutBtn() {
    return SizedBox(
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3.0),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF3C3C),
              Color(0xFFFF913C),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            iconSize: 25,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Retreat already, challenger?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await Database.playerBox?.delete("currentPlayer");
                          setState(() {
                            currentPlayer = null;
                            userErrorMsg = "";
                            passwordErrorMsg = "";
                            _playerController.text = "";
                            _playerPassword.text = "";
                            Navigator.of(context).pop();
                            isLoginSignUpDone = false;
                          });
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


