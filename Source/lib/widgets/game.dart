// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/card_widget.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/leaderboard.dart';
import 'package:memory_game/utils/size_config.dart';

const shadows = [
  Shadow(
    color: Colors.black,  // Changed from Color.fromRGBO(117, 187, 115, 1)
    offset: Offset(1.5, 1.5),
    blurRadius: 2,
  ),

  Shadow(
    color: Colors.black,  // Changed from Color.fromRGBO(117, 187, 115, 1)
    offset: Offset(1.5, 1.5),
    blurRadius: 2,
  ),

  Shadow(
    color: Colors.black,  // Changed from Color.fromRGBO(117, 187, 115, 1)
    offset: Offset(1.5, 1.5),
    blurRadius: 2,
  ),

  Shadow(
    color: Colors.black,  // Changed from Color.fromRGBO(117, 187, 115, 1)
    offset: Offset(1.5, 1.5),
    blurRadius: 2,
  ),

];

class Game extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const Game({super.key, required this.audioPlayer});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late List<CardItem> _cards;
  late List<CardItem> _validPairs;
  late CardItem? _tappedCard;
  late int _counter;
  late Timer _timer;
  late int _rows;
  late int _cols;
  int _score = 0;
  int _flips = 0;
  late int? _bestScore;
  late Player? _currentPlayer;
  late Player? _pb;
  late String? _difficulty;
  late double _multiplier;
  late double _divider;
  bool _enableTaps = true;

  late double deviceWidth;
  late double deviceHeight;
  int countDown = 3;
  bool isCountingDown = true;

  @override
  void initState() {
    startCountDownAndNavigate();
    super.initState();
    _currentPlayer = Database.playerBox?.get("currentPlayer");
    _currentPlayer!.score = 0;
    _pb = Database.playerBox?.get("personalBest");
    _difficulty = Database.optionsBox?.get("difficulty")!;
    int? score = Database.playerBox?.get("personalBest")?.score;
    if (score != null) {
      _bestScore = score;
    } else {
      _bestScore = 0;
    }

    if (_difficulty!.contains("Easy")) {
      _multiplier = 1;
      _rows = 3;
      _cols = 4;
    } else if (_difficulty!.contains("Medium")) {
      _multiplier = 1.25;
      _rows = 4;
      _cols = 5;
    } else {
      _multiplier = 1.5;
      _rows = 6;
      _cols = 6;
    }
    _cards = _getRandomCards(_rows * _cols);
    _tappedCard = null;
    _validPairs = [];

    String? timerOption = Database.optionsBox?.get("timer")!.split(" ")[0];
    int time = int.parse(timerOption!);
    if (time > 3) {
      _startTimer(time + 3);
      _divider = 0.2;
    } else {
      if (time == 1) {
        _divider = 1.5;
      } else {
        _divider = 2.75;
      }
      _startTimer((time * 60) + 3);
    }
  }

  void startCountDownAndNavigate() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      if (countDown > 1) {
        setState(() {
          countDown--;
        });
      } else {
        timer.cancel();
        isCountingDown = false;
      }
    });
  }

  List<CardItem> _shuffleCards(List<CardItem> cards) {
    Random rng = Random();
    for (int i = cards.length - 1; i >= 1; --i) {
      int newIdx = rng.nextInt(i);
      CardItem temp = cards[i];
      cards[i] = cards[newIdx];
      cards[newIdx] = temp;
    }
    return cards;
  }

  List<CardItem> _getRandomCards(int max) {
    return _shuffleCards(CardItem.getCards(_rows * _cols));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _addScore() async {
    if (_pb == null || (_currentPlayer?.score)! > (_pb?.score)!) {
      _pb = _currentPlayer;
      await Database.playerBox?.put("personalBest",
          Player(name: _currentPlayer!.name, score: _currentPlayer!.score));
    }
    var value = await Database.firebase
        .collection("players")
        .doc(_currentPlayer?.name)
        .get();

    if (!value.exists) {
      await Database.firebase
          .collection("players")
          .doc(_currentPlayer?.name)
          .set(_currentPlayer!.toJson());
      return;
    }
    if ((_currentPlayer?.score!)! > value.data()?["score"]) {
      await Database.firebase
          .collection("players")
          .doc(_currentPlayer?.name)
          .update(_currentPlayer!.toJson());
    }
  }

  void _startTimer(int time) {
    _counter = time;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_counter > 0) {
        setState(() {
          --_counter;
        });
      } else {
        timer.cancel();
        _currentPlayer?.score = _score;
        await _addScore();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                _buildGameOverDialog(context, "timer ran out!"));
      }
    });
  }

  void _handleTap(CardItem card) async {
    if (_counter == 0 || card.isTapped) {
      return;
    }
    card.isTapped = true;
    setState(() => _tappedCard ??= card);
    if (_tappedCard == card) {
      return;
    }
    setState(() => ++_flips);

    if (_tappedCard?.val == card.val) {
      setState(() {
        _score += ((_counter / _divider) * _multiplier).truncate();
        _validPairs.add(_tappedCard!);
        _validPairs.add(card);
        _tappedCard = null;
      });
      if (_score > _bestScore!) {
        _bestScore = _score;
      }
    } else {
      setState(() => _enableTaps = false);
      Timer(const Duration(milliseconds: 700), () {
        card.isTapped = false;
        setState(() {
          _tappedCard?.isTapped = false;
          _tappedCard = null;
          _enableTaps = true;
        });
      });
    }
    if (_validPairs.length == _cards.length) {
      _timer.cancel();
      _currentPlayer?.score = _score;
      await _addScore();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              _buildGameOverDialog(context, "you win!"));
    }
  }

  String _secondsToMinutes(int s) {
    int minutes = (s / 60).truncate();
    int seconds = (s % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AlertDialog _buildPauseDialog(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width - 20;
    return AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        content: Stack(
          clipBehavior: Clip.none,
          children: [

            // Paused Button
            Container(
              height: deviceWidth,
              width: deviceWidth,
              // Paused Background
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/game-paused-bg.png"),
                      fit: BoxFit.contain)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),

                  // Rematch Button
                  SizedBox(
                    width: 230,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 3.0,
                              color: Colors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                        backgroundColor: Colors.orangeAccent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Game(
                                      audioPlayer: widget.audioPlayer,
                                    )));
                      },
                      child: const Text(
                        "REMATCH",
                        style: TextStyle(
                          fontSize: 27,
                          fontFamily: 'AlegreyaSans-Black',
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Main Menu Button
                  SizedBox(height: 30),
                  SizedBox(
                    width: 230,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 3.0,
                              color: Colors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          backgroundColor: Colors.orangeAccent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(
                                  audioPlayer: widget.audioPlayer,
                                )));
                      },
                      child: const Text(
                        "MAIN MENU",
                        style: TextStyle(
                          fontSize: 27,
                          fontFamily: 'AlegreyaSans-Black',
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: 20,
              right: -10,
              child: SizedBox(
                height: 80,
                width: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orangeAccent,
                      side: BorderSide(
                      color: Colors.black,  // Border color
                      width: 7,             // Border width
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    _startTimer(_counter);
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.center, // Center the icon
                    child: const Icon(
                      Icons.arrow_back,  // Back arrow icon
                      color: Colors.black,
                      size: 35,  // Adjust size as needed
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildGameOverDialog(BuildContext context, String msg) {
    return Stack(children: [
      AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        content: SizedBox(
            width: SizeConfig.safeBlockHorizontal * 80,
            height: SizeConfig.safeBlockVertical * 60,
            child: Container(
                width: deviceWidth,
                height: deviceHeight,

                // Win Background
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/win-time-bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Game Score
                      Padding(
                        padding: EdgeInsets.only(
                          top: SizeConfig.safeBlockVertical * 7, // adjust as needed
                        ),
                        child: Text(
                          "$_score",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'AlegreyaSans-Black',
                            fontWeight: FontWeight.w900,
                            fontSize: 5.5 * SizeConfig.fontSize,
                          ),
                        ),
                      ),

                      // Score Text
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 1.5, // tweak as needed
                        ),
                        child: Text(
                          "- Score -",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'AlegreyaSans-Black',
                            fontWeight: FontWeight.w900,
                            fontSize: 3.5 * SizeConfig.fontSize,
                          ),
                        ),
                      ),

                      // Rematch Button
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 1.5, // adjust value as needed
                        ),
                        child: SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 60,
                          height: SizeConfig.safeBlockVertical * 6,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Game(audioPlayer: widget.audioPlayer),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  side: const BorderSide(width: 3.5, color: Colors.black),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            child: FittedBox(
                              child: Text(
                                "REMATCH!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'AlegreyaSans-Black',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 27,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Leaderboards Button
                      SizedBox(height: SizeConfig.blockSizeVertical),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 1, // adjust the space as needed
                        ),
                        child: SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 60,
                          height: SizeConfig.safeBlockVertical * 6,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Leaderboard(score: _score),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  side: const BorderSide(width: 3.5, color: Colors.black),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                            child: FittedBox(
                              child: Text(
                                "LEADERBOARDS",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'AlegreyaSans-Black',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 27,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ])
            )
        ),
      ),

      // Home Button
      Positioned(
        top: 170,
        right: 20,
        child: SizedBox(
          height: 80,
          width: 80,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: Colors.orangeAccent,
              side: BorderSide(
                color: Colors.black,  // Border color
                width: 7,             // Border width
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                        audioPlayer: widget.audioPlayer,
                      )));
            },
            child: Align(
              alignment: Alignment.center, // Center the icon
              child: const Icon(
                Icons.home,  // Back arrow icon
                color: Colors.black,
                size: 35,  // Adjust size as needed
              ),
            ),
          ),
        ),
      ),

      // Win or Time Text
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(
                    SizeConfig.safeBlockHorizontal * 25,
                    msg == "timer ran out!"
                        ? 22 * SizeConfig.safeBlockVertical
                        : 24 * SizeConfig.safeBlockVertical,
                    SizeConfig.safeBlockHorizontal * 25,
                    0),
                child: SizedBox(
                  // Adjust width and height as needed
                  width: 350, // You can adjust this to change the width of the image
                  height: 170, // You can adjust this to change the height of the image
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: msg == "timer ran out!"
                              ? AssetImage("assets/time-text.png")
                              : AssetImage("assets/win-text.png"),
                          fit: BoxFit.fitWidth), // You can change this to fit your needs, e.g., BoxFit.contain
                    ),
                  ),
                )),
          ),
        ],
      )

    ]);
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/GameBG.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),

        // Pause Button Container
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            width: 110,
            height: 110,
            child: IconButton(
              onPressed: () {
                _timer.cancel();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      _buildPauseDialog(context),
                );
              },
              icon: Image.asset("assets/pause-btn.png"),
              padding: const EdgeInsets.all(5),
            ),
          ),
        ),

        // Score Container
        Container(
          margin: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal * 60, 138, 0, 0),
          child: SizedBox(
            width: 170,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/score-bg.png"),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 23),
                  child: FittedBox(
                    child: Text(
                      _score.toString(),
                      style: const TextStyle(
                        fontFamily: "AlegreyaSans-Black",
                        fontWeight: FontWeight.w900,
                        fontSize: 27,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Timer Container
        Container(
          margin: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal * 0, 140, 20, 0),
          child: SizedBox(
            width: 170,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/time-box.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 23), // optional tweak
                  child: FittedBox(
                    child: Text(
                      _secondsToMinutes(_counter),
                      style: const TextStyle(
                        fontFamily: "AlegreyaSans-Black",
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 27,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Flip Container
        Container(
          margin: (_rows == 4) || (_rows == 3)
              ? EdgeInsets.fromLTRB(135, 140, 0, 0)
              : EdgeInsets.fromLTRB(135, 140, 0, 0),
          child: SizedBox(
            width: 150,
            height: 100, // Match the height of your time container (optional)
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/flip-box.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 23), // Optional tweak for vertical alignment
                  child: FittedBox(
                    child: Text(
                      "$_flips",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "AlegreyaSans-Black",
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 27,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),


        // Difficulty Level
        Container(
          margin: const EdgeInsets.fromLTRB(30, 75, 0, 0),
          padding: const EdgeInsets.all(5),
          width: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF3C3C), Color(0xFFFF913C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Level: ${_difficulty!.split(" ")[0]}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "AlegreyaSans-Black",
              fontSize: SizeConfig.fontSize * 3.5,
              fontWeight: FontWeight.w900,
              color: Colors.black, // Set to white for contrast over gradient
            ),
          ),
        ),

        // Card grid and flip counter
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: (_rows == 4) || (_rows == 3)
                ? EdgeInsets.fromLTRB(40, 200, 40, 0)
                : EdgeInsets.fromLTRB(20, 220, 20, 0),
            child: GridView.count(
              shrinkWrap: true,
              childAspectRatio: _rows == 6 ? 0.78 : 0.87,
              crossAxisCount: _rows,
              mainAxisSpacing: _rows == 6 ? 5.0 : 4.0,
              crossAxisSpacing: _rows == 6 ? 8.0 : 8.0,
              children: _cards
                  .map((card) => CardWidget(
                card: card,
                onTap: _enableTaps ? _handleTap : null,
              ))
                  .toList(),
            ),
          ),

          // Tutorial Image
          Container(
            child: Image.asset(
              'assets/tutorial.png',
              width: 800, // Adjust width as needed
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ]),

        // Countdown
        IgnorePointer(
          ignoring: !isCountingDown,
          child: Container(
            color: isCountingDown ? Colors.white : Colors.transparent,
            child: Center(
              child: Text(
                countDown.toString(),
                style: TextStyle(
                  fontFamily: "AlegreyaSans-Black",
                  fontSize: 150,
                  fontWeight: FontWeight.w900,
                  color: isCountingDown ? Colors.black : Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
