import 'dart:io';
import 'package:flutter/material.dart';

class Beer {
  int _id;
  String _name, _locationDrank, _drankWith, _otherNotes;
  String _rating;
  String _dateDrank;
  String _pathImage1, _pathImage2, _pathImage3;

  Beer(this._name, this._locationDrank, this._rating, this._drankWith, this._dateDrank, [this._otherNotes, this._pathImage1, this._pathImage2, this._pathImage3]);

  Beer.withId(this._id, this._name, this._locationDrank, this._rating, this._drankWith, this._dateDrank, [this._otherNotes, this._pathImage1, this._pathImage2, this._pathImage3]);

  int get id => _id;
  String get name => _name;
  String get location => _locationDrank;
  String get drankWith => _drankWith;
  String get notes => _otherNotes;
  String get dateDrank => _dateDrank;

  String get rating => _rating;
  String get pathImage1 => _pathImage1;
  String get pathImage2 => _pathImage2;
  String get pathImage3 => _pathImage3;

  set name(String newName) {this._name = newName;}
  set location(String newLocation) {this._locationDrank = newLocation;}
  set drankWith(String newDrankWith) {this._drankWith = newDrankWith;}
  set notes(String newNotes) {this._otherNotes = newNotes;}
  set dateDrank(String newDate) {this._dateDrank = newDate;}
  set rating(String newRating) {this._rating = newRating;}
  set pathImage1(String newPath) {this._pathImage1 = newPath;}
  set pathImage2(String newPath) {this._pathImage2 = newPath;}
  set pathImage3(String newPath) {this._pathImage3 = newPath;}


  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if (id != null)
      map['id'] = _id;

    map['name'] = name;
    map['location'] = location;
    map['rating'] = rating;
    map['drank_with'] = drankWith;
    map['notes'] = notes;
    map['date_drank'] = dateDrank;
    map['path_image_1'] = pathImage1;
    map['path_image_2'] = pathImage2;
    map['path_image_3'] = pathImage3;

    return map;
  }

  Beer.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._locationDrank = map['location'];
    this._rating = map['rating'];
    this._drankWith = map['drank_with'];
    this._otherNotes = map['notes'];
    this._dateDrank = map['date_drank'];
    this._pathImage1 = map['path_image_1'];
    this._pathImage2 = map['path_image_2'];
    this._pathImage3 = map['path_image_3'];
  }
}