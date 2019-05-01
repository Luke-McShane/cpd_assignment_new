import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter_rating/flutter_rating.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cpd_assignment/utils/database_helper.dart';
import 'package:cpd_assignment/utils/beer.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:cpd_assignment/pages/beer_detail.dart';
import 'package:flutter_share_me/flutter_share_me.dart';




class MyBeer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MyBeerState();
  }
}

class MyBeerState extends State<MyBeer> {

  //final _beerNames = <String>["Carling", "Fosters", "Hobgoblin", "Bateman's XXXB", "Dog H"];
  //List myData;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Beer> beerList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if (beerList == null) {
      beerList = List<Beer>();
      updateListView();
    }

    //print(_beerNames[1]);
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('My Beers', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 25.0),),
      ),
      body: _buildBeers(),
    );
  }

  Widget  _buildBeers() {

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int position) {
        if (beerList == null)
          updateListView();
        return new Card(
          child:
            new Slidable(
              key: ObjectKey(beerList[position]),
              delegate: new SlidableDrawerDelegate(),
              actionExtentRatio: 0.25,
              child: _buildRow(beerList[position]),
              actions: <Widget>[
                new IconSlideAction(
                  icon: Icons.delete,
                  color: Colors.redAccent,
                  onTap: () {
                    setState(() {
                    _delete(context, beerList[position]);
                      beerList.removeAt(position);
                  });
                  }//,
                ),
              ],
              secondaryActions: <Widget>[
                new IconSlideAction(
                  caption: 'Share',
                  color: Colors.indigoAccent,
                  icon: Icons.share,
                  onTap: () => FlutterShareMe().shareToSystem(msg: "I drank ${beerList[position].name} at ${beerList[position].location} and I rated it ${beerList[position].rating} out of 5.0!"),
                ),
              ],
            ),
        );
      },
      itemCount: beerList == null ? 0 : count,
    );
  //}
      //},
    //);
  }

  Widget _buildRow(Beer beer) {
    return new GestureDetector(
      onTap: () {drillDown(beer);},
      child:
        new Container(
        //child:
          //new Card(
            color: Colors.greenAccent,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 8.0,
                right: 4.0,
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  beer.pathImage1 != "" ? Container(
                    height: 80.0,
                    width: 80.0,
                    decoration: new BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: new DecorationImage(
                        image: new ExactAssetImage(beer.pathImage1),
                        fit: BoxFit.cover,
                      ),
                      border:
                      Border.all(color: Colors.red, width: 5.0),
                      borderRadius:
                      new BorderRadius.all(const Radius.circular(80.0)),
                    ),
                  ) : Container(width: 0.0, height: 0.0,),
                  SizedBox(width: 5.0,),
                  Expanded(
                    child: Column(

                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        beer.name != null ? Text(beer.name, style: new TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),)
                                          : Container(width: 0, height: 0),
                        beer.location != null ? Text('Drank in ${beer.location}', style: new TextStyle(fontSize: 15.0, color: Colors.white70))
                                          : Container(width: 0, height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("Rating: ", style: new TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold,)),
                            StarRating(
                              size: 25.0,
                              color: Colors.redAccent,
                              rating: double.parse(beer.rating),
                              borderColor: Colors.grey,
                              starCount: 5,
                            ),
                          ]
                        ),
                        beer.drankWith != null ? Text(beer.drankWith, style: new TextStyle(fontSize: 15.0, color: Colors.white70))
                                               : Container(width: 0, height: 0),
                        beer.notes != null ? Text(beer.notes, style: new TextStyle(fontSize: 15.0, color: Colors.white70))
                                           : Container(width: 0, height: 0),
                        beer.dateDrank != null ? Text(beer.dateDrank, style: new TextStyle(fontSize: 15.0, color: Colors.white70))
                                               : Container(width: 0, height: 0),

                      ]
                  ),
                ),
              ],
            )
          )

        ),

      //),
    );
  }

  void _delete(BuildContext context, Beer beer) async {

    int result = await databaseHelper.deleteBeer(beer.id);
    //Navigator.of(context).popAndPushNamed(context, ["/my_beers.dart"]);
    if (result != 0) {
      _showSnackBar(context, 'Successfully Deleted Beer');

      setState(() {updateListView();});
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {

    Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Beer>> beerListFuture = databaseHelper.getBeerList();
      beerListFuture.then((beerList) {
        setState(() {
          this.beerList = beerList;
          this.count = beerList.length;
        });
      });
    });
    //setState(() {
    //});
  }

  void drillDown(Beer beer) async {

    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BeerDetail(beer);
    }));
  }
}
