import 'package:flutter/material.dart';

import '../pages/my_beers.dart';
import '../pages/beer_map.dart';
import '../pages/add_beer.dart';
import '../pages/get_location_page.dart';

class LandingPageButtons extends StatelessWidget {

  final int _index;

  LandingPageButtons(this._index);

  @override
  Widget build(BuildContext context) {
    return new Expanded( //Adding the Expanded widget to get the child to expand to its parent
        child: new Material( //True button
          color: getColour(_index),
          child: new InkWell(
              onTap: getNextPage(_index, context),
              child: new Center(
                  child: new Container(
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.white, width: 5.0)
                    ),
                    padding: new EdgeInsets.all (20.0),
                    child: getText(_index),
                  ),//When we have a widget which is the child of a column, it will try taking up as little space as possible
              )
          )
        ),
    );
  }

  MaterialAccentColor getColour(int index){
    if (index == 1)
      return Colors.greenAccent;
    else if (index == 2)
      return Colors.blueAccent;
    else
      return Colors.redAccent;
  }

  Text getText(int index) {
    if (index == 1)
      return new Text("My Beers", style: new TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
    else if (index == 2)
      return new Text("Beer Map", style: new TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
    else
      return new Text("Add Beer", style: new TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
  }

  GestureTapCallback getNextPage(int index, BuildContext context) {
    if (index == 1)
      return () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MyBeer()));
    else if (index == 2)
      return () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new GetLocationPage()));
    else
      return () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new AddBeer()));
  }

}