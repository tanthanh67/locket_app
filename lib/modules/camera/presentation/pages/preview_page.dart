import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:locket_app/core/domain/entities/user_entity.dart';
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
  late final Future<List<UserEntity>> _friendsFuture;
  bool sendToAllFriends = true;
  bool _isGeneratingCaption = false;
  List<String> selectedUids = [];

  @override
  void initState() {
    super.initState();
    _friendsFuture = context.read<CameraRepository>().getMyFriends();
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
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
        suffixIcon: _buildAiCaptionButton(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAiCaptionButton() {
    final disabled = widget.isVideo || _isGeneratingCaption;

    return Tooltip(
      message: widget.isVideo ? 'Only available for photos' : 'AI caption',
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: disabled ? null : _generateAiCaption,
        icon: _isGeneratingCaption
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD233),
                  strokeWidth: 2,
                ),
              )
            : Icon(
                Icons.auto_awesome_rounded,
                color: disabled ? Colors.white24 : const Color(0xFFFFD233),
                size: 20,
              ),
      ),
    );
  }

  Widget _buildFriendSelector() {
    return SizedBox(
      height: 92,
      child: FutureBuilder<List<UserEntity>>(
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
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildViewerOption(
                label: 'All friends',
                isSelected: sendToAllFriends,
                icon: Icons.group_rounded,
                onTap: () => setState(() {
                  sendToAllFriends = true;
                  selectedUids = [];
                }),
              ),
              ...friends.map((friend) {
                final isSelected =
                    !sendToAllFriends && selectedUids.contains(friend.uid);

                return _buildViewerOption(
                  label: _displayName(friend),
                  isSelected: isSelected,
                  photoUrl: friend.photoUrl,
                  icon: Icons.person_rounded,
                  onTap: () => setState(() {
                    sendToAllFriends = false;
                    if (isSelected) {
                      selectedUids.remove(friend.uid);
                    } else {
                      selectedUids.add(friend.uid);
                    }
                  }),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewerOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    String photoUrl = '',
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD233) : Colors.white24,
                  width: isSelected ? 3 : 1.4,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: isSelected
                    ? const Color(0xFFFFD233)
                    : Colors.white12,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl.isEmpty
                    ? Icon(
                        isSelected ? Icons.check_rounded : icon,
                        color: isSelected ? Colors.black : Colors.white70,
                        size: 25,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFFD233) : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(UserEntity user) {
    if (user.displayName.trim().isNotEmpty) {
      return user.displayName.trim();
    }

    if (user.email.contains('@')) {
      return user.email.split('@').first;
    }

    return 'Friend';
  }

  List<String> _viewerIds(List<UserEntity> friends) {
    if (sendToAllFriends) {
      return friends.map((friend) => friend.uid).toList();
    }

    return selectedUids;
  }

  Widget _buildSendButton() {
    return FutureBuilder<List<UserEntity>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        final friends = snapshot.data ?? const <UserEntity>[];

        return BlocBuilder<CameraCubit, CameraState>(
          builder: (context, state) {
            final isLoading = state.status == CameraStatus.loading;

            return GestureDetector(
              onTap: isLoading ? null : () => _postMoment(friends),
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
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 23,
                      ),
              ),
            );
          },
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

  Future<void> _generateAiCaption() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isGeneratingCaption = true;
    });

    try {
      final caption = await context.read<CameraRepository>().getAiCaption(
        widget.path,
      );
      final nextCaption = caption.trim().isEmpty
          ? 'Khoảnh khắc tuyệt vời'
          : caption.trim();

      if (!mounted) {
        return;
      }

      _captionController.text = nextCaption;
      _captionController.selection = TextSelection.collapsed(
        offset: nextCaption.length,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      const fallbackCaption = 'Khoảnh khắc tuyệt vời';
      _captionController.text = fallbackCaption;
      _captionController.selection = const TextSelection.collapsed(
        offset: fallbackCaption.length,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCaption = false;
        });
      }
    }
  }

  void _postMoment(List<UserEntity> friends) {
    if (!sendToAllFriends && selectedUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one friend')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<CameraCubit>().postMoment(
      localPath: widget.path,
      manualCaption: _captionController.text.trim(),
      selectedFriendIds: _viewerIds(friends),
    );
  }
}
