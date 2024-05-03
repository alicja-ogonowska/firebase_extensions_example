import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddContentPage extends StatefulWidget {
  const AddContentPage({super.key});

  @override
  State<AddContentPage> createState() => _AddContentPageState();
}

class _AddContentPageState extends State<AddContentPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _photo != null
                  ? kIsWeb
                      ? Image.network(
                          _photo!.path,
                          width: MediaQuery.of(context).size.height / 2,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _photo!,
                          width: MediaQuery.of(context).size.height / 2,
                          fit: BoxFit.cover,
                        )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          child: const Text('Pick image from gallery'),
                        ),
                        if (!kIsWeb)
                          ElevatedButton(
                              onPressed: _pickImageFromCamera,
                              child: const Text('Take new picture')),
                      ],
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _startRecording,
                  child: const Text('Record description')),
              ElevatedButton(
                onPressed: _canSave() ? _onSave : null,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _photo = File(image.path);
      } else {
        debugPrint('Image was not selected.');
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (image != null) {
        _photo = File(image.path);
      } else {
        debugPrint('No photo was selected.');
      }
    });
  }

  void _onSave() {
    debugPrint('Saving');
  }

  bool _canSave() => _photo != null;

  void _startRecording() {}
}
