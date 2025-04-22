import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:memory_game/widgets/player_widget.dart';


class Leaderboard extends StatefulWidget {
  final int score;
  const Leaderboard({super.key, required this.score});
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}


class _LeaderboardState extends State<Leaderboard> {
  late List<PlayerWidget> _scores;
  late Player? _currentPlayer;
  late Player? _pb;
  late bool _isLoading;


  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }


  @override
  void initState() {
    _isLoading = true;
    _pb = Database.playerBox?.get("personalBest");
    print(_pb);
    print(_pb?.score);
    _currentPlayer = Database.playerBox?.get("currentPlayer");
    _currentPlayer?.score = widget.score;
    _scores = [];
    if (_pb == null) {
      _pb = _currentPlayer;
      Database.playerBox?.put("personalBest", _currentPlayer!);
    }
    _getLeaderboard();
    super.initState();
  }


  void _getLeaderboard() {
    Database.firebase
        .collection("players")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((event) => {
      for (var doc in event.docs)
        {
          setState(() => _scores.add(PlayerWidget(
              player: Player(
                  name: doc.data()["name"],
                  score: doc.data()["score"]))))
        }
    })
        .whenComplete(() {
      setState(() {
        _scores.add(PlayerWidget(
            player: _currentPlayer!,
            color: const Color.fromRGBO(255, 188, 152, 1)));
        _isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
          body: Container(
            // Background Image
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/Background.png"), fit: BoxFit.cover)
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/logo-title.png",
                      width: 400,
                      height: 300,
                    ),
                  ),
                ),


                // Leaderboards Logo
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 200),
                  child: SizedBox(
                    child: Container(
                      margin:
                      EdgeInsets.only(top: SizeConfig.blockSizeHorizontal * 25),
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/leaderboard.png")
                          )
                      ),
                      child: Stack(
                        children: [
                          (_isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                                SizeConfig.blockSizeHorizontal * 16.25,
                                SizeConfig.blockSizeVertical * 18.75,
                                SizeConfig.blockSizeHorizontal * 17.5,
                                0),
                            itemCount: _scores.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 3),
                            itemBuilder: (context, index) {
                              if (_scores[index].player.score! == 0) {
                                return Container();
                              }
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        index != 10
                                            ? _scores[index].player.name
                                            : "- Your Score -",
                                        style: TextStyle(
                                          fontSize: index != 10 ? 18 : 20,
                                          fontFamily: 'AlegreyaSans-Black',
                                          fontWeight: index != 10
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        _scores[index]
                                            .player
                                            .score
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: index != 10 ? 17 : 19,
                                          fontFamily: 'AlegreyaSans-Black',
                                          fontWeight: index != 10
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),


                                  (index == 9 && widget.score == 0) || index == 10
                                      ? Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent, // Background color of the box
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),


                                    // Account Score
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Best Score :",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: "AlegreyaSans-Black",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          (_pb?.score ?? 0).toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontFamily: "AlegreyaSans-Black",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                ),


                // Back Button
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 2.5),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF3C3C),
                            Color(0xFFFF913C),
                          ],
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        )
    );
  }
}

