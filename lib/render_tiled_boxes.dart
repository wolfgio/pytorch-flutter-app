import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pytorch_poc/pytorch.dart';
import 'package:talker/talker.dart';

class TiledBoxesOnImage extends StatelessWidget {
  final Talker talker;
  final File img;
  final List<OutputSlicing?>? outputSlicing;
  final List<String>? labels;

  const TiledBoxesOnImage({
    super.key,
    required this.talker,
    required this.img,
    this.outputSlicing,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double factorX = constraints.maxWidth;
        double factorY = constraints.maxHeight;

        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: factorX,
              height: factorY,
              child: Image.file(img, fit: BoxFit.fill),
            ),
            if (outputSlicing != null)
              for (var output in outputSlicing!)
                ...renderBoxes(
                  talker,
                  factorX,
                  factorY,
                  output,
                  labels,
                )
          ],
        );
      },
    );
  }
}

List<Widget> renderBoxes(
  Talker talker,
  double factorX,
  double factorY,
  OutputSlicing? output,
  List<String>? labels,
) {
  // final widthScale = output.imgWidth / output.tileWidth;
  // final heightScale = output.imgHeight / output.tileHeight;

  if (output == null) {
    return [const SizedBox.shrink()];
  }

  final x = output.slice.coordinates[0];
  final y = output.slice.coordinates[1];
  final imgWidth = output.imgWidth;
  final imgHeight = output.imgHeight;

  return output.detections.map<Widget>((re) {
    final pLeft = (x + re.rect.left * 640) / imgWidth;
    final pTop = (y + re.rect.top * 640) / imgHeight;
    final pRight = (x + re.rect.right * 640) / imgWidth;
    final pBottom = (y + re.rect.bottom * 640) / imgHeight;

    talker.debug("""
      
      x  $x
      y  $y

      ============ img ============

      width  ${output.imgWidth}
      height ${output.imgHeight}

      ============ points ============

      left ${re.rect.left}
      top  ${re.rect.top}

      ============ final ============

      left ${pLeft * factorX}
      top  ${pTop * factorY - 20}
    """);

    return Positioned(
      left: pLeft * factorX,
      top: pTop * factorY - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Text(
              "${labels?[re.classIndex] ?? re.classIndex.toString()}_${(re.score * 100).toStringAsFixed(2)}%",
            ),
          ),
          Container(
            width: (pRight - pLeft) * factorX,
            height: (pBottom - pTop) * factorY,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 3),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            child: Container(),
          ),
        ],
      ),
    );
  }).toList();
}
