import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:pytorch_poc/detections_frame_slices.dart';
import 'package:pytorch_poc/detections_frame_without_sahi.dart';
import 'package:pytorch_poc/pytorch.dart';
import 'package:talker/talker.dart';

class HomeScreen extends StatefulWidget {
  final Talker talker;

  const HomeScreen({super.key, required this.talker});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Output? _output;
  List<String>? _labels;

  double _xOverlap = 0.0, _yOverlap = 0.0;
  double _sliceWidth = 256, _sliceHeight = 256;

  Future<void> _onPressed(
    String modelPath,
    ObjectDetectionModelType modelType,
  ) async {
    final output = await runInfereces(
      modelPath: modelPath,
      modelType: modelType,
      talker: widget.talker,
      sliceSize: Size(_sliceWidth, _sliceHeight),
      xOverlap: _xOverlap,
      yOverlap: _yOverlap,
    );
    final labels = await loadLabels();

    setState(() {
      _output = output;
      _labels = labels;
    });
  }

  void _onChangedSlider(Axis axis, double value) {
    if (axis == Axis.horizontal) {
      setState(() {
        _xOverlap = value;
      });
    } else {
      setState(() {
        _yOverlap = value;
      });
    }
  }

  void _onChangedInput(Axis axis, String value) {
    if (axis == Axis.horizontal && value.isNotEmpty) {
      setState(() {
        _sliceWidth = double.parse(value);
      });
    }

    if (axis == Axis.vertical && value.isNotEmpty) {
      setState(() {
        _sliceHeight = double.parse(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch DEMO'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(tabs: [
            Tab(text: 'NO SLICING'),
            Tab(text: 'WITH SLICING'),
            Tab(text: 'SLICES'),
          ]),
        ),
        floatingActionButton: ButtonBar(
          children: [
            FloatingActionButton(
              heroTag: null,
              onPressed: () => _onPressed(
                'assets/yolov5s.torchscript',
                ObjectDetectionModelType.yolov5,
              ),
              child: const Text('V5'),
            ),
            FloatingActionButton(
              heroTag: null,
              onPressed: () => _onPressed(
                'assets/yolov8n.torchscript',
                ObjectDetectionModelType.yolov8,
              ),
              child: const Text('V8'),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Slice Width',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _onChangedInput(
                        Axis.horizontal,
                        value,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: '256',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Slice Height',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _onChangedInput(
                        Axis.vertical,
                        value,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: '256',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        const Text('X overlap ratio'),
                        Slider(
                          divisions: 5,
                          value: _xOverlap,
                          onChanged: (value) => _onChangedSlider(
                            Axis.horizontal,
                            value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        const Text('Y overlap ratio'),
                        Slider(
                          divisions: 5,
                          value: _yOverlap,
                          onChanged: (value) => _onChangedSlider(
                            Axis.vertical,
                            value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DetectionsFrameWithoutSAHI(output: _output, labels: _labels),
                  const SizedBox.shrink(),
                  DetectionsFrameSlices(output: _output, labels: _labels),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
