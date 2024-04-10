import 'package:flutter/material.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:pytorch_poc/pytorch.dart';
import 'package:pytorch_poc/render_tiled_boxes.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DetectionsFrameWithSAHI extends StatelessWidget {
  final Talker talker;
  final Output? output;
  final List<String>? labels;

  const DetectionsFrameWithSAHI({
    super.key,
    required this.talker,
    this.output,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (output == null) return const SizedBox.shrink();

    final detections = output!.outputSlicing.fold<List<ResultObjectDetection>>(
      [],
      (prev, element) => prev..addAll(element?.detections ?? []),
    );

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          ),
          width: double.infinity,
          height: 320,
          child: TiledBoxesOnImage(
            talker: talker,
            img: output!.file,
            outputSlicing: output?.outputSlicing,
          ),
        ),
        Expanded(
          child: ListView(
            children: detections
                .map(
                  (detection) => Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text(
                        '${labels?[detection.classIndex]}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Score: ${detection.score}'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '--- Position ---',
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('L: ${detection.rect.left}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('T: ${detection.rect.top}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('R: ${detection.rect.right}'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('B: ${detection.rect.bottom}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
