import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/cubit/friend_cubit.dart';
import '../application/cubit/friend_state.dart';
import '../widgets/request_tile.dart';

class IncomingRequestsPage extends StatelessWidget {
  const IncomingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FriendCubit>().loadIncomingRequests();

    return BlocBuilder<FriendCubit, FriendState>(
      builder: (context, state) {
        if (state is FriendIncomingLoaded) {
          if (state.requests.isEmpty) {
            return const Center(child: Text("No requests"));
          }

          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (_, i) {
              return RequestTile(user: state.requests[i]);
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
