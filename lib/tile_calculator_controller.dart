import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TileCalculatorController extends GetxController {
  final TextEditingController latitudeController = TextEditingController()
    ..text = '55.786889';
  final TextEditingController longitudeController = TextEditingController()
    ..text = '37.617747';
  final TextEditingController zoomController = TextEditingController()
    ..text = '16';
  final imageUrl = Rxn<String>();
  final RxString tileCoordinates = ''.obs;
  final RxString errorLatitude = ''.obs;
  final RxString errorLongitude = ''.obs;
  final RxString errorZoom = ''.obs;
  final RxString tileMessage = ''.obs;

  void calculateTile() {
    if (isUserInputCorrect()) {
      double latitude = double.parse(latitudeController.text);
      double longitude = double.parse(longitudeController.text);
      int zoom = int.parse(zoomController.text);

      var tileNumbers = calculateTileNumber(latitude, longitude, zoom);

      imageUrl.value =
          'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x='
          '${tileNumbers[0]}&y=${tileNumbers[1]}&z=$zoom&scale=1&lang=ru_RU';
      tileCoordinates.value = 'X: ${tileNumbers[0]}, Y: ${tileNumbers[1]}';
    }
  }

  bool isUserInputCorrect() {
    try {
      double latitude = double.parse(latitudeController.text);
      if (latitude < -90 || latitude > 90) {
        errorLatitude.value = 'Широта должна быть в диапазоне от -90 до 90';
        return false;
      }
    } catch (e) {
      errorLatitude.value = 'Введите корректное значение широты';
      return false;
    }

    try {
      double longitude = double.parse(longitudeController.text);
      if (longitude < -180 || longitude > 180) {
        errorLongitude.value = 'Долгота должна быть в диапазоне от -180 до 180';
        return false;
      }
    } catch (e) {
      errorLongitude.value = 'Введите корректное значение долготы';
      return false;
    }

    try {
      int zoom = int.parse(zoomController.text);
      if (zoom < 0 || zoom > 19) {
        errorZoom.value = 'Зум должен быть в диапазоне от 0 до 19';
        return false;
      }
    } catch (e) {
      errorZoom.value = 'Введите корректное значение зума';
      return false;
    }
    return true;
  }

  var projections = [
    {'name': 'wgs84Mercator', 'eccentricity': 0.0818191908426},
    {'name': 'sphericalMercator', 'eccentricity': 0}
  ];

  List<double> fromGeoToPixels(
    double lat,
    double long,
    double eccentricity,
    int z,
  ) {
    double x_p, y_p;
    double rho;
    double beta;
    double phi;
    double theta;
    double e = eccentricity;

    rho = pow(2, z + 8) / 2;
    beta = lat * pi / 180;
    phi = (1 - e * sin(beta)) / (1 + e * sin(beta));
    theta = tan(pi / 4 + beta / 2) * pow(phi, e / 2);

    x_p = rho * (1 + long / 180);
    y_p = rho * (1 - log(theta) / pi);

    return [x_p, y_p];
  }

  List<int> fromPixelsToTileNumber(double x, double y) {
    return [(x / 256).floor(), (y / 256).floor()];
  }

  List<int> calculateTileNumber(double lat, double long, int z) {
    var projection = projections[0];
    var pixelCoords =
        fromGeoToPixels(lat, long, projection['eccentricity'] as double, z);
    var tileNumber = fromPixelsToTileNumber(pixelCoords[0], pixelCoords[1]);
    return tileNumber;
  }
}
