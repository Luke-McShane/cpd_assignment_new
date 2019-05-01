import 'dart:io';
import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:cpd_assignment/camera/image_picker_handler.dart';
import 'package:cpd_assignment/utils/beer.dart';
import 'package:cpd_assignment/camera/image_picker_dialog.dart';
//import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cpd_assignment/utils/database_helper.dart';

import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:android_intent/android_intent.dart';
import 'package:cpd_assignment/pages/get_location_page.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';
//import 'package:geolocation/geolocation.dart';
import 'package:cpd_assignment/pages/landing_page.dart';




import '../utils/beer.dart';

class LocationData {
  double latitude; // Latitude, in degrees
  double longitude; // Longitude, in degrees
  double accuracy; // Estimated horizontal accuracy of this location, radial, in meters
  double altitude; // In meters above the WGS 84 reference ellipsoid
  double speed; // In meters/second
  double speedAccuracy; // In meters/second, always 0 on iOS
  double heading; //Heading is the horizontal direction of travel of this device, in degrees
  double time; //timestamp of the LocationData
}

class AddBeer extends StatefulWidget {

  @override
  AddBeerState createState() => new AddBeerState();
//List<CameraDescription> cameras;
}

 class AddBeerState extends State<AddBeer> with TickerProviderStateMixin, ImagePickerListener {

  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";
  bool fileExists = false;
  Map<String, String> fileContent;

  File _image_1, _image_2, _image_3;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  int curImg;
  double _rating = 0.0;
  String _nameText, _locationText, _drankWithText, _notesText;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Beer> beerList;
  int count = 0;

  FireMapState fireMap = FireMapState();

  //var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

  var currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  var tmpLoc = new TextEditingController();


  Location location = new Location();// new Location();
  bool permission = false;
  String error;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this,_controller);
    imagePicker.init();

    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    
    initPlatformState();
    location.onLocationChanged().listen((var currentLocation) {
      print(currentLocation['latitude']);
      print(currentLocation['longitude']);
    });

    //location.onLocationChanged();
    /*locationSubscription =
        location.onLocationChanged().listen((locationData) {
        setState(() {
          currentLocation = locationData;
        });
    });*/
  }

  Future<Map<String, double>> _getLocation() async {
    var tmp = <String, double>{};
    try {
      tmp = await location.getLocation();
    } catch (e) {
      tmp = null;
    }
    return tmp;
  }
  
  void initPlatformState() async {
    Map<String, double> myLocation;
    try{
      myLocation = await location.getLocation();
      permission = await location.hasPermission();
      locationSubscription =
          location.onLocationChanged().listen((locationData) {
            setState(() {
              currentLocation = locationData;
            });
          });
      error = "";
    } on PlatformException catch(e) {
      if(e.code == 'PERMISSION_DENIED')
        error = "Permission Denied";
      else if(e.code == 'PERMISSION_DENIED_NEVER_ASK')
        error = 'Permission Denied - Please Enable Location';
      myLocation = null;
    }
    setState(() {
      currentLocation = myLocation;
    });

  }

   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }

   @override
   userImage(File _image) {
     setState(() {
       switch (curImg) {
         case 1: {
           this._image_1 = _image;
         } break;
         case 2: {
           this._image_2 = _image;
         } break;
         case 3: {
           this._image_3 = _image;
         } break;
         default: { this._image_1 = _image; }
     }
     });
   }

  @override
  Widget build(BuildContext context) {

    if (beerList == null) {
      beerList = List<Beer>();
    }

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      //resizeToAvoidBottomPadding: true,
      //resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: new Text('Add Beer', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 25.0),),
        backgroundColor: Colors.redAccent,
      ),
      body:Center(child:
           SingleChildScrollView(

            //padding: const EdgeInsets.all(8.0),
            child:
              new Container(
                child:
                new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10,),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _gestureDetector(_image_1, 1),
                            _gestureDetector(_image_2, 2),
                            _gestureDetector(_image_3, 3),
                          ],
                      ),
                      SizedBox(height: 10),

                      _text("Beer Name:"),
                      new TextField(textCapitalization: TextCapitalization.sentences, onChanged: (text){_nameText = text;}, maxLength: 48, style: new TextStyle(fontSize:12.0, color: const Color(0xFF000000), fontWeight: FontWeight.w400, fontFamily: "Roboto")),
                      SizedBox(height: 10),

                      _text("Rating:"),
                      new Row(
                        children: <Widget> [
                          new IconButton(
                              icon: Icon(Icons.keyboard_arrow_left, color: Colors.black,),
                              onPressed: (){
                                setState(() {
                                  if(this._rating > 0.0){
                                    this._rating -= 0.5;
                                  }
                                });
                              }),
                          new StarRating(
                            onRatingChanged: (rating) => setState((){
                              this._rating = rating;
                            }),
                            size: 25.0,
                            rating: _rating,
                            color: Colors.greenAccent,
                            borderColor: Colors.grey,
                            starCount: 5,
                            ),
                          new IconButton(
                              icon: Icon(Icons.keyboard_arrow_right, color: Colors.black,),
                              onPressed: (){
                                setState(() {
                                  if(this._rating < 5.0){
                                    this._rating += 0.5;
                                  }
                                });
                              }),
                        ]
                      ),
                      SizedBox(height: 10),


                      _text("Location Drank:"),
                      new Row(
                        children: <Widget>[
                          new Flexible(
                            child:
                              new TextField(textCapitalization: TextCapitalization.sentences, onChanged: (text){_locationText = text;}, maxLength: 48, style: new TextStyle(fontSize:12.0, color: const Color(0xFF000000), fontWeight: FontWeight.w400, fontFamily: "Roboto"),
                                controller: tmpLoc),

                          ),
                          new IconButton(
                              icon: Icon(Icons.location_on),
                              onPressed: () {_getLocation().then((value)
                                {
                                  setState(()
                                    {
                                      Coordinates coords = new Coordinates(currentLocation['latitude'], currentLocation['longitude']);
                                      getGeoLocation(coords);
                                    });
                                });
                              }),
                        ]
                      ),
                      SizedBox(height: 10),

                      _text("Drank With:"),
                      new TextField(textCapitalization: TextCapitalization.sentences, onChanged: (text){_drankWithText = text;}, maxLength: 48, style: new TextStyle(fontSize:12.0, color: const Color(0xFF000000), fontWeight: FontWeight.w400, fontFamily: "Roboto")),
                      SizedBox(height: 10),

                      _text("Other Notes:"),
                      new TextField(textCapitalization: TextCapitalization.sentences, onChanged: (text){_notesText = text;}, maxLength: 128, style: new TextStyle(fontSize:12.0, color: const Color(0xFF000000), fontWeight: FontWeight.w400, fontFamily: "Roboto")),
                      SizedBox(height: 10),

                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new FlatButton(
                              color: Colors.black26,
                              key: null,
                              onPressed: backButtonPressed,
                              child:
                              new Text(
                                "Back",
                                style: new TextStyle(fontSize: 30.0,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: "Courier"),
                              )
                            ),

                            new FlatButton(
                                color: Colors.black26,
                                key: null,
                                onPressed: saveButtonPressed,
                                child:
                                new Text(
                                  "Save",
                                  style: new TextStyle(fontSize: 30.0,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: "Courier"),
                                )
                            ),


                          ]

                      )
                    ]

                ),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.center,
              ),
        )
      )
    );
  }

  void saveButtonPressed() async {
    if(_nameText == null || ((_locationText == null || _locationText == '') && (tmpLoc.text == null || tmpLoc.text == ''))){
      _showAlertDialog("Error Saving", "Please add at least a name and location");
      return;
    }

    String dateDrank = new DateFormat("dd-MM-yyyy").format(new DateTime.now());
    Beer beer = new Beer(_nameText, _locationText, _rating.toString(), _drankWithText, dateDrank, _notesText);

    final Directory tempDir = await getApplicationDocumentsDirectory();

    String tempPath = tempDir.path;

    String now = new DateTime.now().millisecondsSinceEpoch.toString();

    if (_image_1 != null){
      beer.pathImage1 = _image_1.path;
      await _image_1.copy('$tempPath/image_1_$now.png');
    } else {beer.pathImage1 = '';}
    if (_image_2 != null){
      beer.pathImage2 = _image_2.path;
      await _image_2.copy('$tempPath/image_2_$now.png');
    } else beer.pathImage2 = '';
    if (_image_3 != null){
      beer.pathImage3 = _image_3.path;
      await _image_3.copy('$tempPath/image_3_$now.png');
    } else beer.pathImage3 = '';



    _save(beer);
    fireMap.addGeoPoint(beer);
  }

  void backButtonPressed() {
    Navigator.pop(context, false);
  }

  void _save(Beer beer) async {

    int result;
    if (beer.id != null){
      result = await databaseHelper.updateBeer(beer);
    } else {
      result = await databaseHelper.insertBeer(beer);
    }

    if (result != 0 ) {
      _showAlertDialog('Status', 'Beer Saved Successfully');
      //goHome();
    } else {
      _showAlertDialog('Status', 'Problem Saving Beer');
    }

  }

  void goHome() {
    dispose();
    Navigator.pop(context, false);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LandingPage())
    );

    //Navigator.of(context).pop(c);//new MaterialPageRoute(builder: (BuildContext context) => new GetLocationPage()));
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
    //goHome();
  }

  GestureDetector _gestureDetector(File file, int img) {
    return new GestureDetector(
      onTap: () {
        if(img == 1) {
          curImg= img;
        } else if(img == 2) {
          curImg = img;
        } else {
          curImg = img;
        }
        imagePicker.showDialog(context); },
      child: new Center(
        child: file == null ? new Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            new Center(
              child: new CircleAvatar(
                radius: 45.0,
                backgroundColor: Colors.white70,
              ),
            ),
            new Center(
              child: new Image.asset("assets/photo_camera.png"),
            ),
          ],
        ) : new Container(
          height: 110.0,
          width: 110.0,
          decoration: new BoxDecoration(
            color: const Color(0xff7c94b6),
            image: new DecorationImage(
              image: new ExactAssetImage(file.path),
              fit: BoxFit.cover,
            ),
            border:
            Border.all(color: Colors.greenAccent, width: 5.0),
            borderRadius:
            new BorderRadius.all(const Radius.circular(80.0)),
          ),
        ),
      ),
    );
  }

  Text _text(String text) {
    return new Text(text, style: new TextStyle(fontSize:15.0, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Courier"),);
  }

  getGeoLocation(Coordinates coords) async{
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coords);
    var first = addresses[1];
    var second = addresses[7];
    tmpLoc.text = "${first.thoroughfare}, ${second.addressLine}";
    _locationText = tmpLoc.text;
    //tmpLoc.text = "${second.addressLine}";
  }
}