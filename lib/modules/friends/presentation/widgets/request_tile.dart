import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../application/cubit/friend_cubit.dart';

class RequestTile extends StatelessWidget {
  final UserEntity user;

  const RequestTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(user.displayName[0])),
      title: Text(user.displayName),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              context.read<FriendCubit>().accept(user.uid);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              context.read<FriendCubit>().reject(user.uid);
            },
          ),
        ],
      ),
    );
  }
}
