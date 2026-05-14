import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/domain/entities/post_entity.dart';
import '../../../domain/repository/camera_repository.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraRepository _repository;

  CameraCubit(this._repository) : super(const CameraState());

  void setMode(CameraAppMode mode) => emit(state.copyWith(mode: mode));

  void setRecording(bool recording) =>
      emit(state.copyWith(isRecording: recording));

  Future<void> postMoment({
    required String localPath,
    required String manualCaption,
    required List<String> selectedFriendIds,
  }) async {
    emit(state.copyWith(status: CameraStatus.loading));
    try {
      final isVideo = state.mode == CameraAppMode.video;

      // 1. Upload & Lấy AI Caption (nếu cần) thông qua Repository
      final url = await _repository.uploadMedia(localPath, isVideo);
      if (url.isEmpty) {
        throw Exception('Upload image failed');
      }

      String finalCaption = manualCaption;
      if (finalCaption.isEmpty && !isVideo) {
        finalCaption = await _repository.getAiCaption(localPath);
      }

      final visibleTo = selectedFriendIds.isEmpty
          ? await _repository.getMyFriendIds()
          : selectedFriendIds;

      // 2. Tạo Entity
      final post = PostEntity(
        senderId: FirebaseAuth.instance.currentUser!.uid,
        mediaUrl: url,
        caption: finalCaption,
        type: isVideo ? 'video' : 'image',
        visibleTo: visibleTo,
        createdAt: DateTime.now(),
      );

      // 3. Lưu vào Firestore
      await _repository.createPost(post);

      emit(state.copyWith(status: CameraStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CameraStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void resetStatus() => emit(state.copyWith(status: CameraStatus.initial));
}
