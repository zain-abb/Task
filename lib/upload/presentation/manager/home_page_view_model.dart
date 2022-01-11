import 'dart:async';
import 'dart:io';

import 'package:app_in_snap_task/upload/services/local/moor_database.dart';
import 'package:app_in_snap_task/upload/services/remote/remote_data_source.dart';
import 'package:app_in_snap_task/utils/constants.dart';
import 'package:app_in_snap_task/utils/image_conversion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageViewModel {
  ValueNotifier<File?> imageFile = ValueNotifier<File?>(null);
  ValueNotifier<String> name = ValueNotifier<String>('');
  ValueNotifier<String> age = ValueNotifier<String>('');
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isInitialized = ValueNotifier<bool>(true);
  ValueNotifier<int> counter = ValueNotifier<int>(0);
  ValueNotifier<int> timer = ValueNotifier<int>(60);

  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  void startTimer(BuildContext context) {
    if (imageFile.value != null) {
      const duration = Duration(minutes: 1);
      Timer.periodic(
        duration,
        (Timer timer) async {
          isLoading.value = true;
          await _remoteDataSource.addDataToFireStore(counter.value, name.value, age.value, imageFile.value);
          showSnackBar(context, 'Data added to Firestore successfully!', Colors.green);
          isLoading.value = false;
        },
      );
    }
  }

  Future<void> setCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(counterId, counter.value);
  }

  Future<void> getCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(counterId)) {
      counter.value = prefs.getInt(counterId) ?? 0;
    }
  }

  /// Pick Image from Gallery
  Future<void> getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  /// Pick Image from Camera
  Future<void> getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  /// Get changed value of name text form field
  void onNameChanged(String value) {
    name.value = value;
  }

  /// Get the changed value of age text form field
  void onAgeChanged(String value) {
    age.value = value;
  }

  /// Watch existing data from Storage
  void watchExistingData(BuildContext context) async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    var stream = database.watchAllTasks();
    stream.listen((task) async {
      if (task.isNotEmpty) {
        isLoading.value = true;
        var file = await ImageConversion.getImageFromBase64(task.last.image);
        imageFile.value = file;
        name.value = task.last.name;
        age.value = task.last.age;
        isLoading.value = false;
      }
    });
  }

  /// Upload the values
  Future<void> submit(BuildContext context) async {
    print('ImageFile: ${imageFile.value}');
    if (imageFile.value != null && name.value.isNotEmpty && age.value.isNotEmpty) {
      isLoading.value = true;
      String imgString = ImageConversion.base64String(imageFile.value!.readAsBytesSync());
      final database = Provider.of<AppDatabase>(context, listen: false);
      final task = Task(
        id: counter.value,
        image: imgString,
        name: name.value,
        age: age.value,
      );
      database.insertTask(task);
      counter.value++;
      await setCounter();
      isLoading.value = false;
      showSnackBar(context, 'Data added to Local DB successfully!', Colors.green);
      startTimer(context);
    } else {
      if (imageFile.value == null) {
        showBanner(context, 'Please select the avatar image!', Colors.redAccent);
      } else if (name.value.isEmpty) {
        showBanner(context, 'Please enter the name first!', Colors.redAccent);
      } else if (age.value.isEmpty) {
        showBanner(context, 'Please enter the age first!', Colors.redAccent);
      }
    }
  }

  /// Material Banner
  void showBanner(BuildContext context, String title, Color color) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(title),
        contentTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: color,
        actions: [
          TextButton(
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Dismiss'),
          )
        ],
      ),
    );
  }

  /// Show Snack Bar
  void showSnackBar(BuildContext context, String title, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
  }
}
