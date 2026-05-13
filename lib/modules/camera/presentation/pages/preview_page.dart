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
  late final Future<List<String>> _friendsFuture;
  List<String> selectedUids = [];

  @override
  void initState() {
    super.initState();
    _friendsFuture = context.read<CameraRepository>().getMyFriendIds();
  }

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
          context.read<CameraCubit>().resetStatus();
          Navigator.pop(context);
        }

        if (state.status == CameraStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not post moment'),
              backgroundColor: Colors.redAccent,
            ),
          );
          context.read<CameraCubit>().resetStatus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              tooltip: 'Save',
              icon: const Icon(
                Icons.file_download_rounded,
                color: Colors.white,
              ),
              onPressed: _saveToGallery,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
              final mediaSide = (constraints.maxWidth - 24)
                  .clamp(280.0, constraints.maxHeight * 0.58)
                  .toDouble();

              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: _buildMediaPreview(mediaSide),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.fromLTRB(
                        12,
                        0,
                        12,
                        12 + keyboardInset,
                      ),
                      child: _buildComposerPanel(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(double side) {
    return SizedBox.square(
      dimension: side,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.isVideo
                ? Container(
                    color: const Color(0xFF151515),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  )
                : Image.file(File(widget.path), fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposerPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _buildCaptionField()),
                const SizedBox(width: 10),
                _buildSendButton(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Viewers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _buildSelectAllButton(),
              ],
            ),
            const SizedBox(height: 8),
            _buildFriendSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return TextField(
      controller: _captionController,
      minLines: 1,
      maxLines: 3,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Add a message...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFriendSelector() {
    return SizedBox(
      height: 58,
      child: FutureBuilder<List<String>>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD233),
                  strokeWidth: 2.4,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No friends yet',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            );
          }

          final friends = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final uid = friends[index];
              final isSelected = selectedUids.contains(uid);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(
                  () => isSelected
                      ? selectedUids.remove(uid)
                      : selectedUids.add(uid),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFFFD233)
                        : Colors.white10,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white12,
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.person_rounded,
                    color: isSelected ? Colors.black : Colors.white70,
                    size: 24,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectAllButton() {
    return FutureBuilder<List<String>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        final friends = snapshot.data ?? const <String>[];
        if (friends.isEmpty) {
          return const SizedBox.shrink();
        }

        final allSelected = selectedUids.length == friends.length;
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFD233),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            setState(() {
              selectedUids = allSelected ? [] : List<String>.from(friends);
            });
          },
          child: Text(allSelected ? 'Clear' : 'All friends'),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        final isLoading = state.status == CameraStatus.loading;

        return GestureDetector(
          onTap: isLoading ? null : _postMoment,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD233),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD233).withValues(alpha: 0.25),
                  blurRadius: 16,
                ),
              ],
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.8,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.black, size: 23),
          ),
        );
      },
    );
  }

  Future<void> _saveToGallery() async {
    await ImageGallerySaverPlus.saveFile(widget.path);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
  }

  void _postMoment() {
    FocusScope.of(context).unfocus();
    context.read<CameraCubit>().postMoment(
      localPath: widget.path,
      manualCaption: _captionController.text.trim(),
      selectedFriendIds: selectedUids,
    );
  }
}
