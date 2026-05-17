import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locket_app/modules/camera/domain/repository/camera_repository.dart';
import '../application/cubit/camera_cubit.dart';
import 'preview_page.dart';

class CameraPage extends StatefulWidget {
  final VoidCallback? onShowFeed;

  const CameraPage({super.key, this.onShowFeed});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final previousController = _controller;
    _controller = null;
    if (mounted) {
      setState(() {});
    }
    await previousController?.dispose();

    final cameras = await availableCameras();
    final preferredDirection = _isFront
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == preferredDirection,
      orElse: () => cameras.first,
    );

    final controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }

    _controller = controller;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final previewSide = (constraints.maxWidth - 4)
              .clamp(280.0, height * 0.56)
              .toDouble();
          final topGap = (height * 0.145).clamp(108.0, 150.0);
          final controlsGap = (height * 0.095).clamp(72.0, 116.0);
          final historyGap = (height * 0.11).clamp(84.0, 140.0);

          return Column(
            children: [
              SizedBox(height: topGap),
              _buildPreview(previewSide),
              SizedBox(height: controlsGap),
              _buildCaptureControls(),
              SizedBox(height: historyGap),
              _buildHistoryIndicator(),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreview(double side) {
    final previewSize = _controller!.value.previewSize;
    final previewWidth = previewSize?.height ?? 1;
    final previewHeight = previewSize?.width ?? 1;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -350) {
          widget.onShowFeed?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox.square(
          dimension: side,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewWidth,
                        height: previewHeight,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 28, left: 28, child: _buildFlashButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureControls() {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  final file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (file != null && context.mounted) {
                    context.read<CameraCubit>().setMode(CameraAppMode.photo);
                    _toPreview(file.path, false);
                  }
                },
              ),
              _buildMainButton(state),
              IconButton(
                icon: const Icon(Icons.cached, color: Colors.white, size: 30),
                onPressed: () {
                  setState(() => _isFront = !_isFront);
                  _initCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashButton() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 30),
    );
  }

  Widget _buildMainButton(CameraState state) {
    return GestureDetector(
      onTap: () async {
        context.read<CameraCubit>().setMode(CameraAppMode.photo);
        final image = await _controller!.takePicture();
        _toPreview(image.path, false);
      },
      onLongPress: () async {
        final cameraCubit = context.read<CameraCubit>();
        await _controller!.startVideoRecording();
        cameraCubit.setRecording(true);
      },
      onLongPressUp: () async {
        final cameraCubit = context.read<CameraCubit>();
        final video = await _controller!.stopVideoRecording();
        if (!mounted) {
          return;
        }

        cameraCubit.setRecording(false);
        cameraCubit.setMode(CameraAppMode.video);
        _toPreview(video.path, true);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.yellow, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 44,
          backgroundColor: state.isRecording ? Colors.red : Colors.white,
        ),
      ),
    );
  }

  void _toPreview(String path, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepositoryProvider<CameraRepository>.value(
          value: context
              .read<
                CameraRepository
              >(), // Lấy repo từ trang hiện tại truyền sang trang mới
          child: PreviewPage(path: path, isVideo: isVideo),
        ),
      ),
    );
  }

  Widget _buildHistoryIndicator() {
    return GestureDetector(
      onTap: widget.onShowFeed,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
