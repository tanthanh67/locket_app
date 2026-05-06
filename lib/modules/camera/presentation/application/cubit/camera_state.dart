part of 'camera_cubit.dart';


enum CameraStatus { initial, loading, success, error }

enum CameraAppMode { photo, video }

class CameraState extends Equatable {
  final CameraStatus status;
  final CameraAppMode mode;
  final bool isRecording;
  final String? errorMessage;

  const CameraState({
    this.status = CameraStatus.initial,
    this.mode = CameraAppMode.photo,
    this.isRecording = false,
    this.errorMessage,
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraAppMode? mode,
    bool? isRecording,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, mode, isRecording, errorMessage];
}
