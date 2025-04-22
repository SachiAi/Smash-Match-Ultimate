import 'package:audioplayers/src/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/widgets/home_page.dart';

class Gallery extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const Gallery({super.key, required this.audioPlayer});
  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 70, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 25),
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
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      iconSize: 30,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(audioPlayer: widget.audioPlayer,)));
                      },
                    ),
                  )
                ],
              ),
            ),
            // Main Column
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 100, 20, 0),
                ),

                // Card Gallery Text
                Expanded(
                  flex: 15,
                  child: Center(
                    child: Image.asset(
                      'assets/card-gallery-text.png',
                        width: 500,
                        height: 500,
                    ),
                  ),
                ),

                // Rectangle Container
                Expanded(
                  flex: 40,
                  child: Center(
                    child: Container(
                    margin: const EdgeInsets.fromLTRB(30,0,30,40),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 4.0),
                      color: Colors.orangeAccent,
                    ),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            // Mario Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/mario-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Luigi Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/luigi-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),

                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Peach Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/peach-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Pacman Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/pacman-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Kirby Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/kirby-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Link Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/link-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Steve Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/steve-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Zelda Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/zelda-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Samus Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/samus-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Joker Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/joker-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Cloud Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/cloud-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Sonic Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/sonic-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Pichu Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/pichu-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Marth Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/marth-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Shulk Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/shulk-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Snake Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/snake-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Simon Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/simon-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                            // Ryu Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 170, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/ryu-info.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                            ),

                          ],
                        ),
                      ],
                    ),

                  ),
                    
                  ),
                )
              ],
            ),
          ],
        );
  }


}
