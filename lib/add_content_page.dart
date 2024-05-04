import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fsf_example/audio_recorder.dart';
import 'package:fsf_example/content.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddContentPage extends StatefulWidget {
  const AddContentPage({super.key});

  @override
  State<AddContentPage> createState() => _AddContentPageState();
}

class _AddContentPageState extends State<AddContentPage> {
  XFile? _photo;
  String? _recordingPath;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

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
                          File(_photo!.path),
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
              _recordingPath != null
                  ? const Text('Recording provided')
                  : Recorder(
                      onStop: (path) {
                        setState(() {
                          debugPrint('Recording path: $path');
                          _recordingPath = path;
                        });
                      },
                    ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
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
        _photo = image;
      } else {
        debugPrint('Image was not selected.');
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (image != null) {
        _photo = image;
      } else {
        debugPrint('No photo was selected.');
      }
    });
  }

  bool _canSave() => _photo != null && _recordingPath != null;

  void _onSave() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_photo != null && _recordingPath != null) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final photoUrl = await _uploadPhoto(userId);
        final recordingUrl = await _uploadRecording(userId);

        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('contents')
            .add(
              Content(
                imageUrl: photoUrl,
                recordingUrl: recordingUrl,
              ).toFirestore(),
            )
            .whenComplete(() => Navigator.of(context).pop());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String?> _uploadRecording(String userId) async {
    final Reference recordingRef = FirebaseStorage.instance
        .ref()
        .child('recordings/$userId/${_recordingPath!.split('/').last}.wav');

    late UploadTask recordingUploadTask;
    if (kIsWeb) {
      final uri = Uri.parse(_recordingPath!);
      final client = http.Client();
      final response = await client.get(uri);

      recordingUploadTask = recordingRef.putData(response.bodyBytes);
    } else {
      recordingUploadTask = recordingRef.putFile(File(_recordingPath!));
    }
    String? url;
    await recordingUploadTask.whenComplete(() async {
      url = await recordingRef.getDownloadURL();
    });
    return url;
  }

  Future<String?> _uploadPhoto(String userId) async {
    final Reference photoRef =
        FirebaseStorage.instance.ref().child('images/$userId/${_photo!.name}');

    late UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = photoRef.putData(await _photo!.readAsBytes());
    } else {
      uploadTask = photoRef.putFile(File(_photo!.path));
    }
    String? url;
    await uploadTask.whenComplete(() async {
      url = await photoRef.getDownloadURL();
    });
    return url;
  }
}
