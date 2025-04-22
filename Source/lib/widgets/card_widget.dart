import "package:memory_game/models/card_item.dart";
import 'package:flutter/material.dart';

const Color orangeRed = Color(0xFFFF5349); // Orange-red color

class CardWidget extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onTap;
  const CardWidget({required this.card, this.onTap, super.key});
  @override
  State<CardWidget> createState () => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(widget.onTap != null){
          widget.onTap!(widget.card);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.center,
        padding: EdgeInsets.all((widget.card.isTapped) ? 200 : 200),
        decoration: BoxDecoration(
            // Changed this part to use gradient for the back of the card
            color: widget.card.isTapped ? orangeRed : null, // Only use orangeRed when tapped
            gradient: widget.card.isTapped
                ? null
                : const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFF8A65),],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),

            // Card Back Logo
            image: DecorationImage(
                image: AssetImage(
                    widget.card.isTapped
                        ? widget.card.val
                        : "assets/logo-card.png" // Keep your logo on the back
                ),
                fit: BoxFit.fill
            ),
            border: Border.all(
              color: Colors.black, // Choose border color
              width: 2.5, // Thickness
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(0, 3),
              )
            ]
        ),
      ),
    );
  }
}