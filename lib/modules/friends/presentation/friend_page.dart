import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friend_cubit.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friend_state.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friends")),
      body: BlocBuilder<FriendCubit, FriendState>(
        builder: (context, state) {
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FriendLoaded) {
            return ListView.builder(
              itemCount: state.friends.length,
              itemBuilder: (_, i) {
                final user = state.friends[i];
                return ListTile(
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                );
              },
            );
          }

          if (state is FriendError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
