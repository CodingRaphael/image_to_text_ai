import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'claude_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? _description;
  bool _isLoading = false;
  final _picker = ImagePicker();

  //Pick image
  Future<void> _pickImage(ImageSource source) async {
    //pick image from camera or gallery
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 85,
      );
      //start analysing
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _analyzeImage();
      }
    } catch (e) {
      print(e);
    }
  }

  //analyse image method
  Future<void> _analyzeImage() async {
    if (_image == null) return;
    //set loading state
    setState(() {
      _isLoading = true;
    });
    //start analysing
    try {
      final description = await ClaudeService().analyzeImage(_image!);
      setState(() {
        _description = 'description';
      });
    } catch (e) {
      print(e);
      //set loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI vision'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_image != null)
            Expanded(
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text('No image selected'),
              ),
            ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Take a photo'),
            ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Text('Pick from gallery'),
          ),
          if (_description != null)
            Text(
              _description!,
              style: const TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }
}
