import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:async';
import 'settings_page.dart'; // Ensure the SettingsPage is imported
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FlashlightApp());
}

class FlashlightApp extends StatelessWidget {
  const FlashlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashlight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlashlightHomePage(),
    );
  }
}

class FlashlightHomePage extends StatefulWidget {
  const FlashlightHomePage({super.key});

  @override
  State<FlashlightHomePage> createState() => _FlashlightHomePageState();
}

class _FlashlightHomePageState extends State<FlashlightHomePage> {
  bool _isTorchOn = false;
  bool _useBackFlashlight = true;
  Color _screenFlashlightColor = Colors.white;
  List<Color> _colorPresets = [];
  static const int _maxPresets = 4;
  bool _isContinuousMode = true;
  Color _appBackgroundColor = Colors.black; // Default background color
  double _strobeInterval = 0.5; // Default strobe interval in seconds
  late TextEditingController _strobeController;
  Timer? _strobeTimer;
  bool _isStrobing = false;

  @override
  void initState() {
    super.initState();
    _strobeController = TextEditingController(text: _strobeInterval.toString());
    _loadColorPresets();
    _loadAppBackgroundColor(); // Load the app background color
    _loadStrobeInterval();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAppBackgroundColor();
  }

  Future<void> _loadColorPresets() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _colorPresets = List.generate(
        _maxPresets,
        (index) => Color(prefs.getInt('colorPreset_$index') ?? Colors.white.toARGB32()),
      );
    });
  }

  Future<void> _saveColorPreset(int index, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('colorPreset_$index', color.toARGB32());
  }

  Future<void> _toggleFlashlight() async {
    if (_isStrobing) {
      _stopStrobe();
      if (_useBackFlashlight) {
        await TorchLight.disableTorch();
      }
      setState(() {
        _isTorchOn = false;
      });
      return;
    }
    try {
      if (_useBackFlashlight) {
        if (_isTorchOn) {
          await TorchLight.disableTorch();
          _stopStrobe();
        } else {
          await TorchLight.enableTorch();
        }
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
      if (!_isContinuousMode && _isTorchOn) {
        _startStrobe();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flashlight error: ${e.toString()}')),
        );
      }
    }
  }

  void _managePresets() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Manage Color Presets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._colorPresets.asMap().entries.map((entry) {
                    final color = entry.value;
                    final idx = entry.key;
                    return Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit color',
                          onPressed: () {
                            // ignore: use_build_context_synchronously
                            _editColor(color, (newColor) {
                              setModalState(() {
                                _colorPresets[idx] = newColor;
                              });
                              setState(() {
                                _colorPresets[idx] = newColor;
                              });
                              _saveColorPreset(idx, newColor);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete color',
                          onPressed: _colorPresets.length > 1
                              ? () {
                                  setModalState(() {
                                    _colorPresets.removeAt(idx);
                                  });
                                  setState(() {});
                                }
                              : null,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Color'),
                    onPressed: _colorPresets.length < _maxPresets
                        ? () {
                            // ignore: use_build_context_synchronously
                            _editColor(Colors.purple, (newColor) {
                              setModalState(() {
                                _colorPresets.add(newColor);
                              });
                              _saveColorPreset(_colorPresets.length - 1, newColor);
                              setState(() {}); // Ensure UI updates only once
                            }, isNew: true);
                          }
                        : null,
                  ),
                  if (_colorPresets.length >= _maxPresets)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Maximum $_maxPresets presets allowed.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editColor(Color currentColor, void Function(Color) onColorChanged, {bool isNew = false}) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        TextEditingController hexController = TextEditingController(
          text: currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase(),
        );
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateColorFromHex(String value) {
              if (value.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value)) {
                try {
                  final newColor = Color(int.parse('0xFF$value'));
                  setDialogState(() {
                    tempColor = newColor;
                    errorText = null;
                  });
                } catch (e) {
                  setDialogState(() {
                    errorText = 'Invalid hex color';
                  });
                }
              } else {
                setDialogState(() {
                  errorText = 'Enter 6 hex digits';
                });
              }
            }

            return AlertDialog(
              title: Text(isNew ? 'Add Color' : 'Edit Color'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (color) {
                        setDialogState(() {
                          tempColor = color;
                          hexController.text = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
                          errorText = null;
                        });
                      },
                      labelTypes: [],
                      pickerAreaHeightPercent: 0.8,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('#', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: TextField(
                            controller: hexController,
                            decoration: InputDecoration(
                              labelText: 'Hex Color',
                              errorText: errorText,
                            ),
                            maxLength: 6,
                            onChanged: updateColorFromHex,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (errorText == null) {
                      onColorChanged(tempColor);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(isNew ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'useMaterialYouTheme': prefs.getBool('useMaterialYouTheme') ?? true,
      'useAmoledBlack': prefs.getBool('useAmoledBlack') ?? false,
      'useCustomColor': prefs.getBool('useCustomColor') ?? false,
      'selectedColor': Color(prefs.getInt('selectedColor') ?? Colors.white.toARGB32()),
    };
  }

  void navigateToSettings() async {
    final preferences = await loadPreferences();
    // ignore: use_build_context_synchronously
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(preferences: preferences),
      ),
    );
    if (!mounted) return;
    _loadAppBackgroundColor(); // Reload background color after returning from settings
  }

  Future<void> _loadAppBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appBackgroundColor = Color(prefs.getInt('AppBackgroundColourValue') ?? Colors.black.toARGB32());
    });
  }

  Future<void> _loadStrobeInterval() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _strobeInterval = prefs.getDouble('strobeInterval') ?? 0.5;
      _strobeController.text = _strobeInterval.toString();
    });
  }

  Future<void> _saveStrobeInterval(double interval) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('strobeInterval', interval);
  }

  void _startStrobe() {
    _strobeTimer?.cancel(); // Cancel any existing timer
    setState(() {
      _isStrobing = true;
    });
    Future<void> strobe() async {
      if (_isContinuousMode) {
        setState(() {
          _isStrobing = false;
        });
        return;
      }
      try {
        if (_useBackFlashlight) {
          if (_isTorchOn) {
            await TorchLight.disableTorch();
          } else {
            await TorchLight.enableTorch();
          }
        }
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
        _strobeTimer = Timer(Duration(milliseconds: (_strobeInterval * 1000).toInt()), () => strobe());
      } catch (e) {
        _strobeTimer?.cancel();
        setState(() {
          _isStrobing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Strobe error: ${e.toString()}')),
          );
        }
      }
    }
    strobe();
  }

  void _stopStrobe() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
    setState(() {
      _isStrobing = false;
    });
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _strobeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashlight'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: navigateToSettings,
          ),
        ],
      ),
      body: Container(
        color: _isTorchOn
            ? (_useBackFlashlight ? Colors.black : _screenFlashlightColor)
            : _appBackgroundColor, // Background color based on AppBackgroundColourValue
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleFlashlight,
                    child: Semantics(
                      label: _isTorchOn ? 'Turn off flashlight' : 'Turn on flashlight',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _isStrobing || _isTorchOn ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_useBackFlashlight) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ..._colorPresets.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _screenFlashlightColor = color;
                              });
                            },
                            child: Semantics(
                              label: 'Select color preset',
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: _managePresets,
                          child: Semantics(
                            label: 'Manage color presets',
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Icon(Icons.add, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!_isContinuousMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 160.0),
                  child: SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _strobeController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Strobe Interval (seconds)',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        fillColor: _appBackgroundColor.withAlpha(255),
                        filled: true,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            _strobeInterval = parsed;
                          });
                          _saveStrobeInterval(parsed);
                          if (!_isContinuousMode && _isTorchOn) {
                            _startStrobe(); // Restart strobe with new interval
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0), // Adjusted position
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25), // Retained rounded shape
                  ),
                  child: ToggleButtons(
                    isSelected: [_isContinuousMode, !_isContinuousMode],
                    onPressed: (index) {
                      setState(() {
                        _isContinuousMode = index == 0;
                        if (_isTorchOn) {
                          _stopStrobe();
                          if (_useBackFlashlight) {
                            TorchLight.disableTorch();
                          }
                          _isTorchOn = false;
                          _isStrobing = false;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    selectedBorderColor: Colors.blue[100], // Ensured no inner boundary
                    selectedColor: Colors.white,
                    fillColor: Colors.blue, // Selected side color
                    color: Theme.of(context).colorScheme.surfaceContainerHighest, // Non-selected side color updated to Material You color
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 100.0,
                    ),
                    children: const [
                      Text('Continuous'),
                      Text('Strobe'),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.flash_on,
                        color: _useBackFlashlight ? Colors.blue : Colors.grey,
                      ),
                      tooltip: 'Use device flashlight',
                      onPressed: () {
                        setState(() {
                          if (_isTorchOn && !_useBackFlashlight) {
                            _isTorchOn = false;
                          }
                          _useBackFlashlight = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.phone_android,
                        color: !_useBackFlashlight ? Colors.blue : Colors.grey,
                      ),
                      tooltip: 'Use screen flashlight',
                      onPressed: () {
                        setState(() {
                          if (_isTorchOn && _useBackFlashlight) {
                            _isTorchOn = false;
                          }
                          _useBackFlashlight = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}