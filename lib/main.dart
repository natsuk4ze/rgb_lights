import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Home(),
    );
  }
}

/// Start of the code for RGB Lights Effect
const _columnLength = 12;
const _rowLength = 12;
const _lightSize = 20.0;
const _effectScaleMin = 1.0;
const _effectScaleMax = 150.0;
const _effectAlpha = 0.7;
const _effectValue = 1.0;
const _effectSaturation = 1.0;
const _effectDuration = Duration(milliseconds: 10);

typedef ColorMap = Map<int, Color>;

enum EffectType {
  linerWave,
  circularWave;

  ColorMap colorMap(int count, double scale) => switch (this) {
        linerWave => _linerWaveColorMap(count, scale),
        circularWave => _circularWaveColorMap(count, scale),
      };

  /// Change color based on index
  ColorMap _linerWaveColorMap(int count, double scale) => {
        for (var i = 0; i < _columnLength * _rowLength; i++)
          i: _colorFromHue(count + i * scale)
      };

  /// Change color based on distance from center
  ColorMap _circularWaveColorMap(int count, double scale) {
    const centerPosition =
        Offset((_rowLength - 1) / 2, (_columnLength - 1) / 2);
    currentColumnIndex(int i) => i ~/ _rowLength;
    currentRowIndex(int i) => i % _rowLength;
    currentPosition(int i) =>
        Offset(currentRowIndex(i).toDouble(), currentColumnIndex(i).toDouble());

    return {
      for (var i = 0; i < _columnLength * _rowLength; i++)
        i: _colorFromHue(
            count + (currentPosition(i) - centerPosition).distance * scale)
    };
  }

  Color _colorFromHue(double hue) => HSVColor.fromAHSV(
          _effectAlpha, hue % 360, _effectSaturation, _effectValue)
      .toColor();

  IconData get icon => switch (this) {
        linerWave => Icons.blur_linear,
        circularWave => Icons.blur_circular,
      };

  @override
  String toString() => switch (this) {
        linerWave => 'Liner Wave',
        circularWave => 'Circular Wave',
      };
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  EffectType selectedEffect = EffectType.linerWave;
  double effectScale = _effectScaleMin;
  int count = 0;
  Timer? timer;
  final countController = StreamController<int>();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(_effectDuration, (_) {
      countController.add(count);
      count++;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    countController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EffectSelectionButton(
              selectedEffect: selectedEffect,
              onSelectionChanged: (value) =>
                  setState(() => selectedEffect = value),
            ),
            const SizedBox(height: 40),
            StreamBuilder<int>(
              stream: countController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                return Lights(
                  colorMap:
                      selectedEffect.colorMap(snapshot.data!, effectScale),
                );
              },
            ),
            const SizedBox(height: 40),
            EffectScaleSlider(
              currentScale: effectScale,
              onScaleChanged: (value) => setState(() => effectScale = value),
            ),
          ],
        ),
      ),
    );
  }
}

class EffectSelectionButton extends StatelessWidget {
  const EffectSelectionButton({
    required this.selectedEffect,
    required this.onSelectionChanged,
    super.key,
  });

  final EffectType selectedEffect;
  final void Function(EffectType) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<EffectType>(
      onSelectionChanged: (typeSet) => onSelectionChanged(typeSet.first),
      showSelectedIcon: false,
      segments: [
        for (var type in EffectType.values)
          ButtonSegment(
            icon: Icon(type.icon),
            value: type,
            label: Text(type.toString()),
          )
      ],
      selected: {selectedEffect},
    );
  }
}

class EffectScaleSlider extends StatelessWidget {
  const EffectScaleSlider({
    required this.currentScale,
    required this.onScaleChanged,
    super.key,
  });

  final double currentScale;
  final void Function(double) onScaleChanged;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: _effectScaleMin,
      max: _effectScaleMax,
      value: currentScale,
      onChanged: onScaleChanged,
    );
  }
}

class Lights extends StatelessWidget {
  const Lights({
    required this.colorMap,
    super.key,
  });

  final ColorMap colorMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var columnIndex = 0; columnIndex < _columnLength; columnIndex++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var rowIndex = 0; rowIndex < _rowLength; rowIndex++)
                Light(color: colorMap[_rowLength * columnIndex + rowIndex]!),
            ],
          ),
      ],
    );
  }
}

class Light extends StatelessWidget {
  const Light({
    super.key,
    required this.color,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: _lightSize,
        width: _lightSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: _lightSize / 4,
            )
          ],
        ),
      ),
    );
  }
}
