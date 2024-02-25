// import 'package:flutter/material.dart';
// import 'package:pytorch_poc/pytorch.dart';
// import 'package:talker/talker.dart';

// class TiledBoxesOnImage extends StatelessWidget {
//   final Talker talker;
//   final TiledResult result;

//   const TiledBoxesOnImage({
//     super.key,
//     required this.talker,
//     required this.result,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double factorX = constraints.maxWidth;
//         double factorY = constraints.maxHeight;

//         return Stack(
//           children: [
//             Positioned(
//               left: 0,
//               top: 0,
//               width: factorX,
//               height: factorY,
//               child: Image.file(result.img),
//             ),
//             for (var output in result.outputs)
//               ...renderBoxes(talker, factorX, factorY, output)
//           ],
//         );
//       },
//     );
//   }
// }

// List<Widget> renderBoxes(
//     Talker talker, double factorX, double factorY, TiledOutput output) {
//   final widthScale = output.imgWidth / output.tileWidth;
//   final heightScale = output.imgHeight / output.tileHeight;

//   return output.detections.map<Widget>((re) {
//     final rectLeft = re.rect.left;
//     final rectTop = re.rect.top;
//     final rectRight = re.rect.right;
//     final rectBottom = re.rect.bottom;
//     final rectWidth = re.rect.width;
//     final rectHeight = re.rect.height;

//     final scaledLeft = rectLeft * widthScale;
//     final scaledTop = rectTop * heightScale;
//     final scaledRight = rectRight * widthScale;
//     final scaledBottom = rectBottom * heightScale;
//     final scaledWidth = rectWidth * widthScale;
//     final scaledHeight = rectHeight * heightScale;

//     final standardLeft = rectLeft * factorX;
//     final standardTop = rectTop * factorY;
//     final standardWidth = rectWidth.toDouble() * factorX;
//     final standardHeight = rectHeight.toDouble() * factorY;

//     final tiledLeft = (rectLeft * factorX) * scaledWidth;
//     final tiledTop = (rectTop * factorY) * scaledHeight;
//     final tiledWidth = (scaledWidth * factorX).toDouble() / widthScale;
//     final tiledHeight = (scaledHeight * factorY).toDouble() / heightScale;

//     talker.debug("""


//       factor_x: $factorX, factor_y: $factorY
//       img_width: ${output.imgWidth}, img_height: ${output.imgHeight}
//       tile_width: ${output.tileWidth}, tile_height: ${output.tileHeight}

//       x: ${output.x}, y: ${output.y}

//       ===================

//       score: ${output.detections.map((e) => e.score).toString()}

//       ===================

//       width_scale: $widthScale, height_scale: $heightScale

//       ===================

//       detection
//         left: $rectLeft
//         top: $rectTop
//         right: $rectRight
//         bottom: $rectBottom
//         width: $rectWidth
//         height: $rectHeight

//       scaled
//         left: $scaledLeft
//         top: $scaledTop
//         right: $scaledRight
//         bottom: $scaledBottom
//         width: $scaledWidth
//         height: $scaledHeight

//       full-image-position-without-scale
//         left: $standardLeft
//         top: $standardTop
//         width: $standardWidth
//         height: $standardHeight

//       full-image-position-with-scale
//         left: $tiledLeft
//         top: $tiledTop
//         width: $tiledWidth
//         height: $tiledHeight
//     """);

//     return Positioned(
//       left: standardLeft,
//       top: standardTop - 20,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 20,
//             alignment: Alignment.centerRight,
//             color: Colors.red,
//             child: Text(
//               "${re.className ?? re.classIndex.toString()}_${(re.score * 100).toStringAsFixed(2)}%",
//             ),
//           ),
//           Container(
//             width: standardWidth,
//             height: standardHeight,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.red, width: 3),
//               borderRadius: const BorderRadius.all(Radius.circular(2)),
//             ),
//             child: Container(),
//           ),
//         ],
//       ),
//     );
//   }).toList();
// }
