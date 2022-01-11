import 'dart:io';

import 'package:app_in_snap_task/upload/presentation/manager/home_page_view_model.dart';
import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  const Avatar({required this.viewModel, Key? key}) : super(key: key);
  final HomePageViewModel viewModel;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 5,
          shape: const CircleBorder(),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: ClipOval(
              child: ValueListenableBuilder(
                valueListenable: widget.viewModel.imageFile,
                builder: (_, File? file, __) {
                  if (file == null) return const SizedBox.shrink();
                  return Image.file(file, fit: BoxFit.cover, width: 120, height: 120);
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: -20,
          bottom: -5,
          child: OutlinedButton(
            onPressed: () {
              _showPicker(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              primary: Theme.of(context).primaryColor,
              padding: EdgeInsets.zero,
              elevation: 3,
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        )
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select image',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.redAccent,
                        size: 26,
                      ),
                    )
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: const Text(
                        'Gallery',
                      ),
                      onTap: () async {
                        await widget.viewModel.getFromGallery();
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.camera_enhance_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: const Text(
                        'Camera',
                      ),
                      onTap: () async {
                        await widget.viewModel.getFromCamera();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
