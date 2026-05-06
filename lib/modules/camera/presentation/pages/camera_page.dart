import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locket_app/modules/camera/domain/repository/camera_repository.dart';
import '../application/cubit/camera_cubit.dart';
import 'preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
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

  void _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) =>
          c.lensDirection ==
          (_isFront ? CameraLensDirection.front : CameraLensDirection.back),
    );
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 20),
            _buildPreview(),
            const Spacer(),
            _buildCaptureControls(),
            const SizedBox(height: 20),
            _buildHistoryIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildCaptureControls() {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                if (file != null && mounted) _toPreview(file.path, false);
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
        );
      },
    );
  }

  Widget _buildMainButton(CameraState state) {
    return GestureDetector(
      onTap: () async {
        final image = await _controller!.takePicture();
        _toPreview(image.path, false);
      },
      onLongPress: () async {
        await _controller!.startVideoRecording();
        context.read<CameraCubit>().setRecording(true);
      },
      onLongPressUp: () async {
        final video = await _controller!.stopVideoRecording();
        context.read<CameraCubit>().setRecording(false);
        context.read<CameraCubit>().setMode(CameraAppMode.video);
        _toPreview(video.path, true);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.yellow, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 20),
          ],
        ),
        child: CircleAvatar(
          radius: 35,
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar người dùng (Tạm thời là Icon)
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, color: Colors.white),
          ),
          // Nút danh sách bạn bè ở giữa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "47 Bạn bè", // Sau này dùng data thật
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          // Nút Chat bên phải
          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildHistoryIndicator() {
    return const Column(
      children: [
        Text(
          "Lịch sử",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ],
    );
  }
}
