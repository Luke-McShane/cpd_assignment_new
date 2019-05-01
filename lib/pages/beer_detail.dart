import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cpd_assignment/utils/beer.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:image_picker/image_picker.dart';

class BeerDetail extends StatefulWidget {

  final Beer beer;

  BeerDetail(this.beer);

  @override
  State<StatefulWidget> createState() {
    return BeerDetailState(this.beer);
  }
}

class BeerDetailState extends State<BeerDetail> {
  Beer beer;
  BeerDetailState(this.beer);

  @override
  Widget build(BuildContext context) {
    //TextStyle textStyle = Theme.of(context).textTheme.title;

    return WillPopScope(
        onWillPop: () { closeDetail(); },
        child:
          Scaffold(
            backgroundColor: Colors.black12,
            appBar:AppBar(
              title: Text('Beer Drilldown', style: new TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontFamily: "Roboto")),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () { closeDetail(); })
            ),
            body:
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child:
                new Container(
                  child:
                  new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            beer.pathImage1 != '' ? _container(beer.pathImage1) : Container(width: 0, height: 0),
                            beer.pathImage2 != '' ? _container(beer.pathImage2) : Container(width: 0, height: 0),
                            beer.pathImage3 != '' ? _container(beer.pathImage3) : Container(width: 0, height: 0),
                          ],
                        ),

                        _text("Beer Name:", 25.0),
                        beer.name != null ? _text(beer.name, 20.0)
                                          : _text("N/A", 20.0),

                        SizedBox(height: 15),

                        _text("Rating:", 20.0),
                        new StarRating(
                          size: 25.0,
                          rating: double.parse(beer.rating),
                          color: Colors.greenAccent,
                          borderColor: Colors.grey,
                          starCount: 5,
                        ),
                        SizedBox(height: 15),

                        _text("Location Drank:", 25.0),
                        beer.location != null ? _text(beer.location, 20.0)
                            : _text("N/A", 20.0),
                        SizedBox(height: 15),

                        _text("Drank With:", 25.0),
                        beer.drankWith != null ? _text(beer.drankWith, 20.0)
                            : _text("N/A", 20.0),
                        SizedBox(height: 15),

                        _text("Other Notes:", 25.0),
                        beer.notes != null ? _text(beer.notes, 20.0)
                            : _text("N/A", 20.0),
                        SizedBox(height: 15),

                        _text("Date Drank:", 25.0),
                        beer.dateDrank != null ? _text(beer.dateDrank, 20.0)
                            : _text("N/A", 20.0),
                        SizedBox(height: 20),
                      ]

                  ),

                  padding: const EdgeInsets.all(0.0),
                  alignment: Alignment.center,
                ),
              )
          ),
    );
  }

  void closeDetail() {
    Navigator.pop(context, true);
  }

  Text _text(String text, double size) {
    return new Text(text, style: new TextStyle(fontSize: size, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Courier"), textAlign: TextAlign.center,);
  }

  Container _container(String path){
    return new Container(
      margin: const EdgeInsets.only(left: 5.0, right: 5.0),
      height: 80.0,
      width: 80.0,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        image: new DecorationImage(
          image: new ExactAssetImage(path),
          fit: BoxFit.cover,
        ),
        border:
        Border.all(color: Colors.red, width: 5.0),
        borderRadius:
        new BorderRadius.all(const Radius.circular(80.0)),
      ),
    );
  }
}