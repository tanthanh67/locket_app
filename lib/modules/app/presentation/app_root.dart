import 'package:flutter/material.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Locket thường có giao diện tối
        primarySwatch: Colors.yellow, // Màu vàng đặc trưng của Locket Gold
        scaffoldBackgroundColor: Colors.black,
      ),
      // Sau này sẽ dùng BlocBuilder để check AuthState ở đây
      home: const PlaceholderPage(), 
    );
  }
}

// Trang tạm thời để kiểm tra app đã chạy chưa
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Locket App đã kết nối Firebase!",
          style: TextStyle(color: Colors.yellow, fontSize: 20),
        ),
      ),
    );
  }
}
