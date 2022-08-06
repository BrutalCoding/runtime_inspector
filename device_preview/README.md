<p align="center">
  <img src="https://github.com/BrutalCoding/runtime_inspector/raw/main/logo.png" alt="Device Preview for Flutter" />
</p>

<h4 align="center">Approximate how your app looks and performs on another device.</h4>

<p align="center">
  <a href="https://pub.dartlang.org/packages/device_preview"><img src="https://img.shields.io/pub/v/device_preview.svg"></a>
  <a href="https://www.buymeacoffee.com/brutalcoding">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <img src="https://github.com/BrutalCoding/runtime_inspector/raw/main/device_preview.gif" alt="Device Preview for Flutter" />
</p>

## Runtime Inspector is based on Device Preview
A spin-off from Device Preview, which can be found here: https://github.com/aloisdeniel/flutter_device_preview

Thanks to [aloisdeniel](https://github.com/aloisdenie) for putting up a great package.

Why not a fork? Because I tend to deviate the code a lot and committing these changes back will make it too different. 

Runtime Inspector is intended to be a one-stop plugin for you and your testers. Monkey testing enhanced!

## Runtime Inspector features
* Option to clear app cache (*SharedPrefences, getTemporaryDirectory() getApplicationSupportDirectory() but not this plugin preferences*)
* Option to reset to default values (*Clears preferences of this plugin*)
* Option to access "End User Experience" menu (*the app as seen by your end users, with options*)
* Option to force rebuild widget tree
* 0 linter issues
* Updated example app with button to save or clear cached boolean
* General bug fixes

## Runtime Inspector roadmap 2022 
The following is a list of things that I would like to finish in no particular order.
* Migrate from Provider to Riverpod
* Migrate to full sound null safety
* GH Action "Version Bot" ersioning each merge to main (*pubspec patch bump, git annotated tag and auto-generated CHANGELOG.md - All done through GH Actions*)
* GH Action "PR Bot", to analyze and test your PR's for each commit. Only PR's with green checks will be reviewed!
* GH Action "Code Coverage Bot", to generate a HTML code coverage report and upload to GitHub Pages. Triggered on merge to dev.

## Main features (from Device Preview)

* Preview any device from any device
* Change the device orientation
* Dynamic system configuration (*language, dark mode, text scaling factor, ...)*
* Freeform device with adjustable resolution and safe areas
* Keep the application state

* Plugin system (*Screenshot, File explorer, ...*)
* Customizable plugins

## Quickstart

### Add dependency to your pubspec file

Since Device Preview is a simple Dart package, you have to declare it as any other dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  device_preview: 
    git:
      url: https://github.com/BrutalCoding/runtime_inspector
      ref: dev # Feel free to try another the branch
      path: device_preview/
```

### Add DevicePreview

Wrap your app's root widget in a `DevicePreview` and make sure to :

* Set your app's `useInheritedMediaQuery` to `true`.
* Set your app's `builder` to `DevicePreview.appBuilder`.
* Set your app's `locale` to `DevicePreview.locale(context)`.

> Make sure to override the previous properties as described. If not defined, `MediaQuery` won't be simulated for the selected device.

```dart
import 'package:device_preview/device_preview.dart';

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
```

## Documentation

<a href='https://brutalcoding.github.io/runtime_inspector/' target='_blank'>Open the website</a>

## Demo

<a href='https://flutter-device-preview.firebaseapp.com/' target='_blank'>Open the demo</a>

## Limitations

Think of Device Preview as a first-order approximation of how your app looks and feels on a mobile device. With Device Mode you don't actually run your code on a mobile device. You simulate the mobile user experience from your laptop, desktop or tablet.

> There are some aspects of mobile devices that Device Preview will never be able to simulate. When in doubt, your best bet is to actually run your app on a real device.