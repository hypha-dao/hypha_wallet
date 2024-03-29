import 'package:flutter/material.dart';
import 'package:hypha_wallet/core/extension/scope_functions.dart';
import 'package:hypha_wallet/design/avatar_image/hypha_avatar_image.dart';
import 'package:image_picker/image_picker.dart';

class HyphaEditableAvatarImage extends StatelessWidget {
  final String? imageFromFile;
  final String? imageFromUrl;
  final String? name;
  final double imageRadius;
  final Function(XFile image)? onImageSelected;
  final GestureTapCallback? onImageRemoved;
  final bool withBorder;

  bool get hasImage => imageFromFile != null || imageFromUrl != null;

  const HyphaEditableAvatarImage({
    super.key,
    this.imageFromFile,
    this.imageFromUrl,
    this.name,
    required this.imageRadius,
    this.onImageSelected,
    this.onImageRemoved,
    this.withBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          HyphaAvatarImage(
            imageRadius: imageRadius,
            imageFromFile: imageFromFile,
            imageFromUrl: imageFromUrl,
            name: name,
            onTap: () async {
              await _selectImage();
            },
            withBorder: withBorder,
          ),
          Positioned(
            top: -10,
            right: -10,
            child: hasImage
                ? IconButton(
                    onPressed: () async {
                      onImageRemoved?.call();
                    },
                    icon: const Icon(
                      Icons.remove_circle,
                      size: 32,
                    ),
                  )
                : IconButton(
                    onPressed: () async {
                      await _selectImage();
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      size: 32,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 0,
      maxHeight: 1500,
      maxWidth: 1500,
    );
    image?.let((it) => onImageSelected?.call(it));
  }
}
