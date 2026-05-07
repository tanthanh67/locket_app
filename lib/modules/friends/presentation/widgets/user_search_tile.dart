import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friend_cubit.dart';
import '../../../../core/domain/entities/user_entity.dart';

class UserSearchTile extends StatelessWidget {
  final UserEntity user;

  const UserSearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.displayName),
      subtitle: Text(user.email),
      trailing: ElevatedButton(
        onPressed: () {
          context.read<FriendCubit>().sendFriend(user.uid);
        },
        child: const Text("Add"),
      ),
    );
  }
}
