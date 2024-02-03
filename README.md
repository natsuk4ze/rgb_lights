# RGB Lights Effect in Flutter

![demo](https://github.com/natsuk4ze/rgb_lights/raw/main/assets/demo.gif)

### Dynamically generates RGB light effects in Flutter. 
Remember to [star this repository](https://github.com/natsuk4ze/rgb_lights) for more.

## How does it work

The mechanism is very simple. Like digital signage, we prepare several dots and map a color to each dot.

`HSVColor` is used to generate effects. It has the property that colors can be represented using 360 degrees from 0, which works very well with gradients. (I also use it in [my holographic UI](https://github.com/natsuk4ze/holo))

For example, with just this code, you can create an animation with a color gradient transition.
Actually, I could have used `ColorTween`, but the performance was not good, so I simply used `Stream` and counter. (This could be rewritten.)
```dart
... // Increment 'hue' with a counter.

ColoredBox(color: HSVColor.fromAHSV(1.0, hue % 360, 1.0, 1.0).toColor());
```

Interestingly, one can generate a variety of geometric patterns simply by scaling the function that creates the wave.
```dart
ColorMap _linerWaveColorMap(int count, double scale) => {
      for (var i = 0; i < _columnLength * _rowLength; i++)
        i: _colorFromHue(count + i * scale)
    };
```

In this project, Liner Wave and Circluler Wave are provided as samples, but the number of effects can be infinitely increased. Please experiment with them yourself. To aid understanding, I have combined all classes into one file and have not made any performance adjustments. Please make changes accordingly.
