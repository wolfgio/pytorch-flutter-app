import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_api;
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:talker/talker.dart';

class Slice {
  final List<int> coordinates;
  final Uint8List bytes;
  final File file;

  const Slice({
    required this.coordinates,
    required this.bytes,
    required this.file,
  });
}

class OutuputWithoutSlicing {
  final List<ResultObjectDetection> detections;
  final File file;

  const OutuputWithoutSlicing({required this.detections, required this.file});
}

class OutputSlicing {
  final List<ResultObjectDetection> detections;
  final Slice slice;
  final int imgWidth;
  final int imgHeight;

  const OutputSlicing({
    required this.detections,
    required this.slice,
    required this.imgWidth,
    required this.imgHeight,
  });
}

class Output {
  final ModelObjectDetection model;
  final File file;
  final OutuputWithoutSlicing outuputWithoutSlicing;
  final List<OutputSlicing?> outputSlicing;

  const Output({
    required this.model,
    required this.file,
    required this.outuputWithoutSlicing,
    required this.outputSlicing,
  });
}

Future<List<String>> loadLabels() async {
  return (await rootBundle.loadString('assets/labels.txt')).split('\n');
}

Future<Slice> createImageSlice({
  required image_api.Image img,
  required List<int> coordinates,
  required String tempDir,
  required Talker talker,
  required int sliceWidth,
  required int sliceHeight,
}) async {
  final xmin = coordinates[0];
  final ymin = coordinates[1];
  final xmax = coordinates[2];
  final ymax = coordinates[3];

  final date = DateTime.now().toIso8601String();
  final imgPath = '$tempDir/image_slices/slice_${date}_${xmin}_$ymin.png';

  talker.debug("coordinates $coordinates");

  final cmd = (image_api.Command()
    ..image(img)
    ..copyCrop(x: xmin, y: ymin, width: sliceWidth, height: sliceHeight)
    ..copyExpandCanvas(
      newWidth: 640,
      newHeight: 640,
      position: image_api.ExpandCanvasPosition.topLeft,
    )
    ..writeToFile(imgPath));

  await cmd.executeThread();
  final bytes = await File(imgPath).readAsBytes();

  return Slice(coordinates: coordinates, bytes: bytes, file: File(imgPath));
}

Future<List<OutputSlicing?>> runSlicing({
  required ModelObjectDetection model,
  required Talker talker,
  required Size sliceSize,
  required Uint8List imgBytes,
  required String tempDir,
  double overlapHeightRatio = 0.2,
  double overlapWidthRatio = 0.2,
}) async {
  try {
    final img = image_api.decodeImage(imgBytes);

    if (img != null) {
      final sliceWidth = sliceSize.width.toInt();
      final sliceHeight = sliceSize.height.toInt();

      final imgWidth = img.width;
      final imgHeight = img.height;

      final outputs = <OutputSlicing?>[];

      int yMax = 0, yMin = 0;

      final yOverlap = (overlapHeightRatio * sliceHeight).toInt();
      final xOverlap = (overlapWidthRatio * sliceWidth).toInt();

      while (yMax < imgHeight) {
        int xMax = 0, xMin = 0;
        yMax = yMin + sliceHeight;

        while (xMax < imgWidth) {
          xMax = xMin + sliceWidth;
          if (yMax > imgHeight || xMax > imgWidth) {
            final xmax = min(imgWidth, xMax);
            final ymax = min(imgHeight, yMax);
            final xmin = max(0, xmax - sliceWidth);
            final ymin = max(0, ymax - sliceHeight);

            final slice = await createImageSlice(
              img: img,
              coordinates: [xmin, ymin, xmax, ymax],
              tempDir: tempDir,
              talker: talker,
              sliceWidth: sliceWidth,
              sliceHeight: sliceHeight,
            );

            final detections = await model.getImagePredictionList(slice.bytes);
            outputs.add(
              OutputSlicing(
                detections: detections,
                slice: slice,
                imgWidth: imgWidth,
                imgHeight: imgHeight,
              ),
            );
          } else {
            final slice = await createImageSlice(
              img: img,
              coordinates: [xMin, yMin, xMax, yMax],
              tempDir: tempDir,
              talker: talker,
              sliceWidth: sliceWidth,
              sliceHeight: sliceHeight,
            );

            final detections = await model.getImagePredictionList(slice.bytes);
            outputs.add(
              OutputSlicing(
                detections: detections,
                slice: slice,
                imgWidth: imgWidth,
                imgHeight: imgHeight,
              ),
            );
          }
          xMin = xMax - xOverlap;
        }
        yMin = yMax - yOverlap;
      }

      return outputs;
    }
  } catch (e, st) {
    talker.handle(e, st);
  }

  return [];
}

Future<List<ResultObjectDetection>> runWithoutSlicing({
  required ModelObjectDetection model,
  required String tempDir,
  required Talker talker,
  required Uint8List imgBytes,
}) async {
  try {
    final output = await model.getImagePredictionList(imgBytes);

    return output;
  } catch (e, st) {
    talker.handle(e, st);
  }

  return [];
}

Future<Output?> runInfereces({
  required String modelPath,
  required ObjectDetectionModelType modelType,
  required Talker talker,
  required Size sliceSize,
  required double xOverlap,
  required double yOverlap,
}) async {
  try {
    final tempDir = (await getTemporaryDirectory()).path;
    final model = await PytorchLite.loadObjectDetectionModel(
      modelPath,
      80,
      640,
      640,
      labelPath: 'assets/labels.txt',
      objectDetectionModelType: modelType,
    );

    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      final imgBytes = await xFile.readAsBytes();

      final outputWithoutSAHI = await runWithoutSlicing(
        model: model,
        tempDir: tempDir,
        imgBytes: imgBytes,
        talker: talker,
      );

      final outputSlicing = await runSlicing(
        model: model,
        tempDir: tempDir,
        talker: talker,
        sliceSize: sliceSize,
        overlapWidthRatio: xOverlap,
        overlapHeightRatio: yOverlap,
        imgBytes: imgBytes,
      );

      return Output(
        model: model,
        file: File(xFile.path),
        outputSlicing: outputSlicing,
        outuputWithoutSlicing: OutuputWithoutSlicing(
          detections: outputWithoutSAHI,
          file: File(xFile.path),
        ),
      );
    }
  } catch (e, st) {
    talker.handle(e, st);
  }

  return null;
}
