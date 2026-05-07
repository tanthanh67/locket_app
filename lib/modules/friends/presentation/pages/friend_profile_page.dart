import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';

class FriendProfilePage extends StatelessWidget {
  final String uid;

  const FriendProfilePage({super.key, required this.uid});

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUser() {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: getUser(),
      builder: (context, snapshot) {
        // ================= LOADING =================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ================= ERROR =================
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                "User not found",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final data = snapshot.data!.data()!;

        final name = data['displayName'] ?? 'Unknown';
        final email = data['email'] ?? '';

        return Scaffold(
          backgroundColor: AppColors.surface,

          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(name, style: const TextStyle(color: Colors.white)),
          ),

          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ================= AVATAR =================
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= NAME =================
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 30),

                // ================= INFO CARD =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Friend Profile",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "This profile updates in real-time like Locket.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
