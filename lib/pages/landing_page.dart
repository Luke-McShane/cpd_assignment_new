import 'package:flutter/material.dart';

import '../UI/landing_page_buttons.dart';
import './my_beers.dart';
import './beer_map.dart';
import './add_beer.dart';

class LandingPage extends StatelessWidget {

  int _answer;

  void handleAnswer(int _answer) {
    if (_answer == 1)
      print("Going to 'My Beers'");
    else if (_answer == 2)
      print("Going to 'Beer Map'");
    else
      print("Going to 'Add Beer'");
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new LandingPageButtons(1),
              new LandingPageButtons(2),
              new LandingPageButtons(3),
            ],
          )
      ]
    );
  }


}