import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:locket_app/modules/camera/domain/repository/camera_repository.dart';
import '../application/cubit/camera_cubit.dart';

class PreviewPage extends StatefulWidget {
  final String path;
  final bool isVideo;
  const PreviewPage({super.key, required this.path, required this.isVideo});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final _captionController = TextEditingController();
  List<String> selectedUids = [];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraCubit, CameraState>(
      listener: (context, state) {
        if (state.status == CameraStatus.success) {
          Navigator.pop(context); // Quay về camera
          context.read<CameraCubit>().resetStatus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () async {
                await ImageGallerySaverPlus.saveFile(widget.path);
                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Saved successfully!")),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: widget.isVideo
                    ? const Center(child: Icon(Icons.play_circle, size: 50))
                    : Image.file(File(widget.path), fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Add a message...",
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
            ),
            const Text(
              "Choose viewers:",
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildFriendSelector(),
            const Spacer(),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendSelector() {
    return SizedBox(
      height: 100,
      child: FutureBuilder<List<String>>(
        future: context.read<CameraRepository>().getMyFriendIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final friends = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final uid = friends[index];
              final isSelected = selectedUids.contains(uid);
              return GestureDetector(
                onTap: () => setState(
                  () => isSelected
                      ? selectedUids.remove(uid)
                      : selectedUids.add(uid),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected
                        ? Colors.yellow
                        : Colors.white10,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: GestureDetector(
            onTap: state.status == CameraStatus.loading
                ? null
                : () {
                    context.read<CameraCubit>().postMoment(
                      localPath: widget.path,
                      manualCaption: _captionController.text,
                      selectedFriendIds: selectedUids,
                    );
                  },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: state.status == CameraStatus.loading
                  ? const CircularProgressIndicator(color: Colors.yellow)
                  : const Icon(Icons.send, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}
