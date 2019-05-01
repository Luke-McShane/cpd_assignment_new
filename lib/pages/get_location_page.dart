import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:cpd_assignment/utils/beer.dart';
import 'package:cpd_assignment/pages/landing_page.dart';
import 'package:cpd_assignment/pages/add_beer.dart';

class GetLocationPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FireMap(),
      )
    );
  }
}

class FireMap extends StatefulWidget {
  State createState() => FireMapState();
}

class FireMapState extends State<FireMap> {
  GoogleMapController mapController;
  Location location = new Location();

  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  BehaviorSubject<double> radius = BehaviorSubject(seedValue: 100.0);
  Stream<dynamic> query;

  StreamSubscription subscription;

  build(context) {
    return Stack(children: <Widget>[
      GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(53.226840, -0.548214),
            zoom: 15
        ),
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        mapType: MapType.hybrid  ,
        compassEnabled: true,
        trackCameraPosition: true,
      ),
      Positioned(
        top: 25.0,
        left:10.0,
        child:
        FlatButton(
          child: Icon(Icons.arrow_back, color: Colors.black54),
          color: Colors.white70,
          onPressed: backButtonPressed,//_addGeoPoint,
        )
      ),
      Positioned(
        bottom: 50,
        right: 10,
        child:
          FlatButton(
            child: Icon(Icons.pin_drop, color: Colors.white),
            color: Colors.redAccent,
            onPressed: _addBeer,//_addGeoPoint,
          )
      ),
      Positioned(
        bottom: 50,
        left: 10,
        child: Slider(
          min: 100.0,
          max: 500.0,
          divisions: 4,
          value: radius.value,
          label: 'Radius: ${radius.value}km',
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.redAccent.withOpacity(0.2),
          onChanged: _updateQuery,
        )
      )

    ],);
  }

  _onMapCreated(GoogleMapController controller) {
    _startQuery();
    setState(() {
      mapController = controller;
    });
  }

  _addBeer(){
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new AddBeer()));
  }

  _addMarker() {
    //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new AddBeer()));
    /*TextEditingController _beerNameAndCompany = new TextEditingController();
    TextEditingController _locationAndDate = new TextEditingController();

    //new SingleChildScrollView(
     // child:

    Dialog dialog =          new Dialog(
                child: new Column(
                  children: <Widget>[
                    new TextField(
                      decoration: new InputDecoration(hintText: "Beer name and who you're  drinking with!"),
                      controller: _beerNameAndCompany,
                    ),
                    new TextField(
                      decoration: new InputDecoration(hintText: "Where you're drinking and today's date!"),
                      controller: _locationAndDate,
                    ),
                    new FlatButton(
                      child: new Text("Save"),
                      onPressed: (){
                        setState((){
                          Navigator.pop(context, false);
                          //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new GetLocationPage()));
                        });
                        //Navigator.pop(context);
                      },
                    )
                  ],
                ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);*/
    var marker = MarkerOptions(
      //position: _animateToUser(),//mapController.cameraPosition.target,
      position: mapController.cameraPosition.target,
      icon: BitmapDescriptor.defaultMarker,
      //infoWindowText: InfoWindowText('${_beerNameAndCompany.text}', '${_locationAndDate.text}'),
    );
    
    mapController.addMarker(marker);
    //_addGeoPoint();
  }

  _animateToUser() async {
    var pos = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(pos['latitude'], pos['longitude']),
          zoom: 17.0,
        )
      )
    );
  }

  Future<DocumentReference> addGeoPoint(Beer beer) async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos['latitude'], longitude: pos['longitude']);
    return firestore.collection('locations').add({
      'name': beer.name,
      'date_drank': beer.dateDrank,
      'drank_with': beer.drankWith,
      'location': beer.location,
      /*'id': beer.id,*/
      'position': point.data,
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    //_addMarker();
   // print(documentList);
    mapController.clearMarkers();
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data['position']['geopoint'];
      //double distance = document.data['distance'];
      String name = document.data['name'];
      String drankWith = document.data['drank_with'];
      String date = document.data['date_drank'];
      String location = document.data['location'];
      var marker = MarkerOptions(
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindowText: drankWith == null ? InfoWindowText(name, 'At $location on $date')
                                        : InfoWindowText('$name  with  $drankWith', 'At $location  on $date')
      );

      mapController.addMarker(marker);
    });
  }

  _startQuery() async {
    var pos = await location.getLocation();
    double lat = pos['latitude'];
    double long = pos['longitude'];

    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: long);

    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
        center: center,
        radius: rad,
        field: 'position',
        strictMode: true
      );
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    final zoomMap = {
      100.0: 12.0,
      200.0: 10.0,
      300.0: 7.0,
      400.0: 6.0,
      500.0: 5.0
    };
    final zoom = zoomMap[value];
    mapController.moveCamera(CameraUpdate.zoomTo(zoom));

    setState(() {
      radius.add(value);
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  void backButtonPressed() {
    dispose();
    Navigator.pop(context, false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandingPage())
    );
    //Navigator.of(context).pop(c);//new MaterialPageRoute(builder: (BuildContext context) => new GetLocationPage()));
  }
}