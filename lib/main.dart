import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ================= AUTH =================
import 'modules/auth/data/repositories/auth_repository_impl.dart';
import 'modules/auth/presentation/application/cubit/auth_cubit.dart';

// ================= APP =================
import 'modules/app/presentation/app_root.dart';
import 'core/constants/app_colors.dart';

// ================= FIREBASE =================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= FRIENDS =================
import 'modules/friends/data/data_sources/friend_remote_data_source.dart';
import 'modules/friends/data/repositories/friend_repository_impl.dart';
import 'modules/friends/presentation/application/cubit/friend_cubit.dart';

// ================= USE CASES =================
import 'modules/friends/domain/use_cases/get_friends_usecase.dart';
import 'modules/friends/domain/use_cases/send_friend_request_usecase.dart';
import 'modules/friends/domain/use_cases/accept_friend_request_usecase.dart';
import 'modules/friends/domain/use_cases/reject_friend_request_usecase.dart';
import 'modules/friends/domain/use_cases/unfriend_usecase.dart';
import 'modules/friends/domain/use_cases/search_users_usecase.dart';
import 'modules/friends/domain/use_cases/get_incoming_friend_requests_usecase.dart';
import 'package:locket_app/modules/friends/domain/use_cases/get_all_users_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= ENV =================
  await dotenv.load(fileName: ".env");

  // ================= FIREBASE =================
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // ================= AUTH =================
  final authRepo = AuthRepositoryImpl();

  // ================= FRIEND DATA =================
  final friendRemote = FriendRemoteDataSourceImpl(firestore);
  final friendRepo = FriendRepositoryImpl(friendRemote, auth);

  // ================= USE CASES =================
  final getFriends = GetFriendsUseCase(friendRepo);
  final sendRequest = SendFriendRequestUseCase(friendRepo);
  final acceptRequest = AcceptFriendRequestUseCase(friendRepo);
  final rejectRequest = RejectFriendRequestUseCase(friendRepo);
  final unfriend = UnfriendUseCase(friendRepo);
  final searchUsers = SearchUsersUseCase(friendRepo);
  final getIncomingRequests = GetIncomingRequestsUseCase(friendRepo);
  final getAllUsers = GetAllUsersUseCase(friendRepo);
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: friendRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // ================= AUTH =================
          BlocProvider(create: (_) => AuthCubit(authRepo)..monitorAuthState()),

          // ================= FRIEND =================
          BlocProvider(
            create: (_) => FriendCubit(
              getFriends: getFriends,
              sendRequest: sendRequest,
              acceptRequest: acceptRequest,
              rejectRequest: rejectRequest,
              unfriendUseCase: unfriend,
              searchUsersUseCase: searchUsers,
              getIncomingRequestsUseCase: getIncomingRequests,
              getAllUsersUseCase: getAllUsers,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// ================= ROOT APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locket Gold',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'Inter',
      ),
      home: const AppRoot(),
    );
  }
}
