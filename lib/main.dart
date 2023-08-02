import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tile_calculator_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Yandex Tile Calculator')),
        body: TileCalculator(),
      ),
    );
  }
}

class TileCalculator extends StatelessWidget {
  final TileCalculatorController controller =
      Get.put(TileCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller.latitudeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Широта',
              errorText: controller.errorLatitude.value,
            ),
          ),
          TextField(
            controller: controller.longitudeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Долгота',
              errorText: controller.errorLongitude.value,
            ),
          ),
          TextField(
            controller: controller.zoomController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Зум',
              errorText: controller.errorZoom.value,
            ),
          ),
          ElevatedButton(
            onPressed: controller.calculateTile,
            child: const Text('Рассчитать тайл'),
          ),
          Obx(() => Text(controller.tileCoordinates.value)),
          Obx(() => controller.imageUrl.value == null
              ? Container()
              : Image.network(
                  controller.imageUrl.value!,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) => Center(
                      child: Text(
                        'По данным координатам плитка не найдена, попробуйте другие.',
                        style: Get.textTheme.headlineSmall?.apply(color: Colors.red),
                      ),
                    ),
                )),
        ],
      ),
    );
  }
}
