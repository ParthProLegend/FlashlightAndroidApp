import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> preferences;

  const SettingsPage({super.key, required this.preferences});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late bool useMaterialYouTheme;
  late bool useAmoledBlack;
  late bool useCustomColor;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    useMaterialYouTheme = widget.preferences['useMaterialYouTheme'];
    useAmoledBlack = widget.preferences['useAmoledBlack'];
    useCustomColor = widget.preferences['useCustomColor'];
    selectedColor = widget.preferences['selectedColor'];
    _loadAppBackgroundColorValue().then((color) {
      setState(() {
        selectedColor = color;
      });
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useMaterialYouTheme', useMaterialYouTheme);
    prefs.setBool('useAmoledBlack', useAmoledBlack);
    prefs.setBool('useCustomColor', useCustomColor);
    prefs.setInt('selectedColor', selectedColor.toARGB32());
  }

  Future<void> _saveAppBackgroundColorValue(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('AppBackgroundColourValue', color.toARGB32());
  }

  Future<Color> _loadAppBackgroundColorValue() async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt('AppBackgroundColourValue') ?? Colors.white.toARGB32());
  }

  void _updateAppBackgroundColor() {
    if (useMaterialYouTheme) {
      _saveAppBackgroundColorValue(Theme.of(context).colorScheme.surfaceContainerHighest);
    } else if (useAmoledBlack) {
      _saveAppBackgroundColorValue(Colors.black);
    } else if (useCustomColor) {
      _saveAppBackgroundColorValue(selectedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Use Material You Theme'),
              value: useMaterialYouTheme,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    useMaterialYouTheme = true;
                    useAmoledBlack = false;
                    useCustomColor = false;
                  } else {
                    useMaterialYouTheme = false;
                  }
                  _updateAppBackgroundColor();
                  _savePreferences();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Use AMOLED Black'),
              value: useAmoledBlack,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    useAmoledBlack = true;
                    useMaterialYouTheme = false;
                    useCustomColor = false;
                  } else {
                    useAmoledBlack = false;
                  }
                  _updateAppBackgroundColor();
                  _savePreferences();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Use Custom Color'),
              value: useCustomColor,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    useCustomColor = true;
                    useMaterialYouTheme = false;
                    useAmoledBlack = false;
                  } else {
                    useCustomColor = false;
                  }
                  _updateAppBackgroundColor();
                  _savePreferences();
                });
              },
            ),
            if (useCustomColor)
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Row(
                  children: [
                    const Text('Color:'),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        Color? color = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Select Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: selectedColor,
                                  onColorChanged: (color) {
                                    selectedColor = color;
                                  },
                                  labelTypes: [],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(selectedColor);
                                  },
                                  child: const Text('Select'),
                                ),
                              ],
                            );
                          },
                        );
                        if (color != null) {
                          setState(() {
                            selectedColor = color;
                            _saveAppBackgroundColorValue(selectedColor); // Update AppBackgroundColourValue
                            _savePreferences();
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.black),
              title: const Text('My GitHub Profile'),
              onTap: () async {
                const url = 'https://github.com/default-profile';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.black),
              title: const Text('GitHub Repository (Contributions Welcome!!)'),
              onTap: () async {
                const url = 'https://github.com/default-repo';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.coffee, color: Colors.brown),
              title: const Text('Support on Ko-Fi'),
              onTap: () async {
                const url = 'https://ko-fi.com/parthprolegend';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}