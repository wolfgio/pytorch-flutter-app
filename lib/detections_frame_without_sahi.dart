import 'package:flutter/material.dart';
import 'package:pytorch_poc/pytorch.dart';

class DetectionsFrameWithoutSAHI extends StatelessWidget {
  final Output? output;
  final List<String>? labels;

  const DetectionsFrameWithoutSAHI({super.key, this.output, this.labels});

  @override
  Widget build(BuildContext context) {
    if (output == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          ),
          width: double.infinity,
          height: 320,
          child: output!.model.renderBoxesOnImage(
            output!.outuputWithoutSlicing.file,
            output!.outuputWithoutSlicing.detections,
          ),
        ),
        Expanded(
          child: ListView(
            children: output!.outuputWithoutSlicing.detections
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
